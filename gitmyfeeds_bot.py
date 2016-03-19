#!/usr/bin/python
"""telegram bot to send github user rss-feeds"""

import time
import json
import httplib
from bs4 import BeautifulSoup
import telegram
import re
import psycopg2
import psycopg2.extras

with open('config.json', 'r') as f:
    config = json.load(f)

pg = config['db']['pg_conn']
tg_bot = config['telegram_bot']

print '[%s] start...' % time.strftime('%d.%m.%Y %H:%M:%S')

# connect to postgres
conn = psycopg2.connect(
    "host=%s port=%s dbname=%s user=%s password=%s"
    % (pg['host'], pg['port'], pg['dbname'], pg['user'], pg['pass']),
    cursor_factory=psycopg2.extras.DictCursor)

cur = conn.cursor()
# now use test user only
user_id = 1
cur.execute("""
    select uat.token, gu.username
    from users_atom_tokens uat
        join github_users gu on gu.user_id = uat.user_id
    where uat.user_id = %s
            """ % user_id)
atom = cur.fetchone()

# get feeds for one test user
c = httplib.HTTPSConnection('github.com')
c.request('GET', '/%s.private.atom?token=%s'
          % (atom['username'], atom['token']))
response = c.getresponse()
data = response.read()
soup = BeautifulSoup(data, 'html.parser')

# prepare regexp to get event and entry id from xml
entry_id_pat = re.compile(r".*:(\w+)/(\d+)$")

# parse entries data and save it in the db
for entry in soup.find_all('entry'):
    published = entry.published.get_text()
    entry_title = entry.title.get_text()
    link = entry.link['href']
    title = entry.title.get_text()

    author_raw = entry.author
    author_names = author_raw.find_all('name')
    author = None
    if len(author_names):
        author = author_names[0].get_text()

    entry_id_raw = entry.id.get_text()
    parse_id_res = entry_id_pat.match(entry_id_raw)
    if parse_id_res is None:
        print "notice: could not recognize entry id by pattern. skip"
        continue
    event = parse_id_res.group(1)
    entry_id = parse_id_res.group(2)

    entry_text = None
    entry_text_raw = entry.content.get_text()
    soup_entry = BeautifulSoup(entry_text_raw, 'html.parser')
    quote = soup_entry.blockquote
    if quote is not None:
        entry_text = quote.get_text().strip()

    cur.execute("""
        insert into feeds_private(
            user_id, event, entry_id, published, title, author, content, link
        ) values (%s, %s, %s, %s, %s, %s, %s, %s)
        on conflict (entry_id) do nothing
                """, (user_id, event, entry_id, published,
                      title, author, entry_text, link)
                )
    conn.commit()

# prepare telegram bot
bot = telegram.Bot(token=tg_bot['token'])

# for all active chats send new feeds
cur_feeds = conn.cursor()
cur_feeds.execute("""
    select fp.id, fp.title, fp.link, fp.content
        , to_char(fp.published, 'dd.mm.yy hh24:mi') dt
    from feeds_private fp
        left join feeds_sent fs
            on fp.id = fs.feed_private_id and fs.user_id = %s
    where fs.id is null
    order by fp.published asc
    limit %s
                  """ % (user_id, tg_bot['send_feeds_limit']))

cur_upd = conn.cursor()
cur.execute("""
    select chat_id
    from chats_to_send
    where active = true
            """)
for chat in cur:
    for feed in cur_feeds:
        print 'send feed item [%s] to chat [%s]' \
            % (feed['id'], chat['chat_id'])
        # prepare message to send
        msg = "*%s* [%s](%s)" % (feed['dt'], feed['title'], feed['link'])
        if not feed['content'] is None:
            msg += "\n_%s_" % feed['content']

        # send it
        bot.sendMessage(
            chat_id=chat['chat_id'],
            text=msg,
            parse_mode=telegram.ParseMode.MARKDOWN,
            disable_web_page_preview=True)

        # mark as read to skip it next time
        cur_upd.execute("""
            insert into feeds_sent(feed_private_id, user_id)
            values (%s, %s)
                        """ % (feed['id'], user_id))
        conn.commit()

cur_feeds.close()
cur_upd.close()
cur.close()

conn.close()

print '[%s] finish.' % time.strftime('%d.%m.%Y %H:%M:%S')
