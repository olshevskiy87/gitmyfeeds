gitmyfeeds telegram bot
=======================

### Dependencies

#### Python

* Interpreter `python` 2.7+

* Packages

    - `BeautifulSoup` 3.2.1
    - `python-telegram-bot` 3.2.0
    - `psycopg2` 2.6.1

To install all packages at once run

```sh
$ pip install --user -r requirements.txt
```

#### DBMS

* `PostgreSQL` 9.5 (first version with `ON CONFLICT ... DO ...`)

To install database schema run

```sh
$ psql -h localhost -d gitmyfeeds -f schema.sql
```

### LICENSE
Copyright (c) 2016 Dmitriy Olshevskiy. MIT LICENSE.
See LICENSE for details.
