#!/usr/bin/python

import sys
import json
import httplib
from bs4 import BeautifulSoup
import telegram
import re
import psycopg2

TELEGRAM_TOKEN = ""
GH_TOKEN = ""

""" connect to postgres """
conn = psycopg2.connect("host=127.0.0.1"\
        " port=5432"\
        " dbname=gitmyfeeds"\
        " user=postgres"\
        " password=")

""" get feeds for one test user """
c = httplib.HTTPSConnection('github.com')
c.request('GET', '/olshevskiy87.private.atom?token' + GH_TOKEN)
response = c.getresponse()
data = response.read()
soup = BeautifulSoup(data, 'html.parser')

""" prepare regexp to get event and entry id from xml """
entry_id_pat = re.compile(r".*:(\w+)/(\d+)$")

""" parse entries data and save it in the db """
cur = conn.cursor()
for entry in soup.find_all('entry'):
    published = entry.published.get_text()
    entry_title = entry.title.get_text()
    published = entry.published.get_text()
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

    cur.execute("select id from feeds_private where entry_id = %s", (entry_id,))
    if cur.rowcount != 0:
        # print 'there is already an entry with id [%s]'% entry_id
        continue

    """ there is not such entry, lets add """
    # print 'add entry with id [%s]'% entry_id
    cur.execute("insert into feeds_private("\
                "user_id, event, entry_id, published, title, author, content"\
                ") values(%s, %s, %s, %s, %s, %s, %s)",\
                (1, event, entry_id, published, title, author, entry_text))
    conn.commit()

cur.close()

try:
    f = open('chats_to_send.json', 'r')
except:
    sys.exit('error: could not open json file. exit.\n')

json_file_data = None
try:
    json_file_data = f.read()
except:
    sys.exit('error: could not read from json file. exit.\n')

f.close()

json_p = json.loads(json_file_data)
if not isinstance(json_p, list):
    sys.exit('error: json must be a list of objects. exit.\n')

""" for all connected chats send new feeds """
for chat_item in json_p:
    print 'chat_id [', chat_item['chat_id'], ']'
    bot = telegram.Bot(token = TELEGRAM_TOKEN)
    bot.sendMessage(chat_id = chat_item['chat_id'], text = "Hi")

conn.close()

