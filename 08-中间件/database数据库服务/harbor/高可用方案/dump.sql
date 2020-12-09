--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md50c771dbd92ab99afc949a6002c1d1b0b';
CREATE ROLE server;
ALTER ROLE server WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md563ec1f8a8e6666270fcfc569fb32677d';
CREATE ROLE signer;
ALTER ROLE signer WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5ccb059892368241682f5c5ce9696e8fc';






--
-- Database creation
--

CREATE DATABASE notaryserver WITH TEMPLATE = template0 OWNER = postgres;
GRANT ALL ON DATABASE notaryserver TO server;
CREATE DATABASE notarysigner WITH TEMPLATE = template0 OWNER = postgres;
GRANT ALL ON DATABASE notarysigner TO signer;
CREATE DATABASE registry WITH TEMPLATE = template0 OWNER = postgres;
REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect notaryserver

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- PostgreSQL database dump complete
--

\connect notarysigner

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

\connect registry

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- Name: update_update_time_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_update_time_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.update_time = NOW();
    RETURN NEW;
  END;
$$;


ALTER FUNCTION public.update_update_time_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.access (
    access_id integer NOT NULL,
    access_code character(1),
    comment character varying(30)
);


ALTER TABLE public.access OWNER TO postgres;

--
-- Name: access_access_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.access_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.access_access_id_seq OWNER TO postgres;

--
-- Name: access_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.access_access_id_seq OWNED BY public.access.access_id;


