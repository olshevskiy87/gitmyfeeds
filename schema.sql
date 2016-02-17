CREATE TABLE chats_to_send (
    id serial NOT NULL PRIMARY KEY,
    chat_id bigint NOT NULL UNIQUE,
    description text,
    active boolean DEFAULT false
);

CREATE TABLE feeds_private (
    id bigserial NOT NULL PRIMARY KEY,
    user_id integer,
    event text,
    entry_id bigint UNIQUE,
    published timestamp with time zone,
    title text,
    author text,
    content text,
    creadt timestamp with time zone DEFAULT now(),
    link text
);

CREATE TABLE feeds_sent (
    id bigint NOT NULL,
    feed_private_id bigint NOT NULL,
    user_id integer NOT NULL,
    creadt timestamp with time zone DEFAULT now()
);

CREATE TABLE github_users (
    user_id integer NOT NULL PRIMARY KEY,
    username text NOT NULL UNIQUE,
    email text
);

CREATE TABLE users_atom_tokens (
    user_id integer NOT NULL PRIMARY KEY,
    token text
);

CREATE INDEX idx_fs_feed_private_id
    ON feeds_sent USING btree (feed_private_id);

CREATE INDEX idx_fs_user_id
    ON feeds_sent USING btree (user_id);
