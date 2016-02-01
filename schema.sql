--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: feeds_private; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE feeds_private (
    id bigint NOT NULL,
    user_id integer,
    event text,
    entry_id bigint,
    published timestamp with time zone,
    title text,
    author text,
    content text,
    creadt timestamp with time zone DEFAULT now()
);


ALTER TABLE feeds_private OWNER TO postgres;

--
-- Name: feeds_private_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE feeds_private_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE feeds_private_id_seq OWNER TO postgres;

--
-- Name: feeds_private_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE feeds_private_id_seq OWNED BY feeds_private.id;


--
-- Name: feeds_sent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE feeds_sent (
    id bigint NOT NULL,
    feed_private_id bigint NOT NULL,
    user_id integer NOT NULL,
    creadt timestamp with time zone DEFAULT now()
);


ALTER TABLE feeds_sent OWNER TO postgres;

--
-- Name: feeds_sent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE feeds_sent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE feeds_sent_id_seq OWNER TO postgres;

--
-- Name: feeds_sent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE feeds_sent_id_seq OWNED BY feeds_sent.id;


--
-- Name: github_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE github_users (
    user_id integer NOT NULL,
    username text NOT NULL,
    email text
);


ALTER TABLE github_users OWNER TO postgres;

--
-- Name: users_atom_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users_atom_tokens (
    id bigint NOT NULL,
    user_id integer,
    token text
);


ALTER TABLE users_atom_tokens OWNER TO postgres;

--
-- Name: users_atom_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_atom_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_atom_tokens_id_seq OWNER TO postgres;

--
-- Name: users_atom_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_atom_tokens_id_seq OWNED BY users_atom_tokens.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY feeds_private ALTER COLUMN id SET DEFAULT nextval('feeds_private_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY feeds_sent ALTER COLUMN id SET DEFAULT nextval('feeds_sent_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users_atom_tokens ALTER COLUMN id SET DEFAULT nextval('users_atom_tokens_id_seq'::regclass);


--
-- Name: feeds_private_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY feeds_private
    ADD CONSTRAINT feeds_private_pkey PRIMARY KEY (id);


--
-- Name: github_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY github_users
    ADD CONSTRAINT github_users_pkey PRIMARY KEY (user_id);


--
-- Name: users_atom_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users_atom_tokens
    ADD CONSTRAINT users_atom_tokens_pkey PRIMARY KEY (id);


--
-- Name: idx_fp_entry_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fp_entry_id ON feeds_private USING btree (entry_id);


--
-- Name: idx_fs_feed_private_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fs_feed_private_id ON feeds_sent USING btree (feed_private_id);


--
-- Name: idx_fs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fs_user_id ON feeds_sent USING btree (user_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