--
-- Name: access_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.access_log (
    log_id integer NOT NULL,
    username character varying(255) NOT NULL,
    project_id integer NOT NULL,
    repo_name character varying(256),
    repo_tag character varying(128),
    guid character varying(64),
    operation character varying(20) NOT NULL,
    op_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.access_log OWNER TO postgres;

--
-- Name: access_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.access_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.access_log_log_id_seq OWNER TO postgres;

--
-- Name: access_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.access_log_log_id_seq OWNED BY public.access_log.log_id;


--
-- Name: admin_job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_job (
    id integer NOT NULL,
    job_name character varying(64) NOT NULL,
    job_kind character varying(64) NOT NULL,
    cron_str character varying(256),
    status character varying(64) NOT NULL,
    job_uuid character varying(64),
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.admin_job OWNER TO postgres;

--
-- Name: admin_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_job_id_seq OWNER TO postgres;

--
-- Name: admin_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_job_id_seq OWNED BY public.admin_job.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: clair_vuln_timestamp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clair_vuln_timestamp (
    id integer NOT NULL,
    namespace character varying(128) NOT NULL,
    last_update timestamp without time zone NOT NULL
);


ALTER TABLE public.clair_vuln_timestamp OWNER TO postgres;

--
-- Name: clair_vuln_timestamp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clair_vuln_timestamp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clair_vuln_timestamp_id_seq OWNER TO postgres;

--
-- Name: clair_vuln_timestamp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clair_vuln_timestamp_id_seq OWNED BY public.clair_vuln_timestamp.id;


--
-- Name: harbor_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.harbor_label (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description text,
    color character varying(16),
    level character(1) NOT NULL,
    scope character(1) NOT NULL,
    project_id integer,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.harbor_label OWNER TO postgres;

--
-- Name: harbor_label_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.harbor_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.harbor_label_id_seq OWNER TO postgres;

--
-- Name: harbor_label_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.harbor_label_id_seq OWNED BY public.harbor_label.id;


--
-- Name: harbor_resource_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.harbor_resource_label (
    id integer NOT NULL,
    label_id integer NOT NULL,
    resource_id integer,
    resource_name character varying(256),
    resource_type character(1) NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.harbor_resource_label OWNER TO postgres;

--
-- Name: harbor_resource_label_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.harbor_resource_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.harbor_resource_label_id_seq OWNER TO postgres;

--
-- Name: harbor_resource_label_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.harbor_resource_label_id_seq OWNED BY public.harbor_resource_label.id;


--
-- Name: harbor_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.harbor_user (
    user_id integer NOT NULL,
    username character varying(255),
    email character varying(255),
    password character varying(40) NOT NULL,
    realname character varying(255) NOT NULL,
    comment character varying(30),
    deleted boolean DEFAULT false NOT NULL,
    reset_uuid character varying(40) DEFAULT NULL::character varying,
    salt character varying(40) DEFAULT NULL::character varying,
    sysadmin_flag boolean DEFAULT false NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.harbor_user OWNER TO postgres;

--
-- Name: harbor_user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.harbor_user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.harbor_user_user_id_seq OWNER TO postgres;

--
-- Name: harbor_user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.harbor_user_user_id_seq OWNED BY public.harbor_user.user_id;


--
-- Name: img_scan_job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.img_scan_job (
    id integer NOT NULL,
    status character varying(64) NOT NULL,
    repository character varying(256) NOT NULL,
    tag character varying(128) NOT NULL,
    digest character varying(128),
    job_uuid character varying(64),
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.img_scan_job OWNER TO postgres;

--
-- Name: img_scan_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.img_scan_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.img_scan_job_id_seq OWNER TO postgres;

--
-- Name: img_scan_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.img_scan_job_id_seq OWNED BY public.img_scan_job.id;


--
-- Name: img_scan_overview; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.img_scan_overview (
    id integer NOT NULL,
    image_digest character varying(128) NOT NULL,
    scan_job_id integer NOT NULL,
    severity integer DEFAULT 0 NOT NULL,
    components_overview character varying(2048),
    details_key character varying(128),
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.img_scan_overview OWNER TO postgres;

--
-- Name: img_scan_overview_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.img_scan_overview_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.img_scan_overview_id_seq OWNER TO postgres;

--
-- Name: img_scan_overview_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.img_scan_overview_id_seq OWNED BY public.img_scan_overview.id;


--
-- Name: job_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_log (
    log_id integer NOT NULL,
    job_uuid character varying(64) NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    content text
);


ALTER TABLE public.job_log OWNER TO postgres;

--
-- Name: job_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_log_log_id_seq OWNER TO postgres;

--
-- Name: job_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_log_log_id_seq OWNED BY public.job_log.log_id;


--
-- Name: oidc_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oidc_user (
    id integer NOT NULL,
    user_id integer NOT NULL,
    secret character varying(255) NOT NULL,
    subiss character varying(255) NOT NULL,
    token text,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.oidc_user OWNER TO postgres;

--
-- Name: oidc_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oidc_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oidc_user_id_seq OWNER TO postgres;

--
-- Name: oidc_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oidc_user_id_seq OWNED BY public.oidc_user.id;


--
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    project_id integer NOT NULL,
    owner_id integer NOT NULL,
    name character varying(255) NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.project OWNER TO postgres;

--
-- Name: project_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_member (
    id integer NOT NULL,
    project_id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character(1) NOT NULL,
    role integer NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.project_member OWNER TO postgres;

--
-- Name: project_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_member_id_seq OWNER TO postgres;

--
-- Name: project_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_member_id_seq OWNED BY public.project_member.id;


--
-- Name: project_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_metadata (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.project_metadata OWNER TO postgres;

--
-- Name: project_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_metadata_id_seq OWNER TO postgres;

--
-- Name: project_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_metadata_id_seq OWNED BY public.project_metadata.id;


--
-- Name: project_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_project_id_seq OWNER TO postgres;

--
-- Name: project_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_project_id_seq OWNED BY public.project.project_id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.properties (
    id integer NOT NULL,
    k character varying(64) NOT NULL,
    v character varying(1024) NOT NULL
);


ALTER TABLE public.properties OWNER TO postgres;

--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.properties_id_seq OWNER TO postgres;

--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.properties_id_seq OWNED BY public.properties.id;


--
-- Name: registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registry (
    id integer NOT NULL,
    name character varying(64),
    url character varying(256),
    access_key character varying(255),
    access_secret character varying(4096),
    insecure boolean DEFAULT false NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    credential_type character varying(16),
    type character varying(32),
    description text,
    health character varying(16)
);


ALTER TABLE public.registry OWNER TO postgres;

--
-- Name: replication_execution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.replication_execution (
    id integer NOT NULL,
    policy_id integer NOT NULL,
    status character varying(32),
    status_text text,
    total integer DEFAULT 0 NOT NULL,
    failed integer DEFAULT 0 NOT NULL,
    succeed integer DEFAULT 0 NOT NULL,
    in_progress integer DEFAULT 0 NOT NULL,
    stopped integer DEFAULT 0 NOT NULL,
    trigger character varying(64),
    start_time timestamp without time zone DEFAULT now(),
    end_time timestamp without time zone
);


ALTER TABLE public.replication_execution OWNER TO postgres;

--
-- Name: replication_execution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replication_execution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replication_execution_id_seq OWNER TO postgres;

--
-- Name: replication_execution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replication_execution_id_seq OWNED BY public.replication_execution.id;


--
-- Name: replication_schedule_job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.replication_schedule_job (
    id integer NOT NULL,
    status character varying(64) NOT NULL,
    policy_id integer NOT NULL,
    job_id character varying(64),
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.replication_schedule_job OWNER TO postgres;

--
-- Name: replication_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replication_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replication_job_id_seq OWNER TO postgres;

--
-- Name: replication_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replication_job_id_seq OWNED BY public.replication_schedule_job.id;


--
-- Name: replication_policy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.replication_policy (
    id integer NOT NULL,
    name character varying(256),
    dest_registry_id integer,
    enabled boolean DEFAULT true NOT NULL,
    description text,
    deleted boolean DEFAULT false NOT NULL,
    trigger character varying(256),
    filters character varying(1024),
    replicate_deletion boolean DEFAULT false NOT NULL,
    start_time timestamp without time zone,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    creator character varying(256),
    src_registry_id integer,
    dest_namespace character varying(256),
    override boolean
);


ALTER TABLE public.replication_policy OWNER TO postgres;

--
-- Name: replication_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replication_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replication_policy_id_seq OWNER TO postgres;

--
-- Name: replication_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replication_policy_id_seq OWNED BY public.replication_policy.id;


--
-- Name: replication_target_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replication_target_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replication_target_id_seq OWNER TO postgres;

--
-- Name: replication_target_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replication_target_id_seq OWNED BY public.registry.id;


--
-- Name: replication_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.replication_task (
    id integer NOT NULL,
    execution_id integer NOT NULL,
    resource_type character varying(64),
    src_resource character varying(256),
    dst_resource character varying(256),
    operation character varying(32),
    job_id character varying(64),
    status character varying(32),
    start_time timestamp without time zone DEFAULT now(),
    end_time timestamp without time zone
);


ALTER TABLE public.replication_task OWNER TO postgres;

--
-- Name: replication_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replication_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replication_task_id_seq OWNER TO postgres;

--
-- Name: replication_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replication_task_id_seq OWNED BY public.replication_task.id;


--
-- Name: repository; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repository (
    repository_id integer NOT NULL,
    name character varying(255) NOT NULL,
    project_id integer NOT NULL,
    description text,
    pull_count integer DEFAULT 0 NOT NULL,
    star_count integer DEFAULT 0 NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.repository OWNER TO postgres;

--
-- Name: repository_repository_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.repository_repository_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.repository_repository_id_seq OWNER TO postgres;

--
-- Name: repository_repository_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.repository_repository_id_seq OWNED BY public.repository.repository_id;


--
-- Name: robot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.robot (
    id integer NOT NULL,
    name character varying(255),
    description character varying(1024),
    project_id integer,
    expiresat bigint,
    disabled boolean DEFAULT false NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.robot OWNER TO postgres;

--
-- Name: robot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.robot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.robot_id_seq OWNER TO postgres;

--
-- Name: robot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.robot_id_seq OWNED BY public.robot.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    role_id integer NOT NULL,
    role_mask integer DEFAULT 0 NOT NULL,
    role_code character varying(20),
    name character varying(20)
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: role_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_role_id_seq OWNER TO postgres;

--
-- Name: role_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_role_id_seq OWNED BY public.role.role_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: user_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_group (
    id integer NOT NULL,
    group_name character varying(255) NOT NULL,
    group_type smallint DEFAULT 0,
    ldap_group_dn character varying(512) NOT NULL,
    creation_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_group OWNER TO postgres;

--
-- Name: user_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_group_id_seq OWNER TO postgres;

--
-- Name: user_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_group_id_seq OWNED BY public.user_group.id;


--
-- Name: access access_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access ALTER COLUMN access_id SET DEFAULT nextval('public.access_access_id_seq'::regclass);


--
-- Name: access_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_log ALTER COLUMN log_id SET DEFAULT nextval('public.access_log_log_id_seq'::regclass);


--
-- Name: admin_job id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_job ALTER COLUMN id SET DEFAULT nextval('public.admin_job_id_seq'::regclass);


--
-- Name: clair_vuln_timestamp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clair_vuln_timestamp ALTER COLUMN id SET DEFAULT nextval('public.clair_vuln_timestamp_id_seq'::regclass);


--
-- Name: harbor_label id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_label ALTER COLUMN id SET DEFAULT nextval('public.harbor_label_id_seq'::regclass);


--
-- Name: harbor_resource_label id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_resource_label ALTER COLUMN id SET DEFAULT nextval('public.harbor_resource_label_id_seq'::regclass);


--
-- Name: harbor_user user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_user ALTER COLUMN user_id SET DEFAULT nextval('public.harbor_user_user_id_seq'::regclass);


--
-- Name: img_scan_job id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.img_scan_job ALTER COLUMN id SET DEFAULT nextval('public.img_scan_job_id_seq'::regclass);


--
-- Name: img_scan_overview id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.img_scan_overview ALTER COLUMN id SET DEFAULT nextval('public.img_scan_overview_id_seq'::regclass);


--
-- Name: job_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_log ALTER COLUMN log_id SET DEFAULT nextval('public.job_log_log_id_seq'::regclass);


--
-- Name: oidc_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oidc_user ALTER COLUMN id SET DEFAULT nextval('public.oidc_user_id_seq'::regclass);


--
-- Name: project project_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project ALTER COLUMN project_id SET DEFAULT nextval('public.project_project_id_seq'::regclass);


--
-- Name: project_member id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member ALTER COLUMN id SET DEFAULT nextval('public.project_member_id_seq'::regclass);


--
-- Name: project_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_metadata ALTER COLUMN id SET DEFAULT nextval('public.project_metadata_id_seq'::regclass);


--
-- Name: properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties ALTER COLUMN id SET DEFAULT nextval('public.properties_id_seq'::regclass);


--
-- Name: registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registry ALTER COLUMN id SET DEFAULT nextval('public.replication_target_id_seq'::regclass);


--
-- Name: replication_execution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_execution ALTER COLUMN id SET DEFAULT nextval('public.replication_execution_id_seq'::regclass);


--
-- Name: replication_policy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_policy ALTER COLUMN id SET DEFAULT nextval('public.replication_policy_id_seq'::regclass);


--
-- Name: replication_schedule_job id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_schedule_job ALTER COLUMN id SET DEFAULT nextval('public.replication_job_id_seq'::regclass);


--
-- Name: replication_task id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_task ALTER COLUMN id SET DEFAULT nextval('public.replication_task_id_seq'::regclass);


--
-- Name: repository repository_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository ALTER COLUMN repository_id SET DEFAULT nextval('public.repository_repository_id_seq'::regclass);


--
-- Name: robot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.robot ALTER COLUMN id SET DEFAULT nextval('public.robot_id_seq'::regclass);


--
-- Name: role role_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN role_id SET DEFAULT nextval('public.role_role_id_seq'::regclass);


--
-- Name: user_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_group ALTER COLUMN id SET DEFAULT nextval('public.user_group_id_seq'::regclass);


--
-- Data for Name: access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.access (access_id, access_code, comment) FROM stdin;
1	M	Management access for project
2	R	Read access for project
3	W	Write access for project
4	D	Delete access for project
5	S	Search access for project
\.


--
-- Name: access_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.access_access_id_seq', 33, true);


--
-- Data for Name: access_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.access_log (log_id, username, project_id, repo_name, repo_tag, guid, operation, op_time) FROM stdin;
1	admin	2	test/	N/A		create	2019-08-20 09:32:55.130373
2	admin	2	test/maven-test	latest		push	2019-08-20 09:33:43.292524
3	admin	2	test/maven-test	latest		pull	2019-08-20 09:34:01.05839
4	admin	2	test/maven-test	latest		delete	2019-08-20 09:34:24.361532
5	admin	2	test/	N/A		delete	2019-08-20 09:34:30.53196
\.


--
-- Name: access_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.access_log_log_id_seq', 33, true);


--
-- Data for Name: admin_job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_job (id, job_name, job_kind, cron_str, status, job_uuid, creation_time, update_time, deleted) FROM stdin;
\.


--
-- Name: admin_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_job_id_seq', 1, false);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
1.6.0
\.


--
-- Data for Name: clair_vuln_timestamp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clair_vuln_timestamp (id, namespace, last_update) FROM stdin;
\.


--
-- Name: clair_vuln_timestamp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clair_vuln_timestamp_id_seq', 1, false);


--
-- Data for Name: harbor_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.harbor_label (id, name, description, color, level, scope, project_id, creation_time, update_time, deleted) FROM stdin;
\.


--
-- Name: harbor_label_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.harbor_label_id_seq', 1, false);


--
-- Data for Name: harbor_resource_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.harbor_resource_label (id, label_id, resource_id, resource_name, resource_type, creation_time, update_time) FROM stdin;
\.


--
-- Name: harbor_resource_label_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.harbor_resource_label_id_seq', 1, false);


--
-- Data for Name: harbor_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.harbor_user (user_id, username, email, password, realname, comment, deleted, reset_uuid, salt, sysadmin_flag, creation_time, update_time) FROM stdin;
2	anonymous	anonymous@example.com		anonymous user	anonymous user	t	\N	\N	f	2019-08-20 09:31:12.352773	2019-08-20 09:31:12.352773
1	admin	admin@example.com	6aa1fa97d5d4a31e55114138453f196f	system admin	admin user	f	\N	dld1q4kszhxm9gkmzf52425zdmb7rlk3	t	2019-08-20 09:31:12.352773	2019-08-20 09:31:14.899152
\.


--
-- Name: harbor_user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.harbor_user_user_id_seq', 33, true);


--
-- Data for Name: img_scan_job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.img_scan_job (id, status, repository, tag, digest, job_uuid, creation_time, update_time) FROM stdin;
\.


--
-- Name: img_scan_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.img_scan_job_id_seq', 1, false);


--
-- Data for Name: img_scan_overview; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.img_scan_overview (id, image_digest, scan_job_id, severity, components_overview, details_key, creation_time, update_time) FROM stdin;
\.


--
-- Name: img_scan_overview_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.img_scan_overview_id_seq', 1, false);


--
-- Data for Name: job_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_log (log_id, job_uuid, creation_time, content) FROM stdin;
\.


--
-- Name: job_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_log_log_id_seq', 1, false);


--
-- Data for Name: oidc_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oidc_user (id, user_id, secret, subiss, token, creation_time, update_time) FROM stdin;
\.


--
-- Name: oidc_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oidc_user_id_seq', 1, false);


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (project_id, owner_id, name, creation_time, update_time, deleted) FROM stdin;
1	1	library	2019-08-20 09:31:12.352773	2019-08-20 09:31:12.352773	f
2	1	test#2	2019-08-20 09:32:54	2019-08-20 09:34:30.520688	t
\.


--
-- Data for Name: project_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_member (id, project_id, entity_id, entity_type, role, creation_time, update_time) FROM stdin;
1	1	1	u	1	2019-08-20 09:31:12.352773	2019-08-20 09:31:12.352773
2	2	1	u	1	2019-08-20 09:32:55.08649	2019-08-20 09:32:55.08649
\.


--
-- Name: project_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_member_id_seq', 33, true);


--
-- Data for Name: project_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_metadata (id, project_id, name, value, creation_time, update_time, deleted) FROM stdin;
1	1	public	true	2019-08-20 09:31:12.352773	2019-08-20 09:31:12.352773	f
2	2	public	true	2019-08-20 09:32:55	2019-08-20 09:34:30.493208	t
\.


--
-- Name: project_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_metadata_id_seq', 33, true);


--
-- Name: project_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_project_id_seq', 33, true);


--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.properties (id, k, v) FROM stdin;
\.


--
-- Name: properties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.properties_id_seq', 1, false);


--
-- Data for Name: registry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.registry (id, name, url, access_key, access_secret, insecure, creation_time, update_time, credential_type, type, description, health) FROM stdin;
\.


--
-- Data for Name: replication_execution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.replication_execution (id, policy_id, status, status_text, total, failed, succeed, in_progress, stopped, trigger, start_time, end_time) FROM stdin;
\.


--
-- Name: replication_execution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replication_execution_id_seq', 1, false);


--
-- Name: replication_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replication_job_id_seq', 1, false);


--
-- Data for Name: replication_policy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.replication_policy (id, name, dest_registry_id, enabled, description, deleted, trigger, filters, replicate_deletion, start_time, creation_time, update_time, creator, src_registry_id, dest_namespace, override) FROM stdin;
\.


--
-- Name: replication_policy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replication_policy_id_seq', 1, false);


--
-- Data for Name: replication_schedule_job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.replication_schedule_job (id, status, policy_id, job_id, creation_time, update_time) FROM stdin;
\.


--
-- Name: replication_target_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replication_target_id_seq', 1, false);


--
-- Data for Name: replication_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.replication_task (id, execution_id, resource_type, src_resource, dst_resource, operation, job_id, status, start_time, end_time) FROM stdin;
\.


--
-- Name: replication_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replication_task_id_seq', 1, false);


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository (repository_id, name, project_id, description, pull_count, star_count, creation_time, update_time) FROM stdin;
\.


--
-- Name: repository_repository_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.repository_repository_id_seq', 33, true);


--
-- Data for Name: robot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.robot (id, name, description, project_id, expiresat, disabled, creation_time, update_time) FROM stdin;
\.


--
-- Name: robot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.robot_id_seq', 1, false);


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (role_id, role_mask, role_code, name) FROM stdin;
1	0	MDRWS	projectAdmin
2	0	RWS	developer
3	0	RS	guest
4	0	DRWS	master
\.


--
-- Name: role_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_role_id_seq', 33, true);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, dirty) FROM stdin;
4	f
\.


--
-- Data for Name: user_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_group (id, group_name, group_type, ldap_group_dn, creation_time, update_time) FROM stdin;
\.


--
-- Name: user_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_group_id_seq', 1, false);


--
-- Name: access_log access_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_log
    ADD CONSTRAINT access_log_pkey PRIMARY KEY (log_id);


--
-- Name: access access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access
    ADD CONSTRAINT access_pkey PRIMARY KEY (access_id);


--
-- Name: admin_job admin_job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_job
    ADD CONSTRAINT admin_job_pkey PRIMARY KEY (id);


--
-- Name: clair_vuln_timestamp clair_vuln_timestamp_namespace_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clair_vuln_timestamp
    ADD CONSTRAINT clair_vuln_timestamp_namespace_key UNIQUE (namespace);


--
-- Name: clair_vuln_timestamp clair_vuln_timestamp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clair_vuln_timestamp
    ADD CONSTRAINT clair_vuln_timestamp_pkey PRIMARY KEY (id);


--
-- Name: harbor_label harbor_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_label
    ADD CONSTRAINT harbor_label_pkey PRIMARY KEY (id);


--
-- Name: harbor_resource_label harbor_resource_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_resource_label
    ADD CONSTRAINT harbor_resource_label_pkey PRIMARY KEY (id);


--
-- Name: harbor_user harbor_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_user
    ADD CONSTRAINT harbor_user_email_key UNIQUE (email);


--
-- Name: harbor_user harbor_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_user
    ADD CONSTRAINT harbor_user_pkey PRIMARY KEY (user_id);


--
-- Name: harbor_user harbor_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_user
    ADD CONSTRAINT harbor_user_username_key UNIQUE (username);


--
-- Name: img_scan_job img_scan_job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.img_scan_job
    ADD CONSTRAINT img_scan_job_pkey PRIMARY KEY (id);


--
-- Name: img_scan_overview img_scan_overview_image_digest_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.img_scan_overview
    ADD CONSTRAINT img_scan_overview_image_digest_key UNIQUE (image_digest);


--
-- Name: img_scan_overview img_scan_overview_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.img_scan_overview
    ADD CONSTRAINT img_scan_overview_pkey PRIMARY KEY (id);


--
-- Name: job_log job_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_log
    ADD CONSTRAINT job_log_pkey PRIMARY KEY (log_id);


--
-- Name: oidc_user oidc_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oidc_user
    ADD CONSTRAINT oidc_user_pkey PRIMARY KEY (id);


--
-- Name: oidc_user oidc_user_subiss_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oidc_user
    ADD CONSTRAINT oidc_user_subiss_key UNIQUE (subiss);


--
-- Name: project_member project_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member
    ADD CONSTRAINT project_member_pkey PRIMARY KEY (id);


--
-- Name: project_metadata project_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_metadata
    ADD CONSTRAINT project_metadata_pkey PRIMARY KEY (id);


--
-- Name: project project_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_name_key UNIQUE (name);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- Name: properties properties_k_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_k_key UNIQUE (k);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: replication_execution replication_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_execution
    ADD CONSTRAINT replication_execution_pkey PRIMARY KEY (id);


--
-- Name: replication_schedule_job replication_job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_schedule_job
    ADD CONSTRAINT replication_job_pkey PRIMARY KEY (id);


--
-- Name: replication_policy replication_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_policy
    ADD CONSTRAINT replication_policy_pkey PRIMARY KEY (id);


--
-- Name: registry replication_target_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registry
    ADD CONSTRAINT replication_target_pkey PRIMARY KEY (id);


--
-- Name: replication_task replication_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_task
    ADD CONSTRAINT replication_task_pkey PRIMARY KEY (id);


--
-- Name: repository repository_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository
    ADD CONSTRAINT repository_name_key UNIQUE (name);


--
-- Name: repository repository_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository
    ADD CONSTRAINT repository_pkey PRIMARY KEY (repository_id);


--
-- Name: robot robot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.robot
    ADD CONSTRAINT robot_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: harbor_label unique_label; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_label
    ADD CONSTRAINT unique_label UNIQUE (name, scope, project_id);


--
-- Name: harbor_resource_label unique_label_resource; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.harbor_resource_label
    ADD CONSTRAINT unique_label_resource UNIQUE (label_id, resource_id, resource_name, resource_type);


--
-- Name: replication_policy unique_policy_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replication_policy
    ADD CONSTRAINT unique_policy_name UNIQUE (name);


--
-- Name: project_member unique_project_entity_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member
    ADD CONSTRAINT unique_project_entity_type UNIQUE (project_id, entity_id, entity_type);


--
-- Name: project_metadata unique_project_id_and_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_metadata
    ADD CONSTRAINT unique_project_id_and_name UNIQUE (project_id, name);


--
-- Name: robot unique_robot; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.robot
    ADD CONSTRAINT unique_robot UNIQUE (name, project_id);


--
-- Name: registry unique_target_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registry
    ADD CONSTRAINT unique_target_name UNIQUE (name);


--
-- Name: user_group user_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT user_group_pkey PRIMARY KEY (id);


--
-- Name: admin_job_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_job_status ON public.admin_job USING btree (status);


--
-- Name: admin_job_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_job_uuid ON public.admin_job USING btree (job_uuid);


--
-- Name: execution_policy; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX execution_policy ON public.replication_execution USING btree (policy_id);


--
-- Name: idx_digest; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_digest ON public.img_scan_job USING btree (digest);


--
-- Name: idx_repository_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_repository_tag ON public.img_scan_job USING btree (repository, tag);


--
-- Name: idx_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_status ON public.img_scan_job USING btree (status);


--
-- Name: idx_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_uuid ON public.img_scan_job USING btree (job_uuid);


--
-- Name: job_log_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_log_uuid ON public.job_log USING btree (job_uuid);


--
-- Name: pid_optime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pid_optime ON public.access_log USING btree (project_id, op_time);


--
-- Name: task_execution; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_execution ON public.replication_task USING btree (execution_id);


--
-- Name: admin_job admin_job_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_job_update_time_at_modtime BEFORE UPDATE ON public.admin_job FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: harbor_label harbor_label_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER harbor_label_update_time_at_modtime BEFORE UPDATE ON public.harbor_label FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: harbor_resource_label harbor_resource_label_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER harbor_resource_label_update_time_at_modtime BEFORE UPDATE ON public.harbor_resource_label FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: harbor_user harbor_user_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER harbor_user_update_time_at_modtime BEFORE UPDATE ON public.harbor_user FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: img_scan_job img_scan_job_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER img_scan_job_update_time_at_modtime BEFORE UPDATE ON public.img_scan_job FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: img_scan_overview img_scan_overview_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER img_scan_overview_update_time_at_modtime BEFORE UPDATE ON public.img_scan_overview FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: oidc_user oidc_user_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oidc_user_update_time_at_modtime BEFORE UPDATE ON public.oidc_user FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: project_member project_member_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER project_member_update_time_at_modtime BEFORE UPDATE ON public.project_member FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: project_metadata project_metadata_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER project_metadata_update_time_at_modtime BEFORE UPDATE ON public.project_metadata FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: project project_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER project_update_time_at_modtime BEFORE UPDATE ON public.project FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: replication_policy replication_policy_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER replication_policy_update_time_at_modtime BEFORE UPDATE ON public.replication_policy FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: repository repository_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER repository_update_time_at_modtime BEFORE UPDATE ON public.repository FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: robot robot_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER robot_update_time_at_modtime BEFORE UPDATE ON public.robot FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: user_group user_group_update_time_at_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER user_group_update_time_at_modtime BEFORE UPDATE ON public.user_group FOR EACH ROW EXECUTE PROCEDURE public.update_update_time_at_column();


--
-- Name: oidc_user oidc_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oidc_user
    ADD CONSTRAINT oidc_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.harbor_user(user_id);


--
-- Name: project_metadata project_metadata_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_metadata
    ADD CONSTRAINT project_metadata_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(project_id);


--
-- Name: project project_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.harbor_user(user_id);


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

