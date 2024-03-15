--
-- PostgreSQL database dump
--

-- Dumped from database version 12.13 (Debian 12.13-1.pgdg110+1)
-- Dumped by pg_dump version 14.6 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: sentry_increment_project_counter(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sentry_increment_project_counter(project bigint, delta integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        declare
          new_val int;
        begin
          loop
            update sentry_projectcounter set value = value + delta
             where project_id = project
               returning value into new_val;
            if found then
              return new_val;
            end if;
            begin
              insert into sentry_projectcounter(project_id, value)
                   values (project, delta)
                returning value into new_val;
              return new_val;
            exception when unique_violation then
            end;
          end loop;
        end
        $$;


ALTER FUNCTION public.sentry_increment_project_counter(project bigint, delta integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_authenticator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_authenticator (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_used_at timestamp with time zone,
    type integer NOT NULL,
    config text NOT NULL,
    CONSTRAINT auth_authenticator_type_check CHECK ((type >= 0))
);


ALTER TABLE public.auth_authenticator OWNER TO postgres;

--
-- Name: auth_authenticator_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_authenticator_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_authenticator_id_seq OWNER TO postgres;

--
-- Name: auth_authenticator_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_authenticator_id_seq OWNED BY public.auth_authenticator.id;


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user (
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    id integer NOT NULL,
    username character varying(128) NOT NULL,
    first_name character varying(200) NOT NULL,
    email character varying(75) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    is_superuser boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    is_managed boolean NOT NULL,
    is_password_expired boolean NOT NULL,
    last_password_change timestamp with time zone,
    session_nonce character varying(12),
    last_active timestamp with time zone,
    flags bigint,
    is_sentry_app boolean
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    content_type_id integer,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.django_site OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_site_id_seq OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_site_id_seq OWNED BY public.django_site.id;


--
-- Name: jira_ac_tenant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jira_ac_tenant (
    id bigint NOT NULL,
    organization_id bigint,
    client_key character varying(50) NOT NULL,
    secret character varying(100) NOT NULL,
    base_url character varying(60) NOT NULL,
    public_key character varying(250) NOT NULL
);


ALTER TABLE public.jira_ac_tenant OWNER TO postgres;

--
-- Name: jira_ac_tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jira_ac_tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jira_ac_tenant_id_seq OWNER TO postgres;

--
-- Name: jira_ac_tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jira_ac_tenant_id_seq OWNED BY public.jira_ac_tenant.id;


--
-- Name: nodestore_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nodestore_node (
    id character varying(40) NOT NULL,
    data text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.nodestore_node OWNER TO postgres;

--
-- Name: sentry_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_activity (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint,
    type integer NOT NULL,
    ident character varying(64),
    user_id integer,
    datetime timestamp with time zone NOT NULL,
    data text,
    CONSTRAINT sentry_activity_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_activity OWNER TO postgres;

--
-- Name: sentry_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_activity_id_seq OWNER TO postgres;

--
-- Name: sentry_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_activity_id_seq OWNED BY public.sentry_activity.id;


--
-- Name: sentry_apiapplication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_apiapplication (
    id bigint NOT NULL,
    client_id character varying(64) NOT NULL,
    client_secret text NOT NULL,
    owner_id integer NOT NULL,
    name character varying(64) NOT NULL,
    status integer NOT NULL,
    allowed_origins text,
    redirect_uris text NOT NULL,
    homepage_url character varying(200),
    privacy_url character varying(200),
    terms_url character varying(200),
    date_added timestamp with time zone NOT NULL,
    CONSTRAINT sentry_apiapplication_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_apiapplication OWNER TO postgres;

--
-- Name: sentry_apiapplication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_apiapplication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_apiapplication_id_seq OWNER TO postgres;

--
-- Name: sentry_apiapplication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_apiapplication_id_seq OWNED BY public.sentry_apiapplication.id;


--
-- Name: sentry_apiauthorization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_apiauthorization (
    id bigint NOT NULL,
    application_id bigint,
    user_id integer NOT NULL,
    scopes bigint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    scope_list text[]
);


ALTER TABLE public.sentry_apiauthorization OWNER TO postgres;

--
-- Name: sentry_apiauthorization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_apiauthorization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_apiauthorization_id_seq OWNER TO postgres;

--
-- Name: sentry_apiauthorization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_apiauthorization_id_seq OWNED BY public.sentry_apiauthorization.id;


--
-- Name: sentry_apigrant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_apigrant (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    application_id bigint NOT NULL,
    code character varying(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    scopes bigint NOT NULL,
    scope_list text[]
);


ALTER TABLE public.sentry_apigrant OWNER TO postgres;

--
-- Name: sentry_apigrant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_apigrant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_apigrant_id_seq OWNER TO postgres;

--
-- Name: sentry_apigrant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_apigrant_id_seq OWNED BY public.sentry_apigrant.id;


--
-- Name: sentry_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_apikey (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    label character varying(64) NOT NULL,
    key character varying(32) NOT NULL,
    scopes bigint NOT NULL,
    status integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    allowed_origins text,
    scope_list text[],
    CONSTRAINT sentry_apikey_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_apikey OWNER TO postgres;

--
-- Name: sentry_apikey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_apikey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_apikey_id_seq OWNER TO postgres;

--
-- Name: sentry_apikey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_apikey_id_seq OWNED BY public.sentry_apikey.id;


--
-- Name: sentry_apitoken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_apitoken (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    token character varying(64) NOT NULL,
    scopes bigint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    application_id bigint,
    refresh_token character varying(64),
    expires_at timestamp with time zone,
    scope_list text[]
);


ALTER TABLE public.sentry_apitoken OWNER TO postgres;

--
-- Name: sentry_apitoken_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_apitoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_apitoken_id_seq OWNER TO postgres;

--
-- Name: sentry_apitoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_apitoken_id_seq OWNED BY public.sentry_apitoken.id;


--
-- Name: sentry_assistant_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_assistant_activity (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    guide_id integer NOT NULL,
    viewed_ts timestamp with time zone,
    dismissed_ts timestamp with time zone,
    useful boolean,
    CONSTRAINT sentry_assistant_activity_guide_id_check CHECK ((guide_id >= 0))
);


ALTER TABLE public.sentry_assistant_activity OWNER TO postgres;

--
-- Name: sentry_assistant_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_assistant_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_assistant_activity_id_seq OWNER TO postgres;

--
-- Name: sentry_assistant_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_assistant_activity_id_seq OWNED BY public.sentry_assistant_activity.id;


--
-- Name: sentry_auditlogentry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_auditlogentry (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    actor_id integer,
    target_object integer,
    target_user_id integer,
    event integer NOT NULL,
    data text NOT NULL,
    datetime timestamp with time zone NOT NULL,
    ip_address inet,
    actor_label character varying(64),
    actor_key_id bigint,
    CONSTRAINT sentry_auditlogentry_event_check CHECK ((event >= 0)),
    CONSTRAINT sentry_auditlogentry_target_object_check CHECK ((target_object >= 0))
);


ALTER TABLE public.sentry_auditlogentry OWNER TO postgres;

--
-- Name: sentry_auditlogentry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_auditlogentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_auditlogentry_id_seq OWNER TO postgres;

--
-- Name: sentry_auditlogentry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_auditlogentry_id_seq OWNED BY public.sentry_auditlogentry.id;


--
-- Name: sentry_authidentity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_authidentity (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    auth_provider_id bigint NOT NULL,
    ident character varying(128) NOT NULL,
    data text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    last_verified timestamp with time zone NOT NULL,
    last_synced timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_authidentity OWNER TO postgres;

--
-- Name: sentry_authidentity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_authidentity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_authidentity_id_seq OWNER TO postgres;

--
-- Name: sentry_authidentity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_authidentity_id_seq OWNED BY public.sentry_authidentity.id;


--
-- Name: sentry_authprovider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_authprovider (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    provider character varying(128) NOT NULL,
    config text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    sync_time integer,
    last_sync timestamp with time zone,
    default_role integer NOT NULL,
    default_global_access boolean NOT NULL,
    flags bigint NOT NULL,
    CONSTRAINT sentry_authprovider_default_role_check CHECK ((default_role >= 0)),
    CONSTRAINT sentry_authprovider_sync_time_check CHECK ((sync_time >= 0))
);


ALTER TABLE public.sentry_authprovider OWNER TO postgres;

--
-- Name: sentry_authprovider_default_teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_authprovider_default_teams (
    id integer NOT NULL,
    authprovider_id bigint NOT NULL,
    team_id bigint NOT NULL
);


ALTER TABLE public.sentry_authprovider_default_teams OWNER TO postgres;

--
-- Name: sentry_authprovider_default_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_authprovider_default_teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_authprovider_default_teams_id_seq OWNER TO postgres;

--
-- Name: sentry_authprovider_default_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_authprovider_default_teams_id_seq OWNED BY public.sentry_authprovider_default_teams.id;


--
-- Name: sentry_authprovider_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_authprovider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_authprovider_id_seq OWNER TO postgres;

--
-- Name: sentry_authprovider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_authprovider_id_seq OWNED BY public.sentry_authprovider.id;


--
-- Name: sentry_broadcast; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_broadcast (
    id bigint NOT NULL,
    message character varying(256) NOT NULL,
    link character varying(200),
    is_active boolean NOT NULL,
    date_added timestamp with time zone NOT NULL,
    title character varying(32) NOT NULL,
    upstream_id character varying(32),
    date_expires timestamp with time zone
);


ALTER TABLE public.sentry_broadcast OWNER TO postgres;

--
-- Name: sentry_broadcast_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_broadcast_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_broadcast_id_seq OWNER TO postgres;

--
-- Name: sentry_broadcast_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_broadcast_id_seq OWNED BY public.sentry_broadcast.id;


--
-- Name: sentry_broadcastseen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_broadcastseen (
    id bigint NOT NULL,
    broadcast_id bigint NOT NULL,
    user_id integer NOT NULL,
    date_seen timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_broadcastseen OWNER TO postgres;

--
-- Name: sentry_broadcastseen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_broadcastseen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_broadcastseen_id_seq OWNER TO postgres;

--
-- Name: sentry_broadcastseen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_broadcastseen_id_seq OWNED BY public.sentry_broadcastseen.id;


--
-- Name: sentry_commit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_commit (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    author_id bigint,
    message text,
    CONSTRAINT sentry_commit_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_commit_repository_id_check CHECK ((repository_id >= 0))
);


ALTER TABLE public.sentry_commit OWNER TO postgres;

--
-- Name: sentry_commit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_commit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_commit_id_seq OWNER TO postgres;

--
-- Name: sentry_commit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_commit_id_seq OWNED BY public.sentry_commit.id;


--
-- Name: sentry_commitauthor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_commitauthor (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    name character varying(128),
    email character varying(75) NOT NULL,
    external_id character varying(164),
    CONSTRAINT sentry_commitauthor_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_commitauthor OWNER TO postgres;

--
-- Name: sentry_commitauthor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_commitauthor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_commitauthor_id_seq OWNER TO postgres;

--
-- Name: sentry_commitauthor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_commitauthor_id_seq OWNED BY public.sentry_commitauthor.id;


--
-- Name: sentry_commitfilechange; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_commitfilechange (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    commit_id bigint NOT NULL,
    filename text NOT NULL,
    type character varying(1) NOT NULL,
    CONSTRAINT sentry_commitfilechange_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_commitfilechange OWNER TO postgres;

--
-- Name: sentry_commitfilechange_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_commitfilechange_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_commitfilechange_id_seq OWNER TO postgres;

--
-- Name: sentry_commitfilechange_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_commitfilechange_id_seq OWNED BY public.sentry_commitfilechange.id;


--
-- Name: sentry_dashboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_dashboard (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    created_by_id integer NOT NULL,
    organization_id bigint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    status integer NOT NULL,
    CONSTRAINT sentry_dashboard_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_dashboard OWNER TO postgres;

--
-- Name: sentry_dashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_dashboard_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_dashboard_id_seq OWNER TO postgres;

--
-- Name: sentry_dashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_dashboard_id_seq OWNED BY public.sentry_dashboard.id;


--
-- Name: sentry_deletedorganization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_deletedorganization (
    id bigint NOT NULL,
    actor_label character varying(64),
    actor_id bigint,
    actor_key character varying(32),
    ip_address inet,
    date_deleted timestamp with time zone NOT NULL,
    date_created timestamp with time zone,
    reason text,
    name character varying(64),
    slug character varying(50)
);


ALTER TABLE public.sentry_deletedorganization OWNER TO postgres;

--
-- Name: sentry_deletedorganization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_deletedorganization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_deletedorganization_id_seq OWNER TO postgres;

--
-- Name: sentry_deletedorganization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_deletedorganization_id_seq OWNED BY public.sentry_deletedorganization.id;


--
-- Name: sentry_deletedproject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_deletedproject (
    id bigint NOT NULL,
    actor_label character varying(64),
    actor_id bigint,
    actor_key character varying(32),
    ip_address inet,
    date_deleted timestamp with time zone NOT NULL,
    date_created timestamp with time zone,
    reason text,
    slug character varying(50),
    name character varying(200),
    organization_id bigint,
    organization_name character varying(64),
    organization_slug character varying(50),
    platform character varying(64)
);


ALTER TABLE public.sentry_deletedproject OWNER TO postgres;

--
-- Name: sentry_deletedproject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_deletedproject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_deletedproject_id_seq OWNER TO postgres;

--
-- Name: sentry_deletedproject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_deletedproject_id_seq OWNED BY public.sentry_deletedproject.id;


--
-- Name: sentry_deletedteam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_deletedteam (
    id bigint NOT NULL,
    actor_label character varying(64),
    actor_id bigint,
    actor_key character varying(32),
    ip_address inet,
    date_deleted timestamp with time zone NOT NULL,
    date_created timestamp with time zone,
    reason text,
    name character varying(64),
    slug character varying(50),
    organization_id bigint,
    organization_name character varying(64),
    organization_slug character varying(50)
);


ALTER TABLE public.sentry_deletedteam OWNER TO postgres;

--
-- Name: sentry_deletedteam_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_deletedteam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_deletedteam_id_seq OWNER TO postgres;

--
-- Name: sentry_deletedteam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_deletedteam_id_seq OWNED BY public.sentry_deletedteam.id;


--
-- Name: sentry_deploy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_deploy (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    release_id bigint NOT NULL,
    environment_id integer NOT NULL,
    date_finished timestamp with time zone NOT NULL,
    date_started timestamp with time zone,
    name character varying(64),
    url character varying(200),
    notified boolean,
    CONSTRAINT sentry_deploy_environment_id_check CHECK ((environment_id >= 0)),
    CONSTRAINT sentry_deploy_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_deploy OWNER TO postgres;

--
-- Name: sentry_deploy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_deploy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_deploy_id_seq OWNER TO postgres;

--
-- Name: sentry_deploy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_deploy_id_seq OWNED BY public.sentry_deploy.id;


--
-- Name: sentry_discoversavedquery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_discoversavedquery (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    query text NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL,
    created_by_id integer
);


ALTER TABLE public.sentry_discoversavedquery OWNER TO postgres;

--
-- Name: sentry_discoversavedquery_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_discoversavedquery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_discoversavedquery_id_seq OWNER TO postgres;

--
-- Name: sentry_discoversavedquery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_discoversavedquery_id_seq OWNED BY public.sentry_discoversavedquery.id;


--
-- Name: sentry_discoversavedqueryproject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_discoversavedqueryproject (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    discover_saved_query_id bigint NOT NULL
);


ALTER TABLE public.sentry_discoversavedqueryproject OWNER TO postgres;

--
-- Name: sentry_discoversavedqueryproject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_discoversavedqueryproject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_discoversavedqueryproject_id_seq OWNER TO postgres;

--
-- Name: sentry_discoversavedqueryproject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_discoversavedqueryproject_id_seq OWNED BY public.sentry_discoversavedqueryproject.id;


--
-- Name: sentry_distribution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_distribution (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    release_id bigint NOT NULL,
    name character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    CONSTRAINT sentry_distribution_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_distribution OWNER TO postgres;

--
-- Name: sentry_distribution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_distribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_distribution_id_seq OWNER TO postgres;

--
-- Name: sentry_distribution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_distribution_id_seq OWNED BY public.sentry_distribution.id;


--
-- Name: sentry_email; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_email (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_email OWNER TO postgres;

--
-- Name: sentry_email_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_email_id_seq OWNER TO postgres;

--
-- Name: sentry_email_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_email_id_seq OWNED BY public.sentry_email.id;


--
-- Name: sentry_environment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_environment (
    id bigint NOT NULL,
    project_id integer,
    name character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    organization_id integer NOT NULL,
    CONSTRAINT ck_organization_id_pstv_217ef821157f703 CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_environment_project_id_check CHECK ((project_id >= 0))
);


ALTER TABLE public.sentry_environment OWNER TO postgres;

--
-- Name: sentry_environment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_environment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_environment_id_seq OWNER TO postgres;

--
-- Name: sentry_environment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_environment_id_seq OWNED BY public.sentry_environment.id;


--
-- Name: sentry_environmentproject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_environmentproject (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    environment_id bigint NOT NULL,
    is_hidden boolean
);


ALTER TABLE public.sentry_environmentproject OWNER TO postgres;

--
-- Name: sentry_environmentproject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_environmentproject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_environmentproject_id_seq OWNER TO postgres;

--
-- Name: sentry_environmentproject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_environmentproject_id_seq OWNED BY public.sentry_environmentproject.id;


--
-- Name: sentry_environmentrelease; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_environmentrelease (
    id bigint NOT NULL,
    project_id integer,
    release_id integer NOT NULL,
    environment_id integer NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    organization_id integer NOT NULL,
    CONSTRAINT ck_organization_id_pstv_4f21eb33d1f59511 CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_environmentrelease_environment_id_check CHECK ((environment_id >= 0)),
    CONSTRAINT sentry_environmentrelease_project_id_check CHECK ((project_id >= 0)),
    CONSTRAINT sentry_environmentrelease_release_id_check CHECK ((release_id >= 0))
);


ALTER TABLE public.sentry_environmentrelease OWNER TO postgres;

--
-- Name: sentry_environmentrelease_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_environmentrelease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_environmentrelease_id_seq OWNER TO postgres;

--
-- Name: sentry_environmentrelease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_environmentrelease_id_seq OWNED BY public.sentry_environmentrelease.id;


--
-- Name: sentry_eventattachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_eventattachment (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint,
    event_id character varying(32) NOT NULL,
    file_id bigint NOT NULL,
    name text NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_eventattachment OWNER TO postgres;

--
-- Name: sentry_eventattachment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_eventattachment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_eventattachment_id_seq OWNER TO postgres;

--
-- Name: sentry_eventattachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_eventattachment_id_seq OWNED BY public.sentry_eventattachment.id;


--
-- Name: sentry_eventmapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_eventmapping (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    event_id character varying(32) NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_eventmapping OWNER TO postgres;

--
-- Name: sentry_eventmapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_eventmapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_eventmapping_id_seq OWNER TO postgres;

--
-- Name: sentry_eventmapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_eventmapping_id_seq OWNED BY public.sentry_eventmapping.id;


--
-- Name: sentry_eventprocessingissue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_eventprocessingissue (
    id bigint NOT NULL,
    raw_event_id bigint NOT NULL,
    processing_issue_id bigint NOT NULL
);


ALTER TABLE public.sentry_eventprocessingissue OWNER TO postgres;

--
-- Name: sentry_eventprocessingissue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_eventprocessingissue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_eventprocessingissue_id_seq OWNER TO postgres;

--
-- Name: sentry_eventprocessingissue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_eventprocessingissue_id_seq OWNED BY public.sentry_eventprocessingissue.id;


--
-- Name: sentry_eventtag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_eventtag (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    event_id bigint NOT NULL,
    key_id bigint NOT NULL,
    value_id bigint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    group_id bigint
);


ALTER TABLE public.sentry_eventtag OWNER TO postgres;

--
-- Name: sentry_eventtag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_eventtag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_eventtag_id_seq OWNER TO postgres;

--
-- Name: sentry_eventtag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_eventtag_id_seq OWNED BY public.sentry_eventtag.id;


--
-- Name: sentry_eventuser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_eventuser (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    ident character varying(128),
    email character varying(75),
    username character varying(128),
    ip_address inet,
    date_added timestamp with time zone NOT NULL,
    hash character varying(32) NOT NULL,
    name character varying(128)
);


ALTER TABLE public.sentry_eventuser OWNER TO postgres;

--
-- Name: sentry_eventuser_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_eventuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_eventuser_id_seq OWNER TO postgres;

--
-- Name: sentry_eventuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_eventuser_id_seq OWNED BY public.sentry_eventuser.id;


--
-- Name: sentry_externalissue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_externalissue (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    integration_id integer NOT NULL,
    key character varying(128) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    title text,
    description text,
    metadata text,
    CONSTRAINT sentry_externalissue_integration_id_check CHECK ((integration_id >= 0)),
    CONSTRAINT sentry_externalissue_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_externalissue OWNER TO postgres;

--
-- Name: sentry_externalissue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_externalissue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_externalissue_id_seq OWNER TO postgres;

--
-- Name: sentry_externalissue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_externalissue_id_seq OWNED BY public.sentry_externalissue.id;


--
-- Name: sentry_featureadoption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_featureadoption (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    feature_id integer NOT NULL,
    date_completed timestamp with time zone NOT NULL,
    complete boolean NOT NULL,
    applicable boolean NOT NULL,
    data text NOT NULL,
    CONSTRAINT sentry_featureadoption_feature_id_check CHECK ((feature_id >= 0))
);


ALTER TABLE public.sentry_featureadoption OWNER TO postgres;

--
-- Name: sentry_featureadoption_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_featureadoption_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_featureadoption_id_seq OWNER TO postgres;

--
-- Name: sentry_featureadoption_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_featureadoption_id_seq OWNED BY public.sentry_featureadoption.id;


--
-- Name: sentry_file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_file (
    id bigint NOT NULL,
    name text NOT NULL,
    path text,
    type character varying(64) NOT NULL,
    size integer,
    "timestamp" timestamp with time zone NOT NULL,
    checksum character varying(40),
    headers text NOT NULL,
    blob_id bigint,
    CONSTRAINT sentry_file_size_check CHECK ((size >= 0))
);


ALTER TABLE public.sentry_file OWNER TO postgres;

--
-- Name: sentry_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_file_id_seq OWNER TO postgres;

--
-- Name: sentry_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_file_id_seq OWNED BY public.sentry_file.id;


--
-- Name: sentry_fileblob; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_fileblob (
    id bigint NOT NULL,
    path text,
    size integer,
    checksum character varying(40) NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    CONSTRAINT sentry_fileblob_size_check CHECK ((size >= 0))
);


ALTER TABLE public.sentry_fileblob OWNER TO postgres;

--
-- Name: sentry_fileblob_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_fileblob_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_fileblob_id_seq OWNER TO postgres;

--
-- Name: sentry_fileblob_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_fileblob_id_seq OWNED BY public.sentry_fileblob.id;


--
-- Name: sentry_fileblobindex; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_fileblobindex (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    "offset" integer NOT NULL,
    CONSTRAINT sentry_fileblobindex_offset_check CHECK (("offset" >= 0))
);


ALTER TABLE public.sentry_fileblobindex OWNER TO postgres;

--
-- Name: sentry_fileblobindex_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_fileblobindex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_fileblobindex_id_seq OWNER TO postgres;

--
-- Name: sentry_fileblobindex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_fileblobindex_id_seq OWNED BY public.sentry_fileblobindex.id;


--
-- Name: sentry_fileblobowner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_fileblobowner (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    organization_id bigint NOT NULL
);


ALTER TABLE public.sentry_fileblobowner OWNER TO postgres;

--
-- Name: sentry_fileblobowner_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_fileblobowner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_fileblobowner_id_seq OWNER TO postgres;

--
-- Name: sentry_fileblobowner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_fileblobowner_id_seq OWNED BY public.sentry_fileblobowner.id;


--
-- Name: sentry_filterkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_filterkey (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    key character varying(32) NOT NULL,
    values_seen integer NOT NULL,
    label character varying(64),
    status integer NOT NULL,
    CONSTRAINT ck_status_pstv_56aaa5973127b013 CHECK ((status >= 0)),
    CONSTRAINT ck_values_seen_pstv_12eab0d3ff94a35c CHECK ((values_seen >= 0)),
    CONSTRAINT sentry_filterkey_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_filterkey_values_seen_check CHECK ((values_seen >= 0))
);


ALTER TABLE public.sentry_filterkey OWNER TO postgres;

--
-- Name: sentry_filterkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_filterkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_filterkey_id_seq OWNER TO postgres;

--
-- Name: sentry_filterkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_filterkey_id_seq OWNED BY public.sentry_filterkey.id;


--
-- Name: sentry_filtervalue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_filtervalue (
    id bigint NOT NULL,
    key character varying(32) NOT NULL,
    value character varying(200) NOT NULL,
    project_id bigint,
    times_seen integer NOT NULL,
    last_seen timestamp with time zone,
    first_seen timestamp with time zone,
    data text,
    CONSTRAINT ck_times_seen_pstv_10c4372f28cef967 CHECK ((times_seen >= 0)),
    CONSTRAINT sentry_filtervalue_times_seen_check CHECK ((times_seen >= 0))
);


ALTER TABLE public.sentry_filtervalue OWNER TO postgres;

--
-- Name: sentry_filtervalue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_filtervalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_filtervalue_id_seq OWNER TO postgres;

--
-- Name: sentry_filtervalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_filtervalue_id_seq OWNED BY public.sentry_filtervalue.id;


--
-- Name: sentry_groupasignee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupasignee (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id integer,
    date_added timestamp with time zone NOT NULL,
    team_id bigint,
    CONSTRAINT require_team_or_user_but_not_both CHECK (((NOT ((team_id IS NOT NULL) AND (user_id IS NOT NULL))) AND (NOT ((team_id IS NULL) AND (user_id IS NULL)))))
);


ALTER TABLE public.sentry_groupasignee OWNER TO postgres;

--
-- Name: sentry_groupasignee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupasignee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupasignee_id_seq OWNER TO postgres;

--
-- Name: sentry_groupasignee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupasignee_id_seq OWNED BY public.sentry_groupasignee.id;


--
-- Name: sentry_groupbookmark; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupbookmark (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id integer NOT NULL,
    date_added timestamp with time zone
);


ALTER TABLE public.sentry_groupbookmark OWNER TO postgres;

--
-- Name: sentry_groupbookmark_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupbookmark_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupbookmark_id_seq OWNER TO postgres;

--
-- Name: sentry_groupbookmark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupbookmark_id_seq OWNED BY public.sentry_groupbookmark.id;


--
-- Name: sentry_groupcommitresolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupcommitresolution (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    commit_id integer NOT NULL,
    datetime timestamp with time zone NOT NULL,
    CONSTRAINT sentry_groupcommitresolution_commit_id_check CHECK ((commit_id >= 0)),
    CONSTRAINT sentry_groupcommitresolution_group_id_check CHECK ((group_id >= 0))
);


ALTER TABLE public.sentry_groupcommitresolution OWNER TO postgres;

--
-- Name: sentry_groupcommitresolution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupcommitresolution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupcommitresolution_id_seq OWNER TO postgres;

--
-- Name: sentry_groupcommitresolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupcommitresolution_id_seq OWNED BY public.sentry_groupcommitresolution.id;


--
-- Name: sentry_groupedmessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupedmessage (
    id bigint NOT NULL,
    logger character varying(64) NOT NULL,
    level integer NOT NULL,
    message text NOT NULL,
    view character varying(200),
    status integer NOT NULL,
    times_seen integer NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    data text,
    score integer NOT NULL,
    project_id bigint,
    time_spent_total integer NOT NULL,
    time_spent_count integer NOT NULL,
    resolved_at timestamp with time zone,
    active_at timestamp with time zone,
    is_public boolean,
    platform character varying(64),
    num_comments integer,
    first_release_id bigint,
    short_id bigint,
    CONSTRAINT ck_num_comments_pstv_44851d4d5d739eab CHECK ((num_comments >= 0)),
    CONSTRAINT sentry_groupedmessage_level_check CHECK ((level >= 0)),
    CONSTRAINT sentry_groupedmessage_num_comments_check CHECK ((num_comments >= 0)),
    CONSTRAINT sentry_groupedmessage_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_groupedmessage_times_seen_check CHECK ((times_seen >= 0))
);


ALTER TABLE public.sentry_groupedmessage OWNER TO postgres;

--
-- Name: sentry_groupedmessage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupedmessage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupedmessage_id_seq OWNER TO postgres;

--
-- Name: sentry_groupedmessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupedmessage_id_seq OWNED BY public.sentry_groupedmessage.id;


--
-- Name: sentry_groupemailthread; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupemailthread (
    id bigint NOT NULL,
    email character varying(75) NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    msgid character varying(100) NOT NULL,
    date timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_groupemailthread OWNER TO postgres;

--
-- Name: sentry_groupemailthread_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupemailthread_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupemailthread_id_seq OWNER TO postgres;

--
-- Name: sentry_groupemailthread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupemailthread_id_seq OWNED BY public.sentry_groupemailthread.id;


--
-- Name: sentry_groupenvironment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupenvironment (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    environment_id integer NOT NULL,
    first_release_id integer,
    first_seen timestamp with time zone,
    CONSTRAINT ck_first_release_id_pstv_7ff793b9446dd7b CHECK ((first_release_id >= 0)),
    CONSTRAINT sentry_groupenvironment_environment_id_check CHECK ((environment_id >= 0)),
    CONSTRAINT sentry_groupenvironment_first_release_id_check CHECK ((first_release_id >= 0)),
    CONSTRAINT sentry_groupenvironment_group_id_check CHECK ((group_id >= 0))
);


ALTER TABLE public.sentry_groupenvironment OWNER TO postgres;

--
-- Name: sentry_groupenvironment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupenvironment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupenvironment_id_seq OWNER TO postgres;

--
-- Name: sentry_groupenvironment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupenvironment_id_seq OWNED BY public.sentry_groupenvironment.id;


--
-- Name: sentry_grouphash; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouphash (
    id bigint NOT NULL,
    project_id bigint,
    hash character varying(32) NOT NULL,
    group_id bigint,
    state integer,
    group_tombstone_id integer,
    CONSTRAINT ck_group_tombstone_id_pstv_17e9b9f9962c3c62 CHECK ((group_tombstone_id >= 0)),
    CONSTRAINT ck_state_pstv_556c62431651a0b1 CHECK ((state >= 0)),
    CONSTRAINT sentry_grouphash_group_tombstone_id_check CHECK ((group_tombstone_id >= 0)),
    CONSTRAINT sentry_grouphash_state_check CHECK ((state >= 0))
);


ALTER TABLE public.sentry_grouphash OWNER TO postgres;

--
-- Name: sentry_grouphash_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouphash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouphash_id_seq OWNER TO postgres;

--
-- Name: sentry_grouphash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouphash_id_seq OWNED BY public.sentry_grouphash.id;


--
-- Name: sentry_grouplink; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouplink (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    project_id bigint NOT NULL,
    linked_type integer NOT NULL,
    linked_id bigint NOT NULL,
    relationship integer NOT NULL,
    data text NOT NULL,
    datetime timestamp with time zone NOT NULL,
    CONSTRAINT sentry_grouplink_linked_type_check CHECK ((linked_type >= 0)),
    CONSTRAINT sentry_grouplink_relationship_check CHECK ((relationship >= 0))
);


ALTER TABLE public.sentry_grouplink OWNER TO postgres;

--
-- Name: sentry_grouplink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouplink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouplink_id_seq OWNER TO postgres;

--
-- Name: sentry_grouplink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouplink_id_seq OWNED BY public.sentry_grouplink.id;


--
-- Name: sentry_groupmeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupmeta (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    key character varying(64) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.sentry_groupmeta OWNER TO postgres;

--
-- Name: sentry_groupmeta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupmeta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupmeta_id_seq OWNER TO postgres;

--
-- Name: sentry_groupmeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupmeta_id_seq OWNED BY public.sentry_groupmeta.id;


--
-- Name: sentry_groupredirect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupredirect (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    previous_group_id bigint NOT NULL
);


ALTER TABLE public.sentry_groupredirect OWNER TO postgres;

--
-- Name: sentry_groupredirect_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupredirect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupredirect_id_seq OWNER TO postgres;

--
-- Name: sentry_groupredirect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupredirect_id_seq OWNED BY public.sentry_groupredirect.id;


--
-- Name: sentry_grouprelease; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouprelease (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    group_id integer NOT NULL,
    release_id integer NOT NULL,
    environment character varying(64) NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    CONSTRAINT sentry_grouprelease_group_id_check CHECK ((group_id >= 0)),
    CONSTRAINT sentry_grouprelease_project_id_check CHECK ((project_id >= 0)),
    CONSTRAINT sentry_grouprelease_release_id_check CHECK ((release_id >= 0))
);


ALTER TABLE public.sentry_grouprelease OWNER TO postgres;

--
-- Name: sentry_grouprelease_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouprelease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouprelease_id_seq OWNER TO postgres;

--
-- Name: sentry_grouprelease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouprelease_id_seq OWNED BY public.sentry_grouprelease.id;


--
-- Name: sentry_groupresolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupresolution (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    release_id bigint NOT NULL,
    datetime timestamp with time zone NOT NULL,
    status integer NOT NULL,
    type integer,
    actor_id integer,
    CONSTRAINT ck_actor_id_pstv_750a8dad4187faba CHECK ((actor_id >= 0)),
    CONSTRAINT ck_status_pstv_375a4efcf0df73b9 CHECK ((status >= 0)),
    CONSTRAINT ck_type_pstv_15c3a9fd0180fff9 CHECK ((type >= 0)),
    CONSTRAINT sentry_groupresolution_actor_id_check CHECK ((actor_id >= 0)),
    CONSTRAINT sentry_groupresolution_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_groupresolution_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_groupresolution OWNER TO postgres;

--
-- Name: sentry_groupresolution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupresolution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupresolution_id_seq OWNER TO postgres;

--
-- Name: sentry_groupresolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupresolution_id_seq OWNED BY public.sentry_groupresolution.id;


--
-- Name: sentry_grouprulestatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouprulestatus (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    rule_id bigint NOT NULL,
    group_id bigint NOT NULL,
    status smallint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    last_active timestamp with time zone,
    CONSTRAINT sentry_grouprulestatus_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_grouprulestatus OWNER TO postgres;

--
-- Name: sentry_grouprulestatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouprulestatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouprulestatus_id_seq OWNER TO postgres;

--
-- Name: sentry_grouprulestatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouprulestatus_id_seq OWNED BY public.sentry_grouprulestatus.id;


--
-- Name: sentry_groupseen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupseen (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id integer NOT NULL,
    last_seen timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_groupseen OWNER TO postgres;

--
-- Name: sentry_groupseen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupseen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupseen_id_seq OWNER TO postgres;

--
-- Name: sentry_groupseen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupseen_id_seq OWNED BY public.sentry_groupseen.id;


--
-- Name: sentry_groupshare; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupshare (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    uuid character varying(32) NOT NULL,
    user_id integer,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_groupshare OWNER TO postgres;

--
-- Name: sentry_groupshare_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupshare_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupshare_id_seq OWNER TO postgres;

--
-- Name: sentry_groupshare_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupshare_id_seq OWNED BY public.sentry_groupshare.id;


--
-- Name: sentry_groupsnooze; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupsnooze (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    until timestamp with time zone,
    count integer,
    "window" integer,
    user_count integer,
    user_window integer,
    state text,
    actor_id integer,
    CONSTRAINT ck_actor_id_pstv_1174f21750349df2 CHECK ((actor_id >= 0)),
    CONSTRAINT ck_count_pstv_2e729d18cc059d41 CHECK ((count >= 0)),
    CONSTRAINT ck_user_count_pstv_26e6359669512ec8 CHECK ((user_count >= 0)),
    CONSTRAINT ck_user_window_pstv_5621099b76ac766a CHECK ((user_window >= 0)),
    CONSTRAINT ck_window_pstv_2569b2f0095a6e41 CHECK (("window" >= 0)),
    CONSTRAINT sentry_groupsnooze_actor_id_check CHECK ((actor_id >= 0)),
    CONSTRAINT sentry_groupsnooze_count_check CHECK ((count >= 0)),
    CONSTRAINT sentry_groupsnooze_user_count_check CHECK ((user_count >= 0)),
    CONSTRAINT sentry_groupsnooze_user_window_check CHECK ((user_window >= 0)),
    CONSTRAINT sentry_groupsnooze_window_check CHECK (("window" >= 0))
);


ALTER TABLE public.sentry_groupsnooze OWNER TO postgres;

--
-- Name: sentry_groupsnooze_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupsnooze_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupsnooze_id_seq OWNER TO postgres;

--
-- Name: sentry_groupsnooze_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupsnooze_id_seq OWNED BY public.sentry_groupsnooze.id;


--
-- Name: sentry_groupsubscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_groupsubscription (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id integer NOT NULL,
    is_active boolean NOT NULL,
    reason integer NOT NULL,
    date_added timestamp with time zone,
    CONSTRAINT sentry_groupsubscription_reason_check CHECK ((reason >= 0))
);


ALTER TABLE public.sentry_groupsubscription OWNER TO postgres;

--
-- Name: sentry_groupsubscription_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_groupsubscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_groupsubscription_id_seq OWNER TO postgres;

--
-- Name: sentry_groupsubscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_groupsubscription_id_seq OWNED BY public.sentry_groupsubscription.id;


--
-- Name: sentry_grouptagkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouptagkey (
    id bigint NOT NULL,
    project_id bigint,
    group_id bigint NOT NULL,
    key character varying(32) NOT NULL,
    values_seen integer NOT NULL,
    CONSTRAINT sentry_grouptagkey_values_seen_check CHECK ((values_seen >= 0))
);


ALTER TABLE public.sentry_grouptagkey OWNER TO postgres;

--
-- Name: sentry_grouptagkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouptagkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouptagkey_id_seq OWNER TO postgres;

--
-- Name: sentry_grouptagkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouptagkey_id_seq OWNED BY public.sentry_grouptagkey.id;


--
-- Name: sentry_grouptombstone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_grouptombstone (
    id bigint NOT NULL,
    previous_group_id integer NOT NULL,
    project_id bigint NOT NULL,
    level integer NOT NULL,
    message text NOT NULL,
    culprit character varying(200),
    data text,
    actor_id integer,
    CONSTRAINT sentry_grouptombstone_actor_id_check CHECK ((actor_id >= 0)),
    CONSTRAINT sentry_grouptombstone_level_check CHECK ((level >= 0)),
    CONSTRAINT sentry_grouptombstone_previous_group_id_check CHECK ((previous_group_id >= 0))
);


ALTER TABLE public.sentry_grouptombstone OWNER TO postgres;

--
-- Name: sentry_grouptombstone_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_grouptombstone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_grouptombstone_id_seq OWNER TO postgres;

--
-- Name: sentry_grouptombstone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_grouptombstone_id_seq OWNED BY public.sentry_grouptombstone.id;


--
-- Name: sentry_hipchat_ac_tenant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_hipchat_ac_tenant (
    id character varying(40) NOT NULL,
    room_id character varying(40) NOT NULL,
    room_name character varying(200),
    room_owner_id character varying(40),
    room_owner_name character varying(200),
    secret character varying(120) NOT NULL,
    homepage character varying(250) NOT NULL,
    token_url character varying(250) NOT NULL,
    capabilities_url character varying(250) NOT NULL,
    api_base_url character varying(250) NOT NULL,
    installed_from character varying(250) NOT NULL,
    auth_user_id integer
);


ALTER TABLE public.sentry_hipchat_ac_tenant OWNER TO postgres;

--
-- Name: sentry_hipchat_ac_tenant_organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_hipchat_ac_tenant_organizations (
    id integer NOT NULL,
    tenant_id character varying(40) NOT NULL,
    organization_id bigint NOT NULL
);


ALTER TABLE public.sentry_hipchat_ac_tenant_organizations OWNER TO postgres;

--
-- Name: sentry_hipchat_ac_tenant_organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_hipchat_ac_tenant_organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_hipchat_ac_tenant_organizations_id_seq OWNER TO postgres;

--
-- Name: sentry_hipchat_ac_tenant_organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_hipchat_ac_tenant_organizations_id_seq OWNED BY public.sentry_hipchat_ac_tenant_organizations.id;


--
-- Name: sentry_hipchat_ac_tenant_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_hipchat_ac_tenant_projects (
    id integer NOT NULL,
    tenant_id character varying(40) NOT NULL,
    project_id bigint NOT NULL
);


ALTER TABLE public.sentry_hipchat_ac_tenant_projects OWNER TO postgres;

--
-- Name: sentry_hipchat_ac_tenant_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_hipchat_ac_tenant_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_hipchat_ac_tenant_projects_id_seq OWNER TO postgres;

--
-- Name: sentry_hipchat_ac_tenant_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_hipchat_ac_tenant_projects_id_seq OWNED BY public.sentry_hipchat_ac_tenant_projects.id;


--
-- Name: sentry_identity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_identity (
    id bigint NOT NULL,
    idp_id bigint NOT NULL,
    user_id integer NOT NULL,
    external_id character varying(64) NOT NULL,
    data text NOT NULL,
    status integer NOT NULL,
    scopes text[],
    date_verified timestamp with time zone NOT NULL,
    date_added timestamp with time zone NOT NULL,
    CONSTRAINT sentry_identity_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_identity OWNER TO postgres;

--
-- Name: sentry_identity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_identity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_identity_id_seq OWNER TO postgres;

--
-- Name: sentry_identity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_identity_id_seq OWNED BY public.sentry_identity.id;


--
-- Name: sentry_identityprovider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_identityprovider (
    id bigint NOT NULL,
    type character varying(64) NOT NULL,
    config text NOT NULL,
    date_added timestamp with time zone,
    external_id character varying(64)
);


ALTER TABLE public.sentry_identityprovider OWNER TO postgres;

--
-- Name: sentry_identityprovider_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_identityprovider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_identityprovider_id_seq OWNER TO postgres;

--
-- Name: sentry_identityprovider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_identityprovider_id_seq OWNED BY public.sentry_identityprovider.id;


--
-- Name: sentry_integration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_integration (
    id bigint NOT NULL,
    provider character varying(64) NOT NULL,
    external_id character varying(64) NOT NULL,
    name character varying(200) NOT NULL,
    metadata text NOT NULL,
    date_added timestamp with time zone,
    status integer,
    CONSTRAINT ck_status_pstv_6932790ce8c806c0 CHECK ((status >= 0)),
    CONSTRAINT sentry_integration_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_integration OWNER TO postgres;

--
-- Name: sentry_integration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_integration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_integration_id_seq OWNER TO postgres;

--
-- Name: sentry_integration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_integration_id_seq OWNED BY public.sentry_integration.id;


--
-- Name: sentry_integrationexternalproject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_integrationexternalproject (
    id bigint NOT NULL,
    organization_integration_id integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    name character varying(128) NOT NULL,
    external_id character varying(64) NOT NULL,
    resolved_status character varying(64) NOT NULL,
    unresolved_status character varying(64) NOT NULL,
    CONSTRAINT sentry_integrationexternalpro_organization_integration_id_check CHECK ((organization_integration_id >= 0))
);


ALTER TABLE public.sentry_integrationexternalproject OWNER TO postgres;

--
-- Name: sentry_integrationexternalproject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_integrationexternalproject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_integrationexternalproject_id_seq OWNER TO postgres;

--
-- Name: sentry_integrationexternalproject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_integrationexternalproject_id_seq OWNED BY public.sentry_integrationexternalproject.id;


--
-- Name: sentry_latestrelease; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_latestrelease (
    id bigint NOT NULL,
    repository_id bigint NOT NULL,
    environment_id bigint NOT NULL,
    release_id bigint NOT NULL,
    deploy_id bigint,
    commit_id bigint
);


ALTER TABLE public.sentry_latestrelease OWNER TO postgres;

--
-- Name: sentry_latestrelease_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_latestrelease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_latestrelease_id_seq OWNER TO postgres;

--
-- Name: sentry_latestrelease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_latestrelease_id_seq OWNED BY public.sentry_latestrelease.id;


--
-- Name: sentry_lostpasswordhash; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_lostpasswordhash (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    hash character varying(32) NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_lostpasswordhash OWNER TO postgres;

--
-- Name: sentry_lostpasswordhash_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_lostpasswordhash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_lostpasswordhash_id_seq OWNER TO postgres;

--
-- Name: sentry_lostpasswordhash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_lostpasswordhash_id_seq OWNED BY public.sentry_lostpasswordhash.id;


--
-- Name: sentry_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_message (
    id bigint NOT NULL,
    message text NOT NULL,
    datetime timestamp with time zone NOT NULL,
    data text,
    group_id bigint,
    message_id character varying(32),
    project_id bigint,
    time_spent integer,
    platform character varying(64)
);


ALTER TABLE public.sentry_message OWNER TO postgres;

--
-- Name: sentry_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_message_id_seq OWNER TO postgres;

--
-- Name: sentry_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_message_id_seq OWNED BY public.sentry_message.id;


--
-- Name: sentry_messagefiltervalue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_messagefiltervalue (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    times_seen integer NOT NULL,
    key character varying(32) NOT NULL,
    value character varying(200) NOT NULL,
    project_id bigint,
    last_seen timestamp with time zone,
    first_seen timestamp with time zone,
    CONSTRAINT sentry_messagefiltervalue_times_seen_check CHECK ((times_seen >= 0))
);


ALTER TABLE public.sentry_messagefiltervalue OWNER TO postgres;

--
-- Name: sentry_messagefiltervalue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_messagefiltervalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_messagefiltervalue_id_seq OWNER TO postgres;

--
-- Name: sentry_messagefiltervalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_messagefiltervalue_id_seq OWNED BY public.sentry_messagefiltervalue.id;


--
-- Name: sentry_messageindex; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_messageindex (
    id bigint NOT NULL,
    object_id integer NOT NULL,
    "column" character varying(32) NOT NULL,
    value character varying(128) NOT NULL,
    CONSTRAINT sentry_messageindex_object_id_check CHECK ((object_id >= 0))
);


ALTER TABLE public.sentry_messageindex OWNER TO postgres;

--
-- Name: sentry_messageindex_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_messageindex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_messageindex_id_seq OWNER TO postgres;

--
-- Name: sentry_messageindex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_messageindex_id_seq OWNED BY public.sentry_messageindex.id;


--
-- Name: sentry_monitor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_monitor (
    id bigint NOT NULL,
    guid uuid NOT NULL,
    organization_id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying(128) NOT NULL,
    status integer NOT NULL,
    type integer NOT NULL,
    config text NOT NULL,
    next_checkin timestamp with time zone,
    last_checkin timestamp with time zone,
    date_added timestamp with time zone NOT NULL,
    CONSTRAINT sentry_monitor_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_monitor_project_id_check CHECK ((project_id >= 0)),
    CONSTRAINT sentry_monitor_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_monitor_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_monitor OWNER TO postgres;

--
-- Name: sentry_monitor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_monitor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_monitor_id_seq OWNER TO postgres;

--
-- Name: sentry_monitor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_monitor_id_seq OWNED BY public.sentry_monitor.id;


--
-- Name: sentry_monitorcheckin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_monitorcheckin (
    id bigint NOT NULL,
    guid uuid NOT NULL,
    project_id integer NOT NULL,
    monitor_id bigint NOT NULL,
    location_id bigint,
    status integer NOT NULL,
    config text NOT NULL,
    duration integer,
    date_added timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL,
    CONSTRAINT sentry_monitorcheckin_duration_check CHECK ((duration >= 0)),
    CONSTRAINT sentry_monitorcheckin_project_id_check CHECK ((project_id >= 0)),
    CONSTRAINT sentry_monitorcheckin_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_monitorcheckin OWNER TO postgres;

--
-- Name: sentry_monitorcheckin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_monitorcheckin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_monitorcheckin_id_seq OWNER TO postgres;

--
-- Name: sentry_monitorcheckin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_monitorcheckin_id_seq OWNED BY public.sentry_monitorcheckin.id;


--
-- Name: sentry_monitorlocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_monitorlocation (
    id bigint NOT NULL,
    guid uuid NOT NULL,
    name character varying(128) NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_monitorlocation OWNER TO postgres;

--
-- Name: sentry_monitorlocation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_monitorlocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_monitorlocation_id_seq OWNER TO postgres;

--
-- Name: sentry_monitorlocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_monitorlocation_id_seq OWNED BY public.sentry_monitorlocation.id;


--
-- Name: sentry_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_option (
    id bigint NOT NULL,
    key character varying(64) NOT NULL,
    value text NOT NULL,
    last_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_option OWNER TO postgres;

--
-- Name: sentry_option_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_option_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_option_id_seq OWNER TO postgres;

--
-- Name: sentry_option_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_option_id_seq OWNED BY public.sentry_option.id;


--
-- Name: sentry_organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organization (
    id bigint NOT NULL,
    name character varying(64) NOT NULL,
    status integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    slug character varying(50) NOT NULL,
    flags bigint NOT NULL,
    default_role character varying(32) NOT NULL,
    CONSTRAINT sentry_organization_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_organization OWNER TO postgres;

--
-- Name: sentry_organization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organization_id_seq OWNER TO postgres;

--
-- Name: sentry_organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organization_id_seq OWNED BY public.sentry_organization.id;


--
-- Name: sentry_organizationaccessrequest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationaccessrequest (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    member_id bigint NOT NULL
);


ALTER TABLE public.sentry_organizationaccessrequest OWNER TO postgres;

--
-- Name: sentry_organizationaccessrequest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationaccessrequest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationaccessrequest_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationaccessrequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationaccessrequest_id_seq OWNED BY public.sentry_organizationaccessrequest.id;


--
-- Name: sentry_organizationavatar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationavatar (
    id bigint NOT NULL,
    file_id bigint,
    ident character varying(32) NOT NULL,
    organization_id bigint NOT NULL,
    avatar_type smallint NOT NULL,
    CONSTRAINT sentry_organizationavatar_avatar_type_check CHECK ((avatar_type >= 0))
);


ALTER TABLE public.sentry_organizationavatar OWNER TO postgres;

--
-- Name: sentry_organizationavatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationavatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationavatar_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationavatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationavatar_id_seq OWNED BY public.sentry_organizationavatar.id;


--
-- Name: sentry_organizationintegration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationintegration (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    integration_id bigint NOT NULL,
    config text NOT NULL,
    default_auth_id integer,
    date_added timestamp with time zone,
    status integer NOT NULL,
    CONSTRAINT ck_default_auth_id_pstv_69e09714ab85b548 CHECK ((default_auth_id >= 0)),
    CONSTRAINT ck_status_pstv_36cc6d15e7413671 CHECK ((status >= 0)),
    CONSTRAINT sentry_organizationintegration_default_auth_id_check CHECK ((default_auth_id >= 0)),
    CONSTRAINT sentry_organizationintegration_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_organizationintegration OWNER TO postgres;

--
-- Name: sentry_organizationintegration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationintegration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationintegration_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationintegration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationintegration_id_seq OWNED BY public.sentry_organizationintegration.id;


--
-- Name: sentry_organizationmember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationmember (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    user_id integer,
    type integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    email character varying(75),
    has_global_access boolean NOT NULL,
    flags bigint NOT NULL,
    role character varying(32) NOT NULL,
    token character varying(64),
    token_expires_at timestamp with time zone,
    CONSTRAINT sentry_organizationmember_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_organizationmember OWNER TO postgres;

--
-- Name: sentry_organizationmember_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationmember_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationmember_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationmember_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationmember_id_seq OWNED BY public.sentry_organizationmember.id;


--
-- Name: sentry_organizationmember_teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationmember_teams (
    id integer NOT NULL,
    organizationmember_id bigint NOT NULL,
    team_id bigint NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.sentry_organizationmember_teams OWNER TO postgres;

--
-- Name: sentry_organizationmember_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationmember_teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationmember_teams_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationmember_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationmember_teams_id_seq OWNED BY public.sentry_organizationmember_teams.id;


--
-- Name: sentry_organizationonboardingtask; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationonboardingtask (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    user_id integer,
    task integer NOT NULL,
    status integer NOT NULL,
    date_completed timestamp with time zone NOT NULL,
    project_id bigint,
    data text NOT NULL,
    CONSTRAINT sentry_organizationonboardingtask_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_organizationonboardingtask_task_check CHECK ((task >= 0))
);


ALTER TABLE public.sentry_organizationonboardingtask OWNER TO postgres;

--
-- Name: sentry_organizationonboardingtask_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationonboardingtask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationonboardingtask_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationonboardingtask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationonboardingtask_id_seq OWNED BY public.sentry_organizationonboardingtask.id;


--
-- Name: sentry_organizationoptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_organizationoptions (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    key character varying(64) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.sentry_organizationoptions OWNER TO postgres;

--
-- Name: sentry_organizationoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_organizationoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_organizationoptions_id_seq OWNER TO postgres;

--
-- Name: sentry_organizationoptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_organizationoptions_id_seq OWNED BY public.sentry_organizationoptions.id;


--
-- Name: sentry_platformexternalissue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_platformexternalissue (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    service_type character varying(64) NOT NULL,
    display_name text NOT NULL,
    web_url character varying(200) NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_platformexternalissue OWNER TO postgres;

--
-- Name: sentry_platformexternalissue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_platformexternalissue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_platformexternalissue_id_seq OWNER TO postgres;

--
-- Name: sentry_platformexternalissue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_platformexternalissue_id_seq OWNED BY public.sentry_platformexternalissue.id;


--
-- Name: sentry_processingissue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_processingissue (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    checksum character varying(40) NOT NULL,
    type character varying(30) NOT NULL,
    data text NOT NULL,
    datetime timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_processingissue OWNER TO postgres;

--
-- Name: sentry_processingissue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_processingissue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_processingissue_id_seq OWNER TO postgres;

--
-- Name: sentry_processingissue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_processingissue_id_seq OWNED BY public.sentry_processingissue.id;


--
-- Name: sentry_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_project (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    public boolean NOT NULL,
    date_added timestamp with time zone NOT NULL,
    status integer NOT NULL,
    slug character varying(50),
    organization_id bigint NOT NULL,
    first_event timestamp with time zone,
    forced_color character varying(6),
    flags bigint,
    platform character varying(64),
    CONSTRAINT ck_status_pstv_3af8360b8a37db73 CHECK ((status >= 0)),
    CONSTRAINT sentry_project_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_project OWNER TO postgres;

--
-- Name: sentry_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_project_id_seq OWNER TO postgres;

--
-- Name: sentry_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_project_id_seq OWNED BY public.sentry_project.id;


--
-- Name: sentry_projectavatar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectavatar (
    id bigint NOT NULL,
    file_id bigint,
    ident character varying(32) NOT NULL,
    project_id bigint NOT NULL,
    avatar_type smallint NOT NULL,
    CONSTRAINT sentry_projectavatar_avatar_type_check CHECK ((avatar_type >= 0))
);


ALTER TABLE public.sentry_projectavatar OWNER TO postgres;

--
-- Name: sentry_projectavatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectavatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectavatar_id_seq OWNER TO postgres;

--
-- Name: sentry_projectavatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectavatar_id_seq OWNED BY public.sentry_projectavatar.id;


--
-- Name: sentry_projectbookmark; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectbookmark (
    id bigint NOT NULL,
    project_id bigint,
    user_id integer NOT NULL,
    date_added timestamp with time zone
);


ALTER TABLE public.sentry_projectbookmark OWNER TO postgres;

--
-- Name: sentry_projectbookmark_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectbookmark_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectbookmark_id_seq OWNER TO postgres;

--
-- Name: sentry_projectbookmark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectbookmark_id_seq OWNED BY public.sentry_projectbookmark.id;


--
-- Name: sentry_projectcficachefile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectcficachefile (
    id bigint NOT NULL,
    project_id bigint,
    cache_file_id bigint NOT NULL,
    dsym_file_id bigint NOT NULL,
    checksum character varying(40) NOT NULL,
    version integer NOT NULL,
    CONSTRAINT sentry_projectcficachefile_version_check CHECK ((version >= 0))
);


ALTER TABLE public.sentry_projectcficachefile OWNER TO postgres;

--
-- Name: sentry_projectcficachefile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectcficachefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectcficachefile_id_seq OWNER TO postgres;

--
-- Name: sentry_projectcficachefile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectcficachefile_id_seq OWNED BY public.sentry_projectcficachefile.id;


--
-- Name: sentry_projectcounter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectcounter (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    value bigint NOT NULL
);


ALTER TABLE public.sentry_projectcounter OWNER TO postgres;

--
-- Name: sentry_projectcounter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectcounter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectcounter_id_seq OWNER TO postgres;

--
-- Name: sentry_projectcounter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectcounter_id_seq OWNED BY public.sentry_projectcounter.id;


--
-- Name: sentry_projectdsymfile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectdsymfile (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    object_name text NOT NULL,
    cpu_name character varying(40) NOT NULL,
    project_id bigint,
    uuid character varying(64) NOT NULL,
    data text,
    code_id character varying(64)
);


ALTER TABLE public.sentry_projectdsymfile OWNER TO postgres;

--
-- Name: sentry_projectdsymfile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectdsymfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectdsymfile_id_seq OWNER TO postgres;

--
-- Name: sentry_projectdsymfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectdsymfile_id_seq OWNED BY public.sentry_projectdsymfile.id;


--
-- Name: sentry_projectintegration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectintegration (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    integration_id bigint NOT NULL,
    config text NOT NULL
);


ALTER TABLE public.sentry_projectintegration OWNER TO postgres;

--
-- Name: sentry_projectintegration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectintegration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectintegration_id_seq OWNER TO postgres;

--
-- Name: sentry_projectintegration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectintegration_id_seq OWNED BY public.sentry_projectintegration.id;


--
-- Name: sentry_projectkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectkey (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    public_key character varying(32),
    secret_key character varying(32),
    date_added timestamp with time zone,
    roles bigint NOT NULL,
    label character varying(64),
    status integer NOT NULL,
    rate_limit_count integer,
    rate_limit_window integer,
    data text NOT NULL,
    CONSTRAINT ck_rate_limit_count_pstv_3e2d8378c08cd2b5 CHECK ((rate_limit_count >= 0)),
    CONSTRAINT ck_rate_limit_window_pstv_546e3067ebba7213 CHECK ((rate_limit_window >= 0)),
    CONSTRAINT ck_status_pstv_1f17c0d00e89ed63 CHECK ((status >= 0)),
    CONSTRAINT sentry_projectkey_rate_limit_count_check CHECK ((rate_limit_count >= 0)),
    CONSTRAINT sentry_projectkey_rate_limit_window_check CHECK ((rate_limit_window >= 0)),
    CONSTRAINT sentry_projectkey_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_projectkey OWNER TO postgres;

--
-- Name: sentry_projectkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectkey_id_seq OWNER TO postgres;

--
-- Name: sentry_projectkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectkey_id_seq OWNED BY public.sentry_projectkey.id;


--
-- Name: sentry_projectoptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectoptions (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    key character varying(64) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.sentry_projectoptions OWNER TO postgres;

--
-- Name: sentry_projectoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectoptions_id_seq OWNER TO postgres;

--
-- Name: sentry_projectoptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectoptions_id_seq OWNED BY public.sentry_projectoptions.id;


--
-- Name: sentry_projectownership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectownership (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    raw text,
    schema text,
    fallthrough boolean NOT NULL,
    date_created timestamp with time zone NOT NULL,
    last_updated timestamp with time zone NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.sentry_projectownership OWNER TO postgres;

--
-- Name: sentry_projectownership_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectownership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectownership_id_seq OWNER TO postgres;

--
-- Name: sentry_projectownership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectownership_id_seq OWNED BY public.sentry_projectownership.id;


--
-- Name: sentry_projectplatform; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectplatform (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    platform character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_projectplatform OWNER TO postgres;

--
-- Name: sentry_projectplatform_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectplatform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectplatform_id_seq OWNER TO postgres;

--
-- Name: sentry_projectplatform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectplatform_id_seq OWNED BY public.sentry_projectplatform.id;


--
-- Name: sentry_projectredirect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectredirect (
    id bigint NOT NULL,
    redirect_slug character varying(50) NOT NULL,
    project_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_projectredirect OWNER TO postgres;

--
-- Name: sentry_projectredirect_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectredirect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectredirect_id_seq OWNER TO postgres;

--
-- Name: sentry_projectredirect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectredirect_id_seq OWNED BY public.sentry_projectredirect.id;


--
-- Name: sentry_projectsymcachefile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectsymcachefile (
    id bigint NOT NULL,
    project_id bigint,
    cache_file_id bigint NOT NULL,
    dsym_file_id bigint NOT NULL,
    checksum character varying(40) NOT NULL,
    version integer NOT NULL,
    CONSTRAINT sentry_projectsymcachefile_version_check CHECK ((version >= 0))
);


ALTER TABLE public.sentry_projectsymcachefile OWNER TO postgres;

--
-- Name: sentry_projectsymcachefile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectsymcachefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectsymcachefile_id_seq OWNER TO postgres;

--
-- Name: sentry_projectsymcachefile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectsymcachefile_id_seq OWNED BY public.sentry_projectsymcachefile.id;


--
-- Name: sentry_projectteam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_projectteam (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    team_id bigint NOT NULL
);


ALTER TABLE public.sentry_projectteam OWNER TO postgres;

--
-- Name: sentry_projectteam_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_projectteam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_projectteam_id_seq OWNER TO postgres;

--
-- Name: sentry_projectteam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_projectteam_id_seq OWNED BY public.sentry_projectteam.id;


--
-- Name: sentry_promptsactivity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_promptsactivity (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    feature character varying(64) NOT NULL,
    data text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    organization_id integer NOT NULL,
    CONSTRAINT ck_organization_id_pstv_10b40b6d3b3aca32 CHECK ((organization_id >= 0)),
    CONSTRAINT ck_project_id_pstv_381bd03b942cb1d7 CHECK ((project_id >= 0)),
    CONSTRAINT sentry_promptsactivity_organization_id_check CHECK ((organization_id >= 0))
);


ALTER TABLE public.sentry_promptsactivity OWNER TO postgres;

--
-- Name: sentry_promptsactivity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_promptsactivity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_promptsactivity_id_seq OWNER TO postgres;

--
-- Name: sentry_promptsactivity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_promptsactivity_id_seq OWNED BY public.sentry_promptsactivity.id;


--
-- Name: sentry_pull_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_pull_request (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    title text,
    message text,
    author_id bigint,
    merge_commit_sha character varying(64),
    CONSTRAINT sentry_pull_request_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_pull_request_repository_id_check CHECK ((repository_id >= 0))
);


ALTER TABLE public.sentry_pull_request OWNER TO postgres;

--
-- Name: sentry_pull_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_pull_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_pull_request_id_seq OWNER TO postgres;

--
-- Name: sentry_pull_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_pull_request_id_seq OWNED BY public.sentry_pull_request.id;


--
-- Name: sentry_pullrequest_commit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_pullrequest_commit (
    id bigint NOT NULL,
    pull_request_id bigint NOT NULL,
    commit_id bigint NOT NULL
);


ALTER TABLE public.sentry_pullrequest_commit OWNER TO postgres;

--
-- Name: sentry_pullrequest_commit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_pullrequest_commit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_pullrequest_commit_id_seq OWNER TO postgres;

--
-- Name: sentry_pullrequest_commit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_pullrequest_commit_id_seq OWNED BY public.sentry_pullrequest_commit.id;


--
-- Name: sentry_rawevent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_rawevent (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    event_id character varying(32),
    datetime timestamp with time zone NOT NULL,
    data text
);


ALTER TABLE public.sentry_rawevent OWNER TO postgres;

--
-- Name: sentry_rawevent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_rawevent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_rawevent_id_seq OWNER TO postgres;

--
-- Name: sentry_rawevent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_rawevent_id_seq OWNED BY public.sentry_rawevent.id;


--
-- Name: sentry_recentsearch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_recentsearch (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    user_id integer NOT NULL,
    type smallint NOT NULL,
    query text NOT NULL,
    query_hash character varying(32) NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    date_added timestamp with time zone NOT NULL,
    CONSTRAINT sentry_recentsearch_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_recentsearch OWNER TO postgres;

--
-- Name: sentry_recentsearch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_recentsearch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_recentsearch_id_seq OWNER TO postgres;

--
-- Name: sentry_recentsearch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_recentsearch_id_seq OWNED BY public.sentry_recentsearch.id;


--
-- Name: sentry_relay; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_relay (
    id bigint NOT NULL,
    relay_id character varying(64) NOT NULL,
    public_key character varying(200) NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    is_internal boolean NOT NULL
);


ALTER TABLE public.sentry_relay OWNER TO postgres;

--
-- Name: sentry_relay_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_relay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_relay_id_seq OWNER TO postgres;

--
-- Name: sentry_relay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_relay_id_seq OWNED BY public.sentry_relay.id;


--
-- Name: sentry_release; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_release (
    id bigint NOT NULL,
    project_id bigint,
    version character varying(250) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    date_released timestamp with time zone,
    ref character varying(250),
    url character varying(200),
    date_started timestamp with time zone,
    data text NOT NULL,
    new_groups integer NOT NULL,
    owner_id integer,
    organization_id bigint NOT NULL,
    commit_count integer,
    last_commit_id integer,
    authors text[],
    total_deploys integer,
    last_deploy_id integer,
    CONSTRAINT ck_commit_count_pstv_1e83b2bc4ee61de0 CHECK ((commit_count >= 0)),
    CONSTRAINT ck_last_commit_id_pstv_55474fbdf700412d CHECK ((last_commit_id >= 0)),
    CONSTRAINT ck_last_deploy_id_pstv_84d0c411d577507 CHECK ((last_deploy_id >= 0)),
    CONSTRAINT ck_new_groups_pstv_2cb74b3445ff4f0c CHECK ((new_groups >= 0)),
    CONSTRAINT ck_total_deploys_pstv_3619b358adfb4f75 CHECK ((total_deploys >= 0)),
    CONSTRAINT sentry_release_commit_count_check CHECK ((commit_count >= 0)),
    CONSTRAINT sentry_release_last_commit_id_check CHECK ((last_commit_id >= 0)),
    CONSTRAINT sentry_release_last_deploy_id_check CHECK ((last_deploy_id >= 0)),
    CONSTRAINT sentry_release_new_groups_check CHECK ((new_groups >= 0)),
    CONSTRAINT sentry_release_total_deploys_check CHECK ((total_deploys >= 0))
);


ALTER TABLE public.sentry_release OWNER TO postgres;

--
-- Name: sentry_release_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_release_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_release_id_seq OWNER TO postgres;

--
-- Name: sentry_release_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_release_id_seq OWNED BY public.sentry_release.id;


--
-- Name: sentry_release_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_release_project (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    release_id bigint NOT NULL,
    new_groups integer,
    CONSTRAINT ck_new_groups_pstv_35c7ce1fb5b5915e CHECK ((new_groups >= 0)),
    CONSTRAINT sentry_release_project_new_groups_check CHECK ((new_groups >= 0))
);


ALTER TABLE public.sentry_release_project OWNER TO postgres;

--
-- Name: sentry_release_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_release_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_release_project_id_seq OWNER TO postgres;

--
-- Name: sentry_release_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_release_project_id_seq OWNED BY public.sentry_release_project.id;


--
-- Name: sentry_releasecommit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_releasecommit (
    id bigint NOT NULL,
    project_id integer,
    release_id bigint NOT NULL,
    commit_id bigint NOT NULL,
    "order" integer NOT NULL,
    organization_id integer NOT NULL,
    CONSTRAINT ck_organization_id_pstv_63c72b7b5009246 CHECK ((organization_id >= 0)),
    CONSTRAINT ck_project_id_pstv_559bbb746b5337db CHECK ((project_id >= 0)),
    CONSTRAINT sentry_releasecommit_order_check CHECK (("order" >= 0))
);


ALTER TABLE public.sentry_releasecommit OWNER TO postgres;

--
-- Name: sentry_releasecommit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_releasecommit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_releasecommit_id_seq OWNER TO postgres;

--
-- Name: sentry_releasecommit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_releasecommit_id_seq OWNED BY public.sentry_releasecommit.id;


--
-- Name: sentry_releasefile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_releasefile (
    id bigint NOT NULL,
    project_id bigint,
    release_id bigint NOT NULL,
    file_id bigint NOT NULL,
    ident character varying(40) NOT NULL,
    name text NOT NULL,
    organization_id bigint NOT NULL,
    dist_id bigint
);


ALTER TABLE public.sentry_releasefile OWNER TO postgres;

--
-- Name: sentry_releasefile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_releasefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_releasefile_id_seq OWNER TO postgres;

--
-- Name: sentry_releasefile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_releasefile_id_seq OWNED BY public.sentry_releasefile.id;


--
-- Name: sentry_releaseheadcommit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_releaseheadcommit (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    repository_id integer NOT NULL,
    release_id bigint NOT NULL,
    commit_id bigint NOT NULL,
    CONSTRAINT sentry_releaseheadcommit_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_releaseheadcommit_repository_id_check CHECK ((repository_id >= 0))
);


ALTER TABLE public.sentry_releaseheadcommit OWNER TO postgres;

--
-- Name: sentry_releaseheadcommit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_releaseheadcommit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_releaseheadcommit_id_seq OWNER TO postgres;

--
-- Name: sentry_releaseheadcommit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_releaseheadcommit_id_seq OWNED BY public.sentry_releaseheadcommit.id;


--
-- Name: sentry_releaseprojectenvironment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_releaseprojectenvironment (
    id bigint NOT NULL,
    release_id bigint NOT NULL,
    project_id bigint NOT NULL,
    environment_id bigint NOT NULL,
    new_issues_count integer NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    last_deploy_id integer,
    CONSTRAINT ck_last_deploy_id_pstv_6b9874520fa13549 CHECK ((last_deploy_id >= 0)),
    CONSTRAINT sentry_releaseprojectenvironment_last_deploy_id_check CHECK ((last_deploy_id >= 0)),
    CONSTRAINT sentry_releaseprojectenvironment_new_issues_count_check CHECK ((new_issues_count >= 0))
);


ALTER TABLE public.sentry_releaseprojectenvironment OWNER TO postgres;

--
-- Name: sentry_releaseprojectenvironment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_releaseprojectenvironment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_releaseprojectenvironment_id_seq OWNER TO postgres;

--
-- Name: sentry_releaseprojectenvironment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_releaseprojectenvironment_id_seq OWNED BY public.sentry_releaseprojectenvironment.id;


--
-- Name: sentry_repository; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_repository (
    id bigint NOT NULL,
    organization_id integer NOT NULL,
    name character varying(200) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    url character varying(200),
    provider character varying(64),
    external_id character varying(64),
    config text NOT NULL,
    status integer NOT NULL,
    integration_id integer,
    CONSTRAINT ck_integration_id_pstv_4f3ef70e3e282bab CHECK ((integration_id >= 0)),
    CONSTRAINT ck_status_pstv_562b3ff4dae47f6b CHECK ((status >= 0)),
    CONSTRAINT sentry_repository_integration_id_check CHECK ((integration_id >= 0)),
    CONSTRAINT sentry_repository_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_repository_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_repository OWNER TO postgres;

--
-- Name: sentry_repository_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_repository_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_repository_id_seq OWNER TO postgres;

--
-- Name: sentry_repository_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_repository_id_seq OWNED BY public.sentry_repository.id;


--
-- Name: sentry_reprocessingreport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_reprocessingreport (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    event_id character varying(32),
    datetime timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_reprocessingreport OWNER TO postgres;

--
-- Name: sentry_reprocessingreport_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_reprocessingreport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_reprocessingreport_id_seq OWNER TO postgres;

--
-- Name: sentry_reprocessingreport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_reprocessingreport_id_seq OWNED BY public.sentry_reprocessingreport.id;


--
-- Name: sentry_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_rule (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    label character varying(64) NOT NULL,
    data text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    status integer NOT NULL,
    environment_id integer,
    CONSTRAINT ck_environment_id_pstv_38aad0b7c980c236 CHECK ((environment_id >= 0)),
    CONSTRAINT ck_status_pstv_64efa876e92cb76d CHECK ((status >= 0)),
    CONSTRAINT sentry_rule_environment_id_check CHECK ((environment_id >= 0)),
    CONSTRAINT sentry_rule_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_rule OWNER TO postgres;

--
-- Name: sentry_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_rule_id_seq OWNER TO postgres;

--
-- Name: sentry_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_rule_id_seq OWNED BY public.sentry_rule.id;


--
-- Name: sentry_savedsearch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_savedsearch (
    id bigint NOT NULL,
    project_id bigint,
    name character varying(128) NOT NULL,
    query text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    is_default boolean NOT NULL,
    owner_id integer,
    is_global boolean,
    organization_id bigint,
    type smallint,
    CONSTRAINT ck_type_pstv_409fcb78f819486e CHECK ((type >= 0)),
    CONSTRAINT sentry_savedsearch_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_savedsearch OWNER TO postgres;

--
-- Name: sentry_savedsearch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_savedsearch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_savedsearch_id_seq OWNER TO postgres;

--
-- Name: sentry_savedsearch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_savedsearch_id_seq OWNED BY public.sentry_savedsearch.id;


--
-- Name: sentry_savedsearch_userdefault; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_savedsearch_userdefault (
    id bigint NOT NULL,
    savedsearch_id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.sentry_savedsearch_userdefault OWNER TO postgres;

--
-- Name: sentry_savedsearch_userdefault_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_savedsearch_userdefault_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_savedsearch_userdefault_id_seq OWNER TO postgres;

--
-- Name: sentry_savedsearch_userdefault_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_savedsearch_userdefault_id_seq OWNED BY public.sentry_savedsearch_userdefault.id;


--
-- Name: sentry_scheduleddeletion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_scheduleddeletion (
    id bigint NOT NULL,
    guid character varying(32) NOT NULL,
    app_label character varying(64) NOT NULL,
    model_name character varying(64) NOT NULL,
    object_id bigint NOT NULL,
    date_added timestamp with time zone NOT NULL,
    date_scheduled timestamp with time zone NOT NULL,
    actor_id bigint,
    data text NOT NULL,
    in_progress boolean NOT NULL,
    aborted boolean NOT NULL
);


ALTER TABLE public.sentry_scheduleddeletion OWNER TO postgres;

--
-- Name: sentry_scheduleddeletion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_scheduleddeletion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_scheduleddeletion_id_seq OWNER TO postgres;

--
-- Name: sentry_scheduleddeletion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_scheduleddeletion_id_seq OWNED BY public.sentry_scheduleddeletion.id;


--
-- Name: sentry_scheduledjob; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_scheduledjob (
    id bigint NOT NULL,
    name character varying(128) NOT NULL,
    payload text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    date_scheduled timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_scheduledjob OWNER TO postgres;

--
-- Name: sentry_scheduledjob_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_scheduledjob_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_scheduledjob_id_seq OWNER TO postgres;

--
-- Name: sentry_scheduledjob_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_scheduledjob_id_seq OWNED BY public.sentry_scheduledjob.id;


--
-- Name: sentry_sentryapp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_sentryapp (
    id bigint NOT NULL,
    date_deleted timestamp with time zone,
    application_id integer,
    proxy_user_id integer,
    owner_id bigint NOT NULL,
    scopes bigint NOT NULL,
    scope_list text[],
    name text NOT NULL,
    slug character varying(64) NOT NULL,
    uuid character varying(64) NOT NULL,
    webhook_url character varying(200) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL,
    status integer NOT NULL,
    redirect_url character varying(200),
    overview text,
    is_alertable boolean NOT NULL,
    events text[],
    schema text NOT NULL,
    author text,
    CONSTRAINT ck_status_pstv_355e7ec8e8c72132 CHECK ((status >= 0)),
    CONSTRAINT sentry_sentryapp_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_sentryapp OWNER TO postgres;

--
-- Name: sentry_sentryapp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_sentryapp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_sentryapp_id_seq OWNER TO postgres;

--
-- Name: sentry_sentryapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_sentryapp_id_seq OWNED BY public.sentry_sentryapp.id;


--
-- Name: sentry_sentryappavatar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_sentryappavatar (
    id bigint NOT NULL,
    file_id bigint,
    ident character varying(32) NOT NULL,
    sentry_app_id bigint NOT NULL,
    avatar_type smallint NOT NULL,
    CONSTRAINT sentry_sentryappavatar_avatar_type_check CHECK ((avatar_type >= 0))
);


ALTER TABLE public.sentry_sentryappavatar OWNER TO postgres;

--
-- Name: sentry_sentryappavatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_sentryappavatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_sentryappavatar_id_seq OWNER TO postgres;

--
-- Name: sentry_sentryappavatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_sentryappavatar_id_seq OWNED BY public.sentry_sentryappavatar.id;


--
-- Name: sentry_sentryappcomponent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_sentryappcomponent (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    sentry_app_id bigint NOT NULL,
    type character varying(64) NOT NULL,
    schema text NOT NULL
);


ALTER TABLE public.sentry_sentryappcomponent OWNER TO postgres;

--
-- Name: sentry_sentryappcomponent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_sentryappcomponent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_sentryappcomponent_id_seq OWNER TO postgres;

--
-- Name: sentry_sentryappcomponent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_sentryappcomponent_id_seq OWNED BY public.sentry_sentryappcomponent.id;


--
-- Name: sentry_sentryappinstallation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_sentryappinstallation (
    id bigint NOT NULL,
    date_deleted timestamp with time zone,
    sentry_app_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    authorization_id integer,
    api_grant_id integer,
    uuid character varying(64) NOT NULL,
    date_added timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.sentry_sentryappinstallation OWNER TO postgres;

--
-- Name: sentry_sentryappinstallation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_sentryappinstallation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_sentryappinstallation_id_seq OWNER TO postgres;

--
-- Name: sentry_sentryappinstallation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_sentryappinstallation_id_seq OWNED BY public.sentry_sentryappinstallation.id;


--
-- Name: sentry_servicehook; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_servicehook (
    id bigint NOT NULL,
    guid character varying(32),
    application_id bigint,
    actor_id integer NOT NULL,
    project_id integer NOT NULL,
    url character varying(512) NOT NULL,
    secret text NOT NULL,
    events text[],
    status integer NOT NULL,
    version integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    organization_id integer,
    CONSTRAINT ck_organization_id_pstv_f3d08c27a8d9b78 CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_servicehook_actor_id_check CHECK ((actor_id >= 0)),
    CONSTRAINT sentry_servicehook_organization_id_check CHECK ((organization_id >= 0)),
    CONSTRAINT sentry_servicehook_project_id_check CHECK ((project_id >= 0)),
    CONSTRAINT sentry_servicehook_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_servicehook_version_check CHECK ((version >= 0))
);


ALTER TABLE public.sentry_servicehook OWNER TO postgres;

--
-- Name: sentry_servicehook_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_servicehook_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_servicehook_id_seq OWNER TO postgres;

--
-- Name: sentry_servicehook_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_servicehook_id_seq OWNED BY public.sentry_servicehook.id;


--
-- Name: sentry_servicehookproject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_servicehookproject (
    id bigint NOT NULL,
    service_hook_id bigint NOT NULL,
    project_id integer NOT NULL,
    CONSTRAINT sentry_servicehookproject_project_id_check CHECK ((project_id >= 0))
);


ALTER TABLE public.sentry_servicehookproject OWNER TO postgres;

--
-- Name: sentry_servicehookproject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_servicehookproject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_servicehookproject_id_seq OWNER TO postgres;

--
-- Name: sentry_servicehookproject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_servicehookproject_id_seq OWNED BY public.sentry_servicehookproject.id;


--
-- Name: sentry_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_team (
    id bigint NOT NULL,
    slug character varying(50) NOT NULL,
    name character varying(64) NOT NULL,
    date_added timestamp with time zone,
    status integer NOT NULL,
    organization_id bigint NOT NULL,
    CONSTRAINT ck_status_pstv_1772e42d30eba7ba CHECK ((status >= 0)),
    CONSTRAINT sentry_team_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_team OWNER TO postgres;

--
-- Name: sentry_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_team_id_seq OWNER TO postgres;

--
-- Name: sentry_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_team_id_seq OWNED BY public.sentry_team.id;


--
-- Name: sentry_teamavatar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_teamavatar (
    id bigint NOT NULL,
    file_id bigint,
    ident character varying(32) NOT NULL,
    team_id bigint NOT NULL,
    avatar_type smallint NOT NULL,
    CONSTRAINT sentry_teamavatar_avatar_type_check CHECK ((avatar_type >= 0))
);


ALTER TABLE public.sentry_teamavatar OWNER TO postgres;

--
-- Name: sentry_teamavatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_teamavatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_teamavatar_id_seq OWNER TO postgres;

--
-- Name: sentry_teamavatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_teamavatar_id_seq OWNED BY public.sentry_teamavatar.id;


--
-- Name: sentry_useravatar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_useravatar (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    file_id bigint,
    ident character varying(32) NOT NULL,
    avatar_type smallint NOT NULL,
    CONSTRAINT sentry_useravatar_avatar_type_check CHECK ((avatar_type >= 0))
);


ALTER TABLE public.sentry_useravatar OWNER TO postgres;

--
-- Name: sentry_useravatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_useravatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_useravatar_id_seq OWNER TO postgres;

--
-- Name: sentry_useravatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_useravatar_id_seq OWNED BY public.sentry_useravatar.id;


--
-- Name: sentry_useremail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_useremail (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    email character varying(75) NOT NULL,
    validation_hash character varying(32) NOT NULL,
    date_hash_added timestamp with time zone NOT NULL,
    is_verified boolean NOT NULL
);


ALTER TABLE public.sentry_useremail OWNER TO postgres;

--
-- Name: sentry_useremail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_useremail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_useremail_id_seq OWNER TO postgres;

--
-- Name: sentry_useremail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_useremail_id_seq OWNED BY public.sentry_useremail.id;


--
-- Name: sentry_userip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_userip (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    ip_address inet NOT NULL,
    first_seen timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    country_code character varying(16),
    region_code character varying(16)
);


ALTER TABLE public.sentry_userip OWNER TO postgres;

--
-- Name: sentry_userip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_userip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_userip_id_seq OWNER TO postgres;

--
-- Name: sentry_userip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_userip_id_seq OWNED BY public.sentry_userip.id;


--
-- Name: sentry_useroption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_useroption (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    project_id bigint,
    key character varying(64) NOT NULL,
    value text NOT NULL,
    organization_id bigint
);


ALTER TABLE public.sentry_useroption OWNER TO postgres;

--
-- Name: sentry_useroption_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_useroption_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_useroption_id_seq OWNER TO postgres;

--
-- Name: sentry_useroption_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_useroption_id_seq OWNED BY public.sentry_useroption.id;


--
-- Name: sentry_userpermission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_userpermission (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission character varying(32) NOT NULL
);


ALTER TABLE public.sentry_userpermission OWNER TO postgres;

--
-- Name: sentry_userpermission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_userpermission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_userpermission_id_seq OWNER TO postgres;

--
-- Name: sentry_userpermission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_userpermission_id_seq OWNED BY public.sentry_userpermission.id;


--
-- Name: sentry_userreport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_userreport (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint,
    event_id character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    email character varying(75) NOT NULL,
    comments text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    event_user_id bigint,
    environment_id bigint
);


ALTER TABLE public.sentry_userreport OWNER TO postgres;

--
-- Name: sentry_userreport_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_userreport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_userreport_id_seq OWNER TO postgres;

--
-- Name: sentry_userreport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_userreport_id_seq OWNED BY public.sentry_userreport.id;


--
-- Name: sentry_widget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_widget (
    id bigint NOT NULL,
    dashboard_id bigint NOT NULL,
    "order" integer NOT NULL,
    title character varying(255) NOT NULL,
    display_type integer NOT NULL,
    display_options text NOT NULL,
    date_added timestamp with time zone NOT NULL,
    status integer NOT NULL,
    CONSTRAINT sentry_widget_display_type_check CHECK ((display_type >= 0)),
    CONSTRAINT sentry_widget_order_check CHECK (("order" >= 0)),
    CONSTRAINT sentry_widget_status_check CHECK ((status >= 0))
);


ALTER TABLE public.sentry_widget OWNER TO postgres;

--
-- Name: sentry_widget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_widget_id_seq OWNER TO postgres;

--
-- Name: sentry_widget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_widget_id_seq OWNED BY public.sentry_widget.id;


--
-- Name: sentry_widgetdatasource; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sentry_widgetdatasource (
    id bigint NOT NULL,
    widget_id bigint NOT NULL,
    type integer NOT NULL,
    name character varying(255) NOT NULL,
    data text NOT NULL,
    "order" integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    status integer NOT NULL,
    CONSTRAINT sentry_widgetdatasource_order_check CHECK (("order" >= 0)),
    CONSTRAINT sentry_widgetdatasource_status_check CHECK ((status >= 0)),
    CONSTRAINT sentry_widgetdatasource_type_check CHECK ((type >= 0))
);


ALTER TABLE public.sentry_widgetdatasource OWNER TO postgres;

--
-- Name: sentry_widgetdatasource_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sentry_widgetdatasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sentry_widgetdatasource_id_seq OWNER TO postgres;

--
-- Name: sentry_widgetdatasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sentry_widgetdatasource_id_seq OWNED BY public.sentry_widgetdatasource.id;


--
-- Name: social_auth_usersocialauth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.social_auth_usersocialauth (
    id integer NOT NULL,
    user_id integer NOT NULL,
    provider character varying(32) NOT NULL,
    uid character varying(255) NOT NULL,
    extra_data text NOT NULL
);


ALTER TABLE public.social_auth_usersocialauth OWNER TO postgres;

--
-- Name: social_auth_usersocialauth_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.social_auth_usersocialauth_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.social_auth_usersocialauth_id_seq OWNER TO postgres;

--
-- Name: social_auth_usersocialauth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.social_auth_usersocialauth_id_seq OWNED BY public.social_auth_usersocialauth.id;


--
-- Name: south_migrationhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.south_migrationhistory (
    id integer NOT NULL,
    app_name character varying(255) NOT NULL,
    migration character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.south_migrationhistory OWNER TO postgres;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.south_migrationhistory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.south_migrationhistory_id_seq OWNER TO postgres;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.south_migrationhistory_id_seq OWNED BY public.south_migrationhistory.id;


--
-- Name: tagstore_eventtag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagstore_eventtag (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    event_id bigint NOT NULL,
    key_id bigint NOT NULL,
    value_id bigint NOT NULL,
    date_added timestamp with time zone NOT NULL
);


ALTER TABLE public.tagstore_eventtag OWNER TO postgres;

--
-- Name: tagstore_eventtag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagstore_eventtag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagstore_eventtag_id_seq OWNER TO postgres;

--
-- Name: tagstore_eventtag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagstore_eventtag_id_seq OWNED BY public.tagstore_eventtag.id;


--
-- Name: tagstore_grouptagkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagstore_grouptagkey (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    key_id bigint NOT NULL,
    values_seen integer NOT NULL,
    CONSTRAINT tagstore_grouptagkey_values_seen_check CHECK ((values_seen >= 0))
);


ALTER TABLE public.tagstore_grouptagkey OWNER TO postgres;

--
-- Name: tagstore_grouptagkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagstore_grouptagkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagstore_grouptagkey_id_seq OWNER TO postgres;

--
-- Name: tagstore_grouptagkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagstore_grouptagkey_id_seq OWNED BY public.tagstore_grouptagkey.id;


--
-- Name: tagstore_grouptagvalue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagstore_grouptagvalue (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    group_id bigint NOT NULL,
    times_seen integer NOT NULL,
    key_id bigint NOT NULL,
    value_id bigint NOT NULL,
    last_seen timestamp with time zone,
    first_seen timestamp with time zone,
    CONSTRAINT tagstore_grouptagvalue_times_seen_check CHECK ((times_seen >= 0))
);


ALTER TABLE public.tagstore_grouptagvalue OWNER TO postgres;

--
-- Name: tagstore_grouptagvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagstore_grouptagvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagstore_grouptagvalue_id_seq OWNER TO postgres;

--
-- Name: tagstore_grouptagvalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagstore_grouptagvalue_id_seq OWNED BY public.tagstore_grouptagvalue.id;


--
-- Name: tagstore_tagkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagstore_tagkey (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    environment_id bigint NOT NULL,
    key character varying(32) NOT NULL,
    values_seen integer NOT NULL,
    status integer NOT NULL,
    CONSTRAINT tagstore_tagkey_status_check CHECK ((status >= 0)),
    CONSTRAINT tagstore_tagkey_values_seen_check CHECK ((values_seen >= 0))
);


ALTER TABLE public.tagstore_tagkey OWNER TO postgres;

--
-- Name: tagstore_tagkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagstore_tagkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagstore_tagkey_id_seq OWNER TO postgres;

--
-- Name: tagstore_tagkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagstore_tagkey_id_seq OWNED BY public.tagstore_tagkey.id;


--
-- Name: tagstore_tagvalue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagstore_tagvalue (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    key_id bigint NOT NULL,
    value character varying(200) NOT NULL,
    data text,
    times_seen integer NOT NULL,
    last_seen timestamp with time zone,
    first_seen timestamp with time zone,
    CONSTRAINT tagstore_tagvalue_times_seen_check CHECK ((times_seen >= 0))
);


ALTER TABLE public.tagstore_tagvalue OWNER TO postgres;

--
-- Name: tagstore_tagvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagstore_tagvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagstore_tagvalue_id_seq OWNER TO postgres;

--
-- Name: tagstore_tagvalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagstore_tagvalue_id_seq OWNED BY public.tagstore_tagvalue.id;


--
-- Name: auth_authenticator id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_authenticator ALTER COLUMN id SET DEFAULT nextval('public.auth_authenticator_id_seq'::regclass);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_site id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site ALTER COLUMN id SET DEFAULT nextval('public.django_site_id_seq'::regclass);


--
-- Name: jira_ac_tenant id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jira_ac_tenant ALTER COLUMN id SET DEFAULT nextval('public.jira_ac_tenant_id_seq'::regclass);


--
-- Name: sentry_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_activity ALTER COLUMN id SET DEFAULT nextval('public.sentry_activity_id_seq'::regclass);


--
-- Name: sentry_apiapplication id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiapplication ALTER COLUMN id SET DEFAULT nextval('public.sentry_apiapplication_id_seq'::regclass);


--
-- Name: sentry_apiauthorization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiauthorization ALTER COLUMN id SET DEFAULT nextval('public.sentry_apiauthorization_id_seq'::regclass);


--
-- Name: sentry_apigrant id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apigrant ALTER COLUMN id SET DEFAULT nextval('public.sentry_apigrant_id_seq'::regclass);


--
-- Name: sentry_apikey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apikey ALTER COLUMN id SET DEFAULT nextval('public.sentry_apikey_id_seq'::regclass);


--
-- Name: sentry_apitoken id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken ALTER COLUMN id SET DEFAULT nextval('public.sentry_apitoken_id_seq'::regclass);


--
-- Name: sentry_assistant_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_assistant_activity ALTER COLUMN id SET DEFAULT nextval('public.sentry_assistant_activity_id_seq'::regclass);


--
-- Name: sentry_auditlogentry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry ALTER COLUMN id SET DEFAULT nextval('public.sentry_auditlogentry_id_seq'::regclass);


--
-- Name: sentry_authidentity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity ALTER COLUMN id SET DEFAULT nextval('public.sentry_authidentity_id_seq'::regclass);


--
-- Name: sentry_authprovider id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider ALTER COLUMN id SET DEFAULT nextval('public.sentry_authprovider_id_seq'::regclass);


--
-- Name: sentry_authprovider_default_teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider_default_teams ALTER COLUMN id SET DEFAULT nextval('public.sentry_authprovider_default_teams_id_seq'::regclass);


--
-- Name: sentry_broadcast id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcast ALTER COLUMN id SET DEFAULT nextval('public.sentry_broadcast_id_seq'::regclass);


--
-- Name: sentry_broadcastseen id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcastseen ALTER COLUMN id SET DEFAULT nextval('public.sentry_broadcastseen_id_seq'::regclass);


--
-- Name: sentry_commit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commit ALTER COLUMN id SET DEFAULT nextval('public.sentry_commit_id_seq'::regclass);


--
-- Name: sentry_commitauthor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitauthor ALTER COLUMN id SET DEFAULT nextval('public.sentry_commitauthor_id_seq'::regclass);


--
-- Name: sentry_commitfilechange id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitfilechange ALTER COLUMN id SET DEFAULT nextval('public.sentry_commitfilechange_id_seq'::regclass);


--
-- Name: sentry_dashboard id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_dashboard ALTER COLUMN id SET DEFAULT nextval('public.sentry_dashboard_id_seq'::regclass);


--
-- Name: sentry_deletedorganization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedorganization ALTER COLUMN id SET DEFAULT nextval('public.sentry_deletedorganization_id_seq'::regclass);


--
-- Name: sentry_deletedproject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedproject ALTER COLUMN id SET DEFAULT nextval('public.sentry_deletedproject_id_seq'::regclass);


--
-- Name: sentry_deletedteam id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedteam ALTER COLUMN id SET DEFAULT nextval('public.sentry_deletedteam_id_seq'::regclass);


--
-- Name: sentry_deploy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deploy ALTER COLUMN id SET DEFAULT nextval('public.sentry_deploy_id_seq'::regclass);


--
-- Name: sentry_discoversavedquery id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedquery ALTER COLUMN id SET DEFAULT nextval('public.sentry_discoversavedquery_id_seq'::regclass);


--
-- Name: sentry_discoversavedqueryproject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedqueryproject ALTER COLUMN id SET DEFAULT nextval('public.sentry_discoversavedqueryproject_id_seq'::regclass);


--
-- Name: sentry_distribution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_distribution ALTER COLUMN id SET DEFAULT nextval('public.sentry_distribution_id_seq'::regclass);


--
-- Name: sentry_email id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_email ALTER COLUMN id SET DEFAULT nextval('public.sentry_email_id_seq'::regclass);


--
-- Name: sentry_environment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environment ALTER COLUMN id SET DEFAULT nextval('public.sentry_environment_id_seq'::regclass);


--
-- Name: sentry_environmentproject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentproject ALTER COLUMN id SET DEFAULT nextval('public.sentry_environmentproject_id_seq'::regclass);


--
-- Name: sentry_environmentrelease id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentrelease ALTER COLUMN id SET DEFAULT nextval('public.sentry_environmentrelease_id_seq'::regclass);


--
-- Name: sentry_eventattachment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventattachment ALTER COLUMN id SET DEFAULT nextval('public.sentry_eventattachment_id_seq'::regclass);


--
-- Name: sentry_eventmapping id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventmapping ALTER COLUMN id SET DEFAULT nextval('public.sentry_eventmapping_id_seq'::regclass);


--
-- Name: sentry_eventprocessingissue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventprocessingissue ALTER COLUMN id SET DEFAULT nextval('public.sentry_eventprocessingissue_id_seq'::regclass);


--
-- Name: sentry_eventtag id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventtag ALTER COLUMN id SET DEFAULT nextval('public.sentry_eventtag_id_seq'::regclass);


--
-- Name: sentry_eventuser id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventuser ALTER COLUMN id SET DEFAULT nextval('public.sentry_eventuser_id_seq'::regclass);


--
-- Name: sentry_externalissue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_externalissue ALTER COLUMN id SET DEFAULT nextval('public.sentry_externalissue_id_seq'::regclass);


--
-- Name: sentry_featureadoption id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_featureadoption ALTER COLUMN id SET DEFAULT nextval('public.sentry_featureadoption_id_seq'::regclass);


--
-- Name: sentry_file id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_file ALTER COLUMN id SET DEFAULT nextval('public.sentry_file_id_seq'::regclass);


--
-- Name: sentry_fileblob id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblob ALTER COLUMN id SET DEFAULT nextval('public.sentry_fileblob_id_seq'::regclass);


--
-- Name: sentry_fileblobindex id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobindex ALTER COLUMN id SET DEFAULT nextval('public.sentry_fileblobindex_id_seq'::regclass);


--
-- Name: sentry_fileblobowner id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobowner ALTER COLUMN id SET DEFAULT nextval('public.sentry_fileblobowner_id_seq'::regclass);


--
-- Name: sentry_filterkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filterkey ALTER COLUMN id SET DEFAULT nextval('public.sentry_filterkey_id_seq'::regclass);


--
-- Name: sentry_filtervalue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filtervalue ALTER COLUMN id SET DEFAULT nextval('public.sentry_filtervalue_id_seq'::regclass);


--
-- Name: sentry_groupasignee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupasignee_id_seq'::regclass);


--
-- Name: sentry_groupbookmark id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupbookmark_id_seq'::regclass);


--
-- Name: sentry_groupcommitresolution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupcommitresolution ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupcommitresolution_id_seq'::regclass);


--
-- Name: sentry_groupedmessage id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupedmessage ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupedmessage_id_seq'::regclass);


--
-- Name: sentry_groupemailthread id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupemailthread ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupemailthread_id_seq'::regclass);


--
-- Name: sentry_groupenvironment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupenvironment ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupenvironment_id_seq'::regclass);


--
-- Name: sentry_grouphash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouphash ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouphash_id_seq'::regclass);


--
-- Name: sentry_grouplink id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouplink ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouplink_id_seq'::regclass);


--
-- Name: sentry_groupmeta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupmeta ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupmeta_id_seq'::regclass);


--
-- Name: sentry_groupredirect id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupredirect ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupredirect_id_seq'::regclass);


--
-- Name: sentry_grouprelease id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprelease ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouprelease_id_seq'::regclass);


--
-- Name: sentry_groupresolution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupresolution ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupresolution_id_seq'::regclass);


--
-- Name: sentry_grouprulestatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouprulestatus_id_seq'::regclass);


--
-- Name: sentry_groupseen id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupseen_id_seq'::regclass);


--
-- Name: sentry_groupshare id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupshare_id_seq'::regclass);


--
-- Name: sentry_groupsnooze id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsnooze ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupsnooze_id_seq'::regclass);


--
-- Name: sentry_groupsubscription id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription ALTER COLUMN id SET DEFAULT nextval('public.sentry_groupsubscription_id_seq'::regclass);


--
-- Name: sentry_grouptagkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptagkey ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouptagkey_id_seq'::regclass);


--
-- Name: sentry_grouptombstone id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptombstone ALTER COLUMN id SET DEFAULT nextval('public.sentry_grouptombstone_id_seq'::regclass);


--
-- Name: sentry_hipchat_ac_tenant_organizations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_organizations ALTER COLUMN id SET DEFAULT nextval('public.sentry_hipchat_ac_tenant_organizations_id_seq'::regclass);


--
-- Name: sentry_hipchat_ac_tenant_projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_projects ALTER COLUMN id SET DEFAULT nextval('public.sentry_hipchat_ac_tenant_projects_id_seq'::regclass);


--
-- Name: sentry_identity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity ALTER COLUMN id SET DEFAULT nextval('public.sentry_identity_id_seq'::regclass);


--
-- Name: sentry_identityprovider id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identityprovider ALTER COLUMN id SET DEFAULT nextval('public.sentry_identityprovider_id_seq'::regclass);


--
-- Name: sentry_integration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integration ALTER COLUMN id SET DEFAULT nextval('public.sentry_integration_id_seq'::regclass);


--
-- Name: sentry_integrationexternalproject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integrationexternalproject ALTER COLUMN id SET DEFAULT nextval('public.sentry_integrationexternalproject_id_seq'::regclass);


--
-- Name: sentry_latestrelease id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_latestrelease ALTER COLUMN id SET DEFAULT nextval('public.sentry_latestrelease_id_seq'::regclass);


--
-- Name: sentry_lostpasswordhash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_lostpasswordhash ALTER COLUMN id SET DEFAULT nextval('public.sentry_lostpasswordhash_id_seq'::regclass);


--
-- Name: sentry_message id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_message ALTER COLUMN id SET DEFAULT nextval('public.sentry_message_id_seq'::regclass);


--
-- Name: sentry_messagefiltervalue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_messagefiltervalue ALTER COLUMN id SET DEFAULT nextval('public.sentry_messagefiltervalue_id_seq'::regclass);


--
-- Name: sentry_messageindex id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_messageindex ALTER COLUMN id SET DEFAULT nextval('public.sentry_messageindex_id_seq'::regclass);


--
-- Name: sentry_monitor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitor ALTER COLUMN id SET DEFAULT nextval('public.sentry_monitor_id_seq'::regclass);


--
-- Name: sentry_monitorcheckin id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorcheckin ALTER COLUMN id SET DEFAULT nextval('public.sentry_monitorcheckin_id_seq'::regclass);


--
-- Name: sentry_monitorlocation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorlocation ALTER COLUMN id SET DEFAULT nextval('public.sentry_monitorlocation_id_seq'::regclass);


--
-- Name: sentry_option id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_option ALTER COLUMN id SET DEFAULT nextval('public.sentry_option_id_seq'::regclass);


--
-- Name: sentry_organization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organization ALTER COLUMN id SET DEFAULT nextval('public.sentry_organization_id_seq'::regclass);


--
-- Name: sentry_organizationaccessrequest id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationaccessrequest ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationaccessrequest_id_seq'::regclass);


--
-- Name: sentry_organizationavatar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationavatar_id_seq'::regclass);


--
-- Name: sentry_organizationintegration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationintegration ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationintegration_id_seq'::regclass);


--
-- Name: sentry_organizationmember id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationmember_id_seq'::regclass);


--
-- Name: sentry_organizationmember_teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember_teams ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationmember_teams_id_seq'::regclass);


--
-- Name: sentry_organizationonboardingtask id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationonboardingtask ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationonboardingtask_id_seq'::regclass);


--
-- Name: sentry_organizationoptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationoptions ALTER COLUMN id SET DEFAULT nextval('public.sentry_organizationoptions_id_seq'::regclass);


--
-- Name: sentry_platformexternalissue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_platformexternalissue ALTER COLUMN id SET DEFAULT nextval('public.sentry_platformexternalissue_id_seq'::regclass);


--
-- Name: sentry_processingissue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_processingissue ALTER COLUMN id SET DEFAULT nextval('public.sentry_processingissue_id_seq'::regclass);


--
-- Name: sentry_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_project ALTER COLUMN id SET DEFAULT nextval('public.sentry_project_id_seq'::regclass);


--
-- Name: sentry_projectavatar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectavatar_id_seq'::regclass);


--
-- Name: sentry_projectbookmark id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectbookmark ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectbookmark_id_seq'::regclass);


--
-- Name: sentry_projectcficachefile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectcficachefile_id_seq'::regclass);


--
-- Name: sentry_projectcounter id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcounter ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectcounter_id_seq'::regclass);


--
-- Name: sentry_projectdsymfile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectdsymfile ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectdsymfile_id_seq'::regclass);


--
-- Name: sentry_projectintegration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectintegration ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectintegration_id_seq'::regclass);


--
-- Name: sentry_projectkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectkey ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectkey_id_seq'::regclass);


--
-- Name: sentry_projectoptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectoptions ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectoptions_id_seq'::regclass);


--
-- Name: sentry_projectownership id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectownership ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectownership_id_seq'::regclass);


--
-- Name: sentry_projectplatform id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectplatform ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectplatform_id_seq'::regclass);


--
-- Name: sentry_projectredirect id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectredirect ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectredirect_id_seq'::regclass);


--
-- Name: sentry_projectsymcachefile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectsymcachefile_id_seq'::regclass);


--
-- Name: sentry_projectteam id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectteam ALTER COLUMN id SET DEFAULT nextval('public.sentry_projectteam_id_seq'::regclass);


--
-- Name: sentry_promptsactivity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_promptsactivity ALTER COLUMN id SET DEFAULT nextval('public.sentry_promptsactivity_id_seq'::regclass);


--
-- Name: sentry_pull_request id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pull_request ALTER COLUMN id SET DEFAULT nextval('public.sentry_pull_request_id_seq'::regclass);


--
-- Name: sentry_pullrequest_commit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pullrequest_commit ALTER COLUMN id SET DEFAULT nextval('public.sentry_pullrequest_commit_id_seq'::regclass);


--
-- Name: sentry_rawevent id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rawevent ALTER COLUMN id SET DEFAULT nextval('public.sentry_rawevent_id_seq'::regclass);


--
-- Name: sentry_recentsearch id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_recentsearch ALTER COLUMN id SET DEFAULT nextval('public.sentry_recentsearch_id_seq'::regclass);


--
-- Name: sentry_relay id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_relay ALTER COLUMN id SET DEFAULT nextval('public.sentry_relay_id_seq'::regclass);


--
-- Name: sentry_release id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release ALTER COLUMN id SET DEFAULT nextval('public.sentry_release_id_seq'::regclass);


--
-- Name: sentry_release_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release_project ALTER COLUMN id SET DEFAULT nextval('public.sentry_release_project_id_seq'::regclass);


--
-- Name: sentry_releasecommit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit ALTER COLUMN id SET DEFAULT nextval('public.sentry_releasecommit_id_seq'::regclass);


--
-- Name: sentry_releasefile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile ALTER COLUMN id SET DEFAULT nextval('public.sentry_releasefile_id_seq'::regclass);


--
-- Name: sentry_releaseheadcommit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseheadcommit ALTER COLUMN id SET DEFAULT nextval('public.sentry_releaseheadcommit_id_seq'::regclass);


--
-- Name: sentry_releaseprojectenvironment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment ALTER COLUMN id SET DEFAULT nextval('public.sentry_releaseprojectenvironment_id_seq'::regclass);


--
-- Name: sentry_repository id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_repository ALTER COLUMN id SET DEFAULT nextval('public.sentry_repository_id_seq'::regclass);


--
-- Name: sentry_reprocessingreport id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_reprocessingreport ALTER COLUMN id SET DEFAULT nextval('public.sentry_reprocessingreport_id_seq'::regclass);


--
-- Name: sentry_rule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rule ALTER COLUMN id SET DEFAULT nextval('public.sentry_rule_id_seq'::regclass);


--
-- Name: sentry_savedsearch id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch ALTER COLUMN id SET DEFAULT nextval('public.sentry_savedsearch_id_seq'::regclass);


--
-- Name: sentry_savedsearch_userdefault id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault ALTER COLUMN id SET DEFAULT nextval('public.sentry_savedsearch_userdefault_id_seq'::regclass);


--
-- Name: sentry_scheduleddeletion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduleddeletion ALTER COLUMN id SET DEFAULT nextval('public.sentry_scheduleddeletion_id_seq'::regclass);


--
-- Name: sentry_scheduledjob id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduledjob ALTER COLUMN id SET DEFAULT nextval('public.sentry_scheduledjob_id_seq'::regclass);


--
-- Name: sentry_sentryapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp ALTER COLUMN id SET DEFAULT nextval('public.sentry_sentryapp_id_seq'::regclass);


--
-- Name: sentry_sentryappavatar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar ALTER COLUMN id SET DEFAULT nextval('public.sentry_sentryappavatar_id_seq'::regclass);


--
-- Name: sentry_sentryappcomponent id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappcomponent ALTER COLUMN id SET DEFAULT nextval('public.sentry_sentryappcomponent_id_seq'::regclass);


--
-- Name: sentry_sentryappinstallation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation ALTER COLUMN id SET DEFAULT nextval('public.sentry_sentryappinstallation_id_seq'::regclass);


--
-- Name: sentry_servicehook id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehook ALTER COLUMN id SET DEFAULT nextval('public.sentry_servicehook_id_seq'::regclass);


--
-- Name: sentry_servicehookproject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehookproject ALTER COLUMN id SET DEFAULT nextval('public.sentry_servicehookproject_id_seq'::regclass);


--
-- Name: sentry_team id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_team ALTER COLUMN id SET DEFAULT nextval('public.sentry_team_id_seq'::regclass);


--
-- Name: sentry_teamavatar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar ALTER COLUMN id SET DEFAULT nextval('public.sentry_teamavatar_id_seq'::regclass);


--
-- Name: sentry_useravatar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar ALTER COLUMN id SET DEFAULT nextval('public.sentry_useravatar_id_seq'::regclass);


--
-- Name: sentry_useremail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useremail ALTER COLUMN id SET DEFAULT nextval('public.sentry_useremail_id_seq'::regclass);


--
-- Name: sentry_userip id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userip ALTER COLUMN id SET DEFAULT nextval('public.sentry_userip_id_seq'::regclass);


--
-- Name: sentry_useroption id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption ALTER COLUMN id SET DEFAULT nextval('public.sentry_useroption_id_seq'::regclass);


--
-- Name: sentry_userpermission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userpermission ALTER COLUMN id SET DEFAULT nextval('public.sentry_userpermission_id_seq'::regclass);


--
-- Name: sentry_userreport id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport ALTER COLUMN id SET DEFAULT nextval('public.sentry_userreport_id_seq'::regclass);


--
-- Name: sentry_widget id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widget ALTER COLUMN id SET DEFAULT nextval('public.sentry_widget_id_seq'::regclass);


--
-- Name: sentry_widgetdatasource id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widgetdatasource ALTER COLUMN id SET DEFAULT nextval('public.sentry_widgetdatasource_id_seq'::regclass);


--
-- Name: social_auth_usersocialauth id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_auth_usersocialauth ALTER COLUMN id SET DEFAULT nextval('public.social_auth_usersocialauth_id_seq'::regclass);


--
-- Name: south_migrationhistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.south_migrationhistory ALTER COLUMN id SET DEFAULT nextval('public.south_migrationhistory_id_seq'::regclass);


--
-- Name: tagstore_eventtag id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_eventtag ALTER COLUMN id SET DEFAULT nextval('public.tagstore_eventtag_id_seq'::regclass);


--
-- Name: tagstore_grouptagkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagkey ALTER COLUMN id SET DEFAULT nextval('public.tagstore_grouptagkey_id_seq'::regclass);


--
-- Name: tagstore_grouptagvalue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagvalue ALTER COLUMN id SET DEFAULT nextval('public.tagstore_grouptagvalue_id_seq'::regclass);


--
-- Name: tagstore_tagkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagkey ALTER COLUMN id SET DEFAULT nextval('public.tagstore_tagkey_id_seq'::regclass);


--
-- Name: tagstore_tagvalue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagvalue ALTER COLUMN id SET DEFAULT nextval('public.tagstore_tagvalue_id_seq'::regclass);


--
-- Data for Name: auth_authenticator; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_authenticator (id, user_id, created_at, last_used_at, type, config) FROM stdin;
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can add permission	2	add_permission
5	Can change permission	2	change_permission
6	Can delete permission	2	delete_permission
7	Can add group	3	add_group
8	Can change group	3	change_group
9	Can delete group	3	delete_group
10	Can add content type	4	add_contenttype
11	Can change content type	4	change_contenttype
12	Can delete content type	4	delete_contenttype
13	Can add session	5	add_session
14	Can change session	5	change_session
15	Can delete session	5	delete_session
16	Can add site	6	add_site
17	Can change site	6	change_site
18	Can delete site	6	delete_site
19	Can add migration history	7	add_migrationhistory
20	Can change migration history	7	change_migrationhistory
21	Can delete migration history	7	delete_migrationhistory
22	Can add activity	8	add_activity
23	Can change activity	8	change_activity
24	Can delete activity	8	delete_activity
25	Can add api application	9	add_apiapplication
26	Can change api application	9	change_apiapplication
27	Can delete api application	9	delete_apiapplication
28	Can add api authorization	10	add_apiauthorization
29	Can change api authorization	10	change_apiauthorization
30	Can delete api authorization	10	delete_apiauthorization
31	Can add api grant	11	add_apigrant
32	Can change api grant	11	change_apigrant
33	Can delete api grant	11	delete_apigrant
34	Can add api key	12	add_apikey
35	Can change api key	12	change_apikey
36	Can delete api key	12	delete_apikey
37	Can add api token	13	add_apitoken
38	Can change api token	13	change_apitoken
39	Can delete api token	13	delete_apitoken
40	Can add assistant activity	14	add_assistantactivity
41	Can change assistant activity	14	change_assistantactivity
42	Can delete assistant activity	14	delete_assistantactivity
43	Can add audit log entry	15	add_auditlogentry
44	Can change audit log entry	15	change_auditlogentry
45	Can delete audit log entry	15	delete_auditlogentry
46	Can add authenticator	16	add_authenticator
47	Can change authenticator	16	change_authenticator
48	Can delete authenticator	16	delete_authenticator
49	Can add auth identity	17	add_authidentity
50	Can change auth identity	17	change_authidentity
51	Can delete auth identity	17	delete_authidentity
52	Can add auth provider	18	add_authprovider
53	Can change auth provider	18	change_authprovider
54	Can delete auth provider	18	delete_authprovider
55	Can add broadcast	19	add_broadcast
56	Can change broadcast	19	change_broadcast
57	Can delete broadcast	19	delete_broadcast
58	Can add broadcast seen	20	add_broadcastseen
59	Can change broadcast seen	20	change_broadcastseen
60	Can delete broadcast seen	20	delete_broadcastseen
61	Can add commit	21	add_commit
62	Can change commit	21	change_commit
63	Can delete commit	21	delete_commit
64	Can add commit author	22	add_commitauthor
65	Can change commit author	22	change_commitauthor
66	Can delete commit author	22	delete_commitauthor
67	Can add commit file change	23	add_commitfilechange
68	Can change commit file change	23	change_commitfilechange
69	Can delete commit file change	23	delete_commitfilechange
70	Can add counter	24	add_counter
71	Can change counter	24	change_counter
72	Can delete counter	24	delete_counter
73	Can add dashboard	25	add_dashboard
74	Can change dashboard	25	change_dashboard
75	Can delete dashboard	25	delete_dashboard
76	Can add file blob	26	add_fileblob
77	Can change file blob	26	change_fileblob
78	Can delete file blob	26	delete_fileblob
79	Can add file	27	add_file
80	Can change file	27	change_file
81	Can delete file	27	delete_file
82	Can add file blob index	28	add_fileblobindex
83	Can change file blob index	28	change_fileblobindex
84	Can delete file blob index	28	delete_fileblobindex
85	Can add file blob owner	29	add_fileblobowner
86	Can change file blob owner	29	change_fileblobowner
87	Can delete file blob owner	29	delete_fileblobowner
88	Can add project debug file	30	add_projectdebugfile
89	Can change project debug file	30	change_projectdebugfile
90	Can delete project debug file	30	delete_projectdebugfile
91	Can add project sym cache file	31	add_projectsymcachefile
92	Can change project sym cache file	31	change_projectsymcachefile
93	Can delete project sym cache file	31	delete_projectsymcachefile
94	Can add project cfi cache file	32	add_projectcficachefile
95	Can change project cfi cache file	32	change_projectcficachefile
96	Can delete project cfi cache file	32	delete_projectcficachefile
97	Can add deleted organization	33	add_deletedorganization
98	Can change deleted organization	33	change_deletedorganization
99	Can delete deleted organization	33	delete_deletedorganization
100	Can add deleted project	34	add_deletedproject
101	Can change deleted project	34	change_deletedproject
102	Can delete deleted project	34	delete_deletedproject
103	Can add deleted team	35	add_deletedteam
104	Can change deleted team	35	change_deletedteam
105	Can delete deleted team	35	delete_deletedteam
106	Can add deploy	36	add_deploy
107	Can change deploy	36	change_deploy
108	Can delete deploy	36	delete_deploy
109	Can add discover saved query project	37	add_discoversavedqueryproject
110	Can change discover saved query project	37	change_discoversavedqueryproject
111	Can delete discover saved query project	37	delete_discoversavedqueryproject
112	Can add discover saved query	38	add_discoversavedquery
113	Can change discover saved query	38	change_discoversavedquery
114	Can delete discover saved query	38	delete_discoversavedquery
115	Can add distribution	39	add_distribution
116	Can change distribution	39	change_distribution
117	Can delete distribution	39	delete_distribution
118	Can add email	40	add_email
119	Can change email	40	change_email
120	Can delete email	40	delete_email
121	Can add environment project	41	add_environmentproject
122	Can change environment project	41	change_environmentproject
123	Can delete environment project	41	delete_environmentproject
124	Can add environment	42	add_environment
125	Can change environment	42	change_environment
126	Can delete environment	42	delete_environment
127	Can add message	43	add_event
128	Can change message	43	change_event
129	Can delete message	43	delete_event
130	Can add event attachment	44	add_eventattachment
131	Can change event attachment	44	change_eventattachment
132	Can delete event attachment	44	delete_eventattachment
133	Can add event mapping	45	add_eventmapping
134	Can change event mapping	45	change_eventmapping
135	Can delete event mapping	45	delete_eventmapping
136	Can add event user	46	add_eventuser
137	Can change event user	46	change_eventuser
138	Can delete event user	46	delete_eventuser
139	Can add external issue	47	add_externalissue
140	Can change external issue	47	change_externalissue
141	Can delete external issue	47	delete_externalissue
142	Can add feature adoption	48	add_featureadoption
143	Can change feature adoption	48	change_featureadoption
144	Can delete feature adoption	48	delete_featureadoption
145	Can add grouped message	49	add_group
146	Can change grouped message	49	change_group
147	Can delete grouped message	49	delete_group
148	Can view	49	can_view
149	Can add group assignee	50	add_groupassignee
150	Can change group assignee	50	change_groupassignee
151	Can delete group assignee	50	delete_groupassignee
152	Can add group bookmark	51	add_groupbookmark
153	Can change group bookmark	51	change_groupbookmark
154	Can delete group bookmark	51	delete_groupbookmark
155	Can add group commit resolution	52	add_groupcommitresolution
156	Can change group commit resolution	52	change_groupcommitresolution
157	Can delete group commit resolution	52	delete_groupcommitresolution
158	Can add group email thread	53	add_groupemailthread
159	Can change group email thread	53	change_groupemailthread
160	Can delete group email thread	53	delete_groupemailthread
161	Can add group environment	54	add_groupenvironment
162	Can change group environment	54	change_groupenvironment
163	Can delete group environment	54	delete_groupenvironment
164	Can add group hash	55	add_grouphash
165	Can change group hash	55	change_grouphash
166	Can delete group hash	55	delete_grouphash
167	Can add group link	56	add_grouplink
168	Can change group link	56	change_grouplink
169	Can delete group link	56	delete_grouplink
170	Can add group meta	57	add_groupmeta
171	Can change group meta	57	change_groupmeta
172	Can delete group meta	57	delete_groupmeta
173	Can add group redirect	58	add_groupredirect
174	Can change group redirect	58	change_groupredirect
175	Can delete group redirect	58	delete_groupredirect
176	Can add group release	59	add_grouprelease
177	Can change group release	59	change_grouprelease
178	Can delete group release	59	delete_grouprelease
179	Can add group resolution	60	add_groupresolution
180	Can change group resolution	60	change_groupresolution
181	Can delete group resolution	60	delete_groupresolution
182	Can add group rule status	61	add_grouprulestatus
183	Can change group rule status	61	change_grouprulestatus
184	Can delete group rule status	61	delete_grouprulestatus
185	Can add group seen	62	add_groupseen
186	Can change group seen	62	change_groupseen
187	Can delete group seen	62	delete_groupseen
188	Can add group share	63	add_groupshare
189	Can change group share	63	change_groupshare
190	Can delete group share	63	delete_groupshare
191	Can add group snooze	64	add_groupsnooze
192	Can change group snooze	64	change_groupsnooze
193	Can delete group snooze	64	delete_groupsnooze
194	Can add group subscription	65	add_groupsubscription
195	Can change group subscription	65	change_groupsubscription
196	Can delete group subscription	65	delete_groupsubscription
197	Can add group tombstone	66	add_grouptombstone
198	Can change group tombstone	66	change_grouptombstone
199	Can delete group tombstone	66	delete_grouptombstone
200	Can add identity provider	67	add_identityprovider
201	Can change identity provider	67	change_identityprovider
202	Can delete identity provider	67	delete_identityprovider
203	Can add identity	68	add_identity
204	Can change identity	68	change_identity
205	Can delete identity	68	delete_identity
206	Can add integration external project	69	add_integrationexternalproject
207	Can change integration external project	69	change_integrationexternalproject
208	Can delete integration external project	69	delete_integrationexternalproject
209	Can add organization integration	70	add_organizationintegration
210	Can change organization integration	70	change_organizationintegration
211	Can delete organization integration	70	delete_organizationintegration
212	Can add project integration	71	add_projectintegration
213	Can change project integration	71	change_projectintegration
214	Can delete project integration	71	delete_projectintegration
215	Can add integration	72	add_integration
216	Can change integration	72	change_integration
217	Can delete integration	72	delete_integration
218	Can add latest release	73	add_latestrelease
219	Can change latest release	73	change_latestrelease
220	Can delete latest release	73	delete_latestrelease
221	Can add lost password hash	74	add_lostpasswordhash
222	Can change lost password hash	74	change_lostpasswordhash
223	Can delete lost password hash	74	delete_lostpasswordhash
224	Can add monitor	75	add_monitor
225	Can change monitor	75	change_monitor
226	Can delete monitor	75	delete_monitor
227	Can add monitor check in	76	add_monitorcheckin
228	Can change monitor check in	76	change_monitorcheckin
229	Can delete monitor check in	76	delete_monitorcheckin
230	Can add monitor location	77	add_monitorlocation
231	Can change monitor location	77	change_monitorlocation
232	Can delete monitor location	77	delete_monitorlocation
233	Can add option	78	add_option
234	Can change option	78	change_option
235	Can delete option	78	delete_option
236	Can add organization	79	add_organization
237	Can change organization	79	change_organization
238	Can delete organization	79	delete_organization
239	Can add organization access request	80	add_organizationaccessrequest
240	Can change organization access request	80	change_organizationaccessrequest
241	Can delete organization access request	80	delete_organizationaccessrequest
242	Can add organization avatar	81	add_organizationavatar
243	Can change organization avatar	81	change_organizationavatar
244	Can delete organization avatar	81	delete_organizationavatar
245	Can add organization member team	82	add_organizationmemberteam
246	Can change organization member team	82	change_organizationmemberteam
247	Can delete organization member team	82	delete_organizationmemberteam
248	Can add organization member	83	add_organizationmember
249	Can change organization member	83	change_organizationmember
250	Can delete organization member	83	delete_organizationmember
251	Can add organization onboarding task	84	add_organizationonboardingtask
252	Can change organization onboarding task	84	change_organizationonboardingtask
253	Can delete organization onboarding task	84	delete_organizationonboardingtask
254	Can add organization option	85	add_organizationoption
255	Can change organization option	85	change_organizationoption
256	Can delete organization option	85	delete_organizationoption
257	Can add platform external issue	86	add_platformexternalissue
258	Can change platform external issue	86	change_platformexternalissue
259	Can delete platform external issue	86	delete_platformexternalissue
260	Can add processing issue	87	add_processingissue
261	Can change processing issue	87	change_processingissue
262	Can delete processing issue	87	delete_processingissue
263	Can add event processing issue	88	add_eventprocessingissue
264	Can change event processing issue	88	change_eventprocessingissue
265	Can delete event processing issue	88	delete_eventprocessingissue
266	Can add project team	89	add_projectteam
267	Can change project team	89	change_projectteam
268	Can delete project team	89	delete_projectteam
269	Can add project	90	add_project
270	Can change project	90	change_project
271	Can delete project	90	delete_project
272	Can add project avatar	91	add_projectavatar
273	Can change project avatar	91	change_projectavatar
274	Can delete project avatar	91	delete_projectavatar
275	Can add project bookmark	92	add_projectbookmark
276	Can change project bookmark	92	change_projectbookmark
277	Can delete project bookmark	92	delete_projectbookmark
278	Can add project key	93	add_projectkey
279	Can change project key	93	change_projectkey
280	Can delete project key	93	delete_projectkey
281	Can add project option	94	add_projectoption
282	Can change project option	94	change_projectoption
283	Can delete project option	94	delete_projectoption
284	Can add project ownership	95	add_projectownership
285	Can change project ownership	95	change_projectownership
286	Can delete project ownership	95	delete_projectownership
287	Can add project platform	96	add_projectplatform
288	Can change project platform	96	change_projectplatform
289	Can delete project platform	96	delete_projectplatform
290	Can add project redirect	97	add_projectredirect
291	Can change project redirect	97	change_projectredirect
292	Can delete project redirect	97	delete_projectredirect
293	Can add prompts activity	98	add_promptsactivity
294	Can change prompts activity	98	change_promptsactivity
295	Can delete prompts activity	98	delete_promptsactivity
296	Can add pull request	99	add_pullrequest
297	Can change pull request	99	change_pullrequest
298	Can delete pull request	99	delete_pullrequest
299	Can add pull request commit	100	add_pullrequestcommit
300	Can change pull request commit	100	change_pullrequestcommit
301	Can delete pull request commit	100	delete_pullrequestcommit
302	Can add raw event	101	add_rawevent
303	Can change raw event	101	change_rawevent
304	Can delete raw event	101	delete_rawevent
305	Can add recent search	102	add_recentsearch
306	Can change recent search	102	change_recentsearch
307	Can delete recent search	102	delete_recentsearch
308	Can add relay	103	add_relay
309	Can change relay	103	change_relay
310	Can delete relay	103	delete_relay
311	Can add release project	104	add_releaseproject
312	Can change release project	104	change_releaseproject
313	Can delete release project	104	delete_releaseproject
314	Can add release	105	add_release
315	Can change release	105	change_release
316	Can delete release	105	delete_release
317	Can add release commit	106	add_releasecommit
318	Can change release commit	106	change_releasecommit
319	Can delete release commit	106	delete_releasecommit
320	Can add release environment	107	add_releaseenvironment
321	Can change release environment	107	change_releaseenvironment
322	Can delete release environment	107	delete_releaseenvironment
323	Can add release file	108	add_releasefile
324	Can change release file	108	change_releasefile
325	Can delete release file	108	delete_releasefile
326	Can add release head commit	109	add_releaseheadcommit
327	Can change release head commit	109	change_releaseheadcommit
328	Can delete release head commit	109	delete_releaseheadcommit
329	Can add release project environment	110	add_releaseprojectenvironment
330	Can change release project environment	110	change_releaseprojectenvironment
331	Can delete release project environment	110	delete_releaseprojectenvironment
332	Can add repository	111	add_repository
333	Can change repository	111	change_repository
334	Can delete repository	111	delete_repository
335	Can add reprocessing report	112	add_reprocessingreport
336	Can change reprocessing report	112	change_reprocessingreport
337	Can delete reprocessing report	112	delete_reprocessingreport
338	Can add rule	113	add_rule
339	Can change rule	113	change_rule
340	Can delete rule	113	delete_rule
341	Can add saved search	114	add_savedsearch
342	Can change saved search	114	change_savedsearch
343	Can delete saved search	114	delete_savedsearch
344	Can add saved search user default	115	add_savedsearchuserdefault
345	Can change saved search user default	115	change_savedsearchuserdefault
346	Can delete saved search user default	115	delete_savedsearchuserdefault
347	Can add scheduled deletion	116	add_scheduleddeletion
348	Can change scheduled deletion	116	change_scheduleddeletion
349	Can delete scheduled deletion	116	delete_scheduleddeletion
350	Can add scheduled job	117	add_scheduledjob
351	Can change scheduled job	117	change_scheduledjob
352	Can delete scheduled job	117	delete_scheduledjob
353	Can add sentry app	118	add_sentryapp
354	Can change sentry app	118	change_sentryapp
355	Can delete sentry app	118	delete_sentryapp
356	Can add sentry app avatar	119	add_sentryappavatar
357	Can change sentry app avatar	119	change_sentryappavatar
358	Can delete sentry app avatar	119	delete_sentryappavatar
359	Can add sentry app component	120	add_sentryappcomponent
360	Can change sentry app component	120	change_sentryappcomponent
361	Can delete sentry app component	120	delete_sentryappcomponent
362	Can add sentry app installation	121	add_sentryappinstallation
363	Can change sentry app installation	121	change_sentryappinstallation
364	Can delete sentry app installation	121	delete_sentryappinstallation
365	Can add service hook project	122	add_servicehookproject
366	Can change service hook project	122	change_servicehookproject
367	Can delete service hook project	122	delete_servicehookproject
368	Can add service hook	123	add_servicehook
369	Can change service hook	123	change_servicehook
370	Can delete service hook	123	delete_servicehook
371	Can add team	124	add_team
372	Can change team	124	change_team
373	Can delete team	124	delete_team
374	Can add team avatar	125	add_teamavatar
375	Can change team avatar	125	change_teamavatar
376	Can delete team avatar	125	delete_teamavatar
377	Can add user	126	add_user
378	Can change user	126	change_user
379	Can delete user	126	delete_user
380	Can add user avatar	127	add_useravatar
381	Can change user avatar	127	change_useravatar
382	Can delete user avatar	127	delete_useravatar
383	Can add user email	128	add_useremail
384	Can change user email	128	change_useremail
385	Can delete user email	128	delete_useremail
386	Can add user ip	129	add_userip
387	Can change user ip	129	change_userip
388	Can delete user ip	129	delete_userip
389	Can add user option	130	add_useroption
390	Can change user option	130	change_useroption
391	Can delete user option	130	delete_useroption
392	Can add user permission	131	add_userpermission
393	Can change user permission	131	change_userpermission
394	Can delete user permission	131	delete_userpermission
395	Can add user report	132	add_userreport
396	Can change user report	132	change_userreport
397	Can delete user report	132	delete_userreport
398	Can add widget data source	133	add_widgetdatasource
399	Can change widget data source	133	change_widgetdatasource
400	Can delete widget data source	133	delete_widgetdatasource
401	Can add widget	134	add_widget
402	Can change widget	134	change_widget
403	Can delete widget	134	delete_widget
404	Can add event tag	135	add_eventtag
405	Can change event tag	135	change_eventtag
406	Can delete event tag	135	delete_eventtag
407	Can add group tag key	136	add_grouptagkey
408	Can change group tag key	136	change_grouptagkey
409	Can delete group tag key	136	delete_grouptagkey
410	Can add group tag value	137	add_grouptagvalue
411	Can change group tag value	137	change_grouptagvalue
412	Can delete group tag value	137	delete_grouptagvalue
413	Can add tag key	138	add_tagkey
414	Can change tag key	138	change_tagkey
415	Can delete tag key	138	delete_tagkey
416	Can add tag value	139	add_tagvalue
417	Can change tag value	139	change_tagvalue
418	Can delete tag value	139	delete_tagvalue
419	Can add node	140	add_node
420	Can change node	140	change_node
421	Can delete node	140	delete_node
422	Can add user social auth	141	add_usersocialauth
423	Can change user social auth	141	change_usersocialauth
424	Can delete user social auth	141	delete_usersocialauth
425	Can add tenant	142	add_tenant
426	Can change tenant	142	change_tenant
427	Can delete tenant	142	delete_tenant
428	Can add jira tenant	143	add_jiratenant
429	Can change jira tenant	143	change_jiratenant
430	Can delete jira tenant	143	delete_jiratenant
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user (password, last_login, id, username, first_name, email, is_staff, is_active, is_superuser, date_joined, is_managed, is_password_expired, last_password_change, session_nonce, last_active, flags, is_sentry_app) FROM stdin;
pbkdf2_sha256$12000$ANd8f5NXSh1i$gsFbLuMESNwJz57JKZyLOC/pox50LGic4afdl0KNggw=	2022-12-22 12:40:43.076183+00	1	sentry@itlabs.io		sentry@itlabs.io	t	t	t	2022-12-22 12:26:14.877917+00	f	f	2022-12-22 12:26:15.251155+00	\N	2022-12-22 12:40:43.189787+00	0	\N
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, user_id, content_type_id, object_id, object_repr, action_flag, change_message) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, name, app_label, model) FROM stdin;
1	log entry	admin	logentry
2	permission	auth	permission
3	group	auth	group
4	content type	contenttypes	contenttype
5	session	sessions	session
6	site	sites	site
7	migration history	south	migrationhistory
8	activity	sentry	activity
9	api application	sentry	apiapplication
10	api authorization	sentry	apiauthorization
11	api grant	sentry	apigrant
12	api key	sentry	apikey
13	api token	sentry	apitoken
14	assistant activity	sentry	assistantactivity
15	audit log entry	sentry	auditlogentry
16	authenticator	sentry	authenticator
17	auth identity	sentry	authidentity
18	auth provider	sentry	authprovider
19	broadcast	sentry	broadcast
20	broadcast seen	sentry	broadcastseen
21	commit	sentry	commit
22	commit author	sentry	commitauthor
23	commit file change	sentry	commitfilechange
24	counter	sentry	counter
25	dashboard	sentry	dashboard
26	file blob	sentry	fileblob
27	file	sentry	file
28	file blob index	sentry	fileblobindex
29	file blob owner	sentry	fileblobowner
30	project debug file	sentry	projectdebugfile
31	project sym cache file	sentry	projectsymcachefile
32	project cfi cache file	sentry	projectcficachefile
33	deleted organization	sentry	deletedorganization
34	deleted project	sentry	deletedproject
35	deleted team	sentry	deletedteam
36	deploy	sentry	deploy
37	discover saved query project	sentry	discoversavedqueryproject
38	discover saved query	sentry	discoversavedquery
39	distribution	sentry	distribution
40	email	sentry	email
41	environment project	sentry	environmentproject
42	environment	sentry	environment
43	message	sentry	event
44	event attachment	sentry	eventattachment
45	event mapping	sentry	eventmapping
46	event user	sentry	eventuser
47	external issue	sentry	externalissue
48	feature adoption	sentry	featureadoption
49	grouped message	sentry	group
50	group assignee	sentry	groupassignee
51	group bookmark	sentry	groupbookmark
52	group commit resolution	sentry	groupcommitresolution
53	group email thread	sentry	groupemailthread
54	group environment	sentry	groupenvironment
55	group hash	sentry	grouphash
56	group link	sentry	grouplink
57	group meta	sentry	groupmeta
58	group redirect	sentry	groupredirect
59	group release	sentry	grouprelease
60	group resolution	sentry	groupresolution
61	group rule status	sentry	grouprulestatus
62	group seen	sentry	groupseen
63	group share	sentry	groupshare
64	group snooze	sentry	groupsnooze
65	group subscription	sentry	groupsubscription
66	group tombstone	sentry	grouptombstone
67	identity provider	sentry	identityprovider
68	identity	sentry	identity
69	integration external project	sentry	integrationexternalproject
70	organization integration	sentry	organizationintegration
71	project integration	sentry	projectintegration
72	integration	sentry	integration
73	latest release	sentry	latestrelease
74	lost password hash	sentry	lostpasswordhash
75	monitor	sentry	monitor
76	monitor check in	sentry	monitorcheckin
77	monitor location	sentry	monitorlocation
78	option	sentry	option
79	organization	sentry	organization
80	organization access request	sentry	organizationaccessrequest
81	organization avatar	sentry	organizationavatar
82	organization member team	sentry	organizationmemberteam
83	organization member	sentry	organizationmember
84	organization onboarding task	sentry	organizationonboardingtask
85	organization option	sentry	organizationoption
86	platform external issue	sentry	platformexternalissue
87	processing issue	sentry	processingissue
88	event processing issue	sentry	eventprocessingissue
89	project team	sentry	projectteam
90	project	sentry	project
91	project avatar	sentry	projectavatar
92	project bookmark	sentry	projectbookmark
93	project key	sentry	projectkey
94	project option	sentry	projectoption
95	project ownership	sentry	projectownership
96	project platform	sentry	projectplatform
97	project redirect	sentry	projectredirect
98	prompts activity	sentry	promptsactivity
99	pull request	sentry	pullrequest
100	pull request commit	sentry	pullrequestcommit
101	raw event	sentry	rawevent
102	recent search	sentry	recentsearch
103	relay	sentry	relay
104	release project	sentry	releaseproject
105	release	sentry	release
106	release commit	sentry	releasecommit
107	release environment	sentry	releaseenvironment
108	release file	sentry	releasefile
109	release head commit	sentry	releaseheadcommit
110	release project environment	sentry	releaseprojectenvironment
111	repository	sentry	repository
112	reprocessing report	sentry	reprocessingreport
113	rule	sentry	rule
114	saved search	sentry	savedsearch
115	saved search user default	sentry	savedsearchuserdefault
116	scheduled deletion	sentry	scheduleddeletion
117	scheduled job	sentry	scheduledjob
118	sentry app	sentry	sentryapp
119	sentry app avatar	sentry	sentryappavatar
120	sentry app component	sentry	sentryappcomponent
121	sentry app installation	sentry	sentryappinstallation
122	service hook project	sentry	servicehookproject
123	service hook	sentry	servicehook
124	team	sentry	team
125	team avatar	sentry	teamavatar
126	user	sentry	user
127	user avatar	sentry	useravatar
128	user email	sentry	useremail
129	user ip	sentry	userip
130	user option	sentry	useroption
131	user permission	sentry	userpermission
132	user report	sentry	userreport
133	widget data source	sentry	widgetdatasource
134	widget	sentry	widget
135	event tag	sentry	eventtag
136	group tag key	sentry	grouptagkey
137	group tag value	sentry	grouptagvalue
138	tag key	sentry	tagkey
139	tag value	sentry	tagvalue
140	node	nodestore	node
141	user social auth	social_auth	usersocialauth
142	tenant	hipchat_ac	tenant
143	jira tenant	jira_ac	jiratenant
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Data for Name: django_site; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_site (id, domain, name) FROM stdin;
1	example.com	example.com
\.


--
-- Data for Name: jira_ac_tenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jira_ac_tenant (id, organization_id, client_key, secret, base_url, public_key) FROM stdin;
\.


--
-- Data for Name: nodestore_node; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nodestore_node (id, data, "timestamp") FROM stdin;
\.


--
-- Data for Name: sentry_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_activity (id, project_id, group_id, type, ident, user_id, datetime, data) FROM stdin;
\.


--
-- Data for Name: sentry_apiapplication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_apiapplication (id, client_id, client_secret, owner_id, name, status, allowed_origins, redirect_uris, homepage_url, privacy_url, terms_url, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_apiauthorization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_apiauthorization (id, application_id, user_id, scopes, date_added, scope_list) FROM stdin;
\.


--
-- Data for Name: sentry_apigrant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_apigrant (id, user_id, application_id, code, expires_at, redirect_uri, scopes, scope_list) FROM stdin;
\.


--
-- Data for Name: sentry_apikey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_apikey (id, organization_id, label, key, scopes, status, date_added, allowed_origins, scope_list) FROM stdin;
\.


--
-- Data for Name: sentry_apitoken; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_apitoken (id, user_id, token, scopes, date_added, application_id, refresh_token, expires_at, scope_list) FROM stdin;
1	1	1685afd6688d4d92837fcd763453407ae082f0c4291f4e3aa72b25a159632f49	0	2022-12-22 12:41:20.645957+00	\N	\N	\N	{event:admin,event:read,member:read,org:read,project:read,project:releases,team:read,project:write,team:write,member:admin,org:write,team:admin,project:admin,org:admin}
\.


--
-- Data for Name: sentry_assistant_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_assistant_activity (id, user_id, guide_id, viewed_ts, dismissed_ts, useful) FROM stdin;
\.


--
-- Data for Name: sentry_auditlogentry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_auditlogentry (id, organization_id, actor_id, target_object, target_user_id, event, data, datetime, ip_address, actor_label, actor_key_id) FROM stdin;
\.


--
-- Data for Name: sentry_authidentity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_authidentity (id, user_id, auth_provider_id, ident, data, date_added, last_verified, last_synced) FROM stdin;
\.


--
-- Data for Name: sentry_authprovider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_authprovider (id, organization_id, provider, config, date_added, sync_time, last_sync, default_role, default_global_access, flags) FROM stdin;
\.


--
-- Data for Name: sentry_authprovider_default_teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_authprovider_default_teams (id, authprovider_id, team_id) FROM stdin;
\.


--
-- Data for Name: sentry_broadcast; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_broadcast (id, message, link, is_active, date_added, title, upstream_id, date_expires) FROM stdin;
\.


--
-- Data for Name: sentry_broadcastseen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_broadcastseen (id, broadcast_id, user_id, date_seen) FROM stdin;
\.


--
-- Data for Name: sentry_commit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_commit (id, organization_id, repository_id, key, date_added, author_id, message) FROM stdin;
\.


--
-- Data for Name: sentry_commitauthor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_commitauthor (id, organization_id, name, email, external_id) FROM stdin;
\.


--
-- Data for Name: sentry_commitfilechange; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_commitfilechange (id, organization_id, commit_id, filename, type) FROM stdin;
\.


--
-- Data for Name: sentry_dashboard; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_dashboard (id, title, created_by_id, organization_id, date_added, status) FROM stdin;
\.


--
-- Data for Name: sentry_deletedorganization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_deletedorganization (id, actor_label, actor_id, actor_key, ip_address, date_deleted, date_created, reason, name, slug) FROM stdin;
\.


--
-- Data for Name: sentry_deletedproject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_deletedproject (id, actor_label, actor_id, actor_key, ip_address, date_deleted, date_created, reason, slug, name, organization_id, organization_name, organization_slug, platform) FROM stdin;
\.


--
-- Data for Name: sentry_deletedteam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_deletedteam (id, actor_label, actor_id, actor_key, ip_address, date_deleted, date_created, reason, name, slug, organization_id, organization_name, organization_slug) FROM stdin;
\.


--
-- Data for Name: sentry_deploy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_deploy (id, organization_id, release_id, environment_id, date_finished, date_started, name, url, notified) FROM stdin;
\.


--
-- Data for Name: sentry_discoversavedquery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_discoversavedquery (id, organization_id, name, query, date_created, date_updated, created_by_id) FROM stdin;
\.


--
-- Data for Name: sentry_discoversavedqueryproject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_discoversavedqueryproject (id, project_id, discover_saved_query_id) FROM stdin;
\.


--
-- Data for Name: sentry_distribution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_distribution (id, organization_id, release_id, name, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_email; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_email (id, email, date_added) FROM stdin;
1	sentry@itlabs.io	2022-12-22 12:26:15.287481+00
\.


--
-- Data for Name: sentry_environment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_environment (id, project_id, name, date_added, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_environmentproject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_environmentproject (id, project_id, environment_id, is_hidden) FROM stdin;
\.


--
-- Data for Name: sentry_environmentrelease; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_environmentrelease (id, project_id, release_id, environment_id, first_seen, last_seen, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_eventattachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_eventattachment (id, project_id, group_id, event_id, file_id, name, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_eventmapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_eventmapping (id, project_id, group_id, event_id, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_eventprocessingissue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_eventprocessingissue (id, raw_event_id, processing_issue_id) FROM stdin;
\.


--
-- Data for Name: sentry_eventtag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_eventtag (id, project_id, event_id, key_id, value_id, date_added, group_id) FROM stdin;
\.


--
-- Data for Name: sentry_eventuser; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_eventuser (id, project_id, ident, email, username, ip_address, date_added, hash, name) FROM stdin;
\.


--
-- Data for Name: sentry_externalissue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_externalissue (id, organization_id, integration_id, key, date_added, title, description, metadata) FROM stdin;
\.


--
-- Data for Name: sentry_featureadoption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_featureadoption (id, organization_id, feature_id, date_completed, complete, applicable, data) FROM stdin;
\.


--
-- Data for Name: sentry_file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_file (id, name, path, type, size, "timestamp", checksum, headers, blob_id) FROM stdin;
\.


--
-- Data for Name: sentry_fileblob; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_fileblob (id, path, size, checksum, "timestamp") FROM stdin;
\.


--
-- Data for Name: sentry_fileblobindex; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_fileblobindex (id, file_id, blob_id, "offset") FROM stdin;
\.


--
-- Data for Name: sentry_fileblobowner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_fileblobowner (id, blob_id, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_filterkey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_filterkey (id, project_id, key, values_seen, label, status) FROM stdin;
\.


--
-- Data for Name: sentry_filtervalue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_filtervalue (id, key, value, project_id, times_seen, last_seen, first_seen, data) FROM stdin;
\.


--
-- Data for Name: sentry_groupasignee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupasignee (id, project_id, group_id, user_id, date_added, team_id) FROM stdin;
\.


--
-- Data for Name: sentry_groupbookmark; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupbookmark (id, project_id, group_id, user_id, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_groupcommitresolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupcommitresolution (id, group_id, commit_id, datetime) FROM stdin;
\.


--
-- Data for Name: sentry_groupedmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupedmessage (id, logger, level, message, view, status, times_seen, last_seen, first_seen, data, score, project_id, time_spent_total, time_spent_count, resolved_at, active_at, is_public, platform, num_comments, first_release_id, short_id) FROM stdin;
\.


--
-- Data for Name: sentry_groupemailthread; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupemailthread (id, email, project_id, group_id, msgid, date) FROM stdin;
\.


--
-- Data for Name: sentry_groupenvironment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupenvironment (id, group_id, environment_id, first_release_id, first_seen) FROM stdin;
\.


--
-- Data for Name: sentry_grouphash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouphash (id, project_id, hash, group_id, state, group_tombstone_id) FROM stdin;
\.


--
-- Data for Name: sentry_grouplink; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouplink (id, group_id, project_id, linked_type, linked_id, relationship, data, datetime) FROM stdin;
\.


--
-- Data for Name: sentry_groupmeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupmeta (id, group_id, key, value) FROM stdin;
\.


--
-- Data for Name: sentry_groupredirect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupredirect (id, group_id, previous_group_id) FROM stdin;
\.


--
-- Data for Name: sentry_grouprelease; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouprelease (id, project_id, group_id, release_id, environment, first_seen, last_seen) FROM stdin;
\.


--
-- Data for Name: sentry_groupresolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupresolution (id, group_id, release_id, datetime, status, type, actor_id) FROM stdin;
\.


--
-- Data for Name: sentry_grouprulestatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouprulestatus (id, project_id, rule_id, group_id, status, date_added, last_active) FROM stdin;
\.


--
-- Data for Name: sentry_groupseen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupseen (id, project_id, group_id, user_id, last_seen) FROM stdin;
\.


--
-- Data for Name: sentry_groupshare; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupshare (id, project_id, group_id, uuid, user_id, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_groupsnooze; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupsnooze (id, group_id, until, count, "window", user_count, user_window, state, actor_id) FROM stdin;
\.


--
-- Data for Name: sentry_groupsubscription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_groupsubscription (id, project_id, group_id, user_id, is_active, reason, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_grouptagkey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouptagkey (id, project_id, group_id, key, values_seen) FROM stdin;
\.


--
-- Data for Name: sentry_grouptombstone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_grouptombstone (id, previous_group_id, project_id, level, message, culprit, data, actor_id) FROM stdin;
\.


--
-- Data for Name: sentry_hipchat_ac_tenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_hipchat_ac_tenant (id, room_id, room_name, room_owner_id, room_owner_name, secret, homepage, token_url, capabilities_url, api_base_url, installed_from, auth_user_id) FROM stdin;
\.


--
-- Data for Name: sentry_hipchat_ac_tenant_organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_hipchat_ac_tenant_organizations (id, tenant_id, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_hipchat_ac_tenant_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_hipchat_ac_tenant_projects (id, tenant_id, project_id) FROM stdin;
\.


--
-- Data for Name: sentry_identity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_identity (id, idp_id, user_id, external_id, data, status, scopes, date_verified, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_identityprovider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_identityprovider (id, type, config, date_added, external_id) FROM stdin;
\.


--
-- Data for Name: sentry_integration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_integration (id, provider, external_id, name, metadata, date_added, status) FROM stdin;
\.


--
-- Data for Name: sentry_integrationexternalproject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_integrationexternalproject (id, organization_integration_id, date_added, name, external_id, resolved_status, unresolved_status) FROM stdin;
\.


--
-- Data for Name: sentry_latestrelease; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_latestrelease (id, repository_id, environment_id, release_id, deploy_id, commit_id) FROM stdin;
\.


--
-- Data for Name: sentry_lostpasswordhash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_lostpasswordhash (id, user_id, hash, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_message (id, message, datetime, data, group_id, message_id, project_id, time_spent, platform) FROM stdin;
\.


--
-- Data for Name: sentry_messagefiltervalue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_messagefiltervalue (id, group_id, times_seen, key, value, project_id, last_seen, first_seen) FROM stdin;
\.


--
-- Data for Name: sentry_messageindex; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_messageindex (id, object_id, "column", value) FROM stdin;
\.


--
-- Data for Name: sentry_monitor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_monitor (id, guid, organization_id, project_id, name, status, type, config, next_checkin, last_checkin, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_monitorcheckin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_monitorcheckin (id, guid, project_id, monitor_id, location_id, status, config, duration, date_added, date_updated) FROM stdin;
\.


--
-- Data for Name: sentry_monitorlocation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_monitorlocation (id, guid, name, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_option (id, key, value, last_updated) FROM stdin;
1	auth.allow-registration	gAKJLg==	2022-12-22 12:40:56.048518+00
2	system.admin-email	gAJYEAAAAHNlbnRyeUBpdGxhYnMuaW9xAS4=	2022-12-22 12:40:56.060574+00
3	system.url-prefix	gAJYEwAAAGh0dHA6Ly8wLjAuMC4wOjkwMDBxAS4=	2022-12-22 12:40:56.071921+00
4	sentry:version-configured	gAJYBQAAADkuMS4ycQEu	2022-12-22 12:40:56.08509+00
\.


--
-- Data for Name: sentry_organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organization (id, name, status, date_added, slug, flags, default_role) FROM stdin;
1	Sentry	0	2022-12-22 12:24:22.158624+00	sentry	1	member
\.


--
-- Data for Name: sentry_organizationaccessrequest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationaccessrequest (id, team_id, member_id) FROM stdin;
\.


--
-- Data for Name: sentry_organizationavatar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationavatar (id, file_id, ident, organization_id, avatar_type) FROM stdin;
\.


--
-- Data for Name: sentry_organizationintegration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationintegration (id, organization_id, integration_id, config, default_auth_id, date_added, status) FROM stdin;
\.


--
-- Data for Name: sentry_organizationmember; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationmember (id, organization_id, user_id, type, date_added, email, has_global_access, flags, role, token, token_expires_at) FROM stdin;
1	1	1	50	2022-12-22 12:26:15.307037+00	\N	t	0	owner	\N	\N
\.


--
-- Data for Name: sentry_organizationmember_teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationmember_teams (id, organizationmember_id, team_id, is_active) FROM stdin;
1	1	1	t
\.


--
-- Data for Name: sentry_organizationonboardingtask; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationonboardingtask (id, organization_id, user_id, task, status, date_completed, project_id, data) FROM stdin;
\.


--
-- Data for Name: sentry_organizationoptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_organizationoptions (id, organization_id, key, value) FROM stdin;
\.


--
-- Data for Name: sentry_platformexternalissue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_platformexternalissue (id, group_id, service_type, display_name, web_url, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_processingissue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_processingissue (id, project_id, checksum, type, data, datetime) FROM stdin;
\.


--
-- Data for Name: sentry_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_project (id, name, public, date_added, status, slug, organization_id, first_event, forced_color, flags, platform) FROM stdin;
1	Internal	f	2022-12-22 12:24:22.185108+00	0	internal	1	\N	\N	0	\N
\.


--
-- Data for Name: sentry_projectavatar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectavatar (id, file_id, ident, project_id, avatar_type) FROM stdin;
\.


--
-- Data for Name: sentry_projectbookmark; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectbookmark (id, project_id, user_id, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_projectcficachefile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectcficachefile (id, project_id, cache_file_id, dsym_file_id, checksum, version) FROM stdin;
\.


--
-- Data for Name: sentry_projectcounter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectcounter (id, project_id, value) FROM stdin;
\.


--
-- Data for Name: sentry_projectdsymfile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectdsymfile (id, file_id, object_name, cpu_name, project_id, uuid, data, code_id) FROM stdin;
\.


--
-- Data for Name: sentry_projectintegration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectintegration (id, project_id, integration_id, config) FROM stdin;
\.


--
-- Data for Name: sentry_projectkey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectkey (id, project_id, public_key, secret_key, date_added, roles, label, status, rate_limit_count, rate_limit_window, data) FROM stdin;
1	1	d4471721c5cc4609be1dc9a831a3bb6d	713923ae42ee425488b212f95edbb94d	2022-12-22 12:24:22.206626+00	1	Default	0	\N	\N	{}
\.


--
-- Data for Name: sentry_projectoptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectoptions (id, project_id, key, value) FROM stdin;
1	1	sentry:relay-rev	gAJYIAAAADkwYjcxNWI2ODFmMzExZWQ5NjU2MDI0MmFjMTIwMDA3cQEu
2	1	sentry:relay-rev-lastchange	gAJjZGF0ZXRpbWUKZGF0ZXRpbWUKcQFVCgfmDBYMGBYFLAxjcHl0egpfVVRDCnECKVJxA4ZScQQu
3	1	sentry:origins	gAJdcQFVASphLg==
\.


--
-- Data for Name: sentry_projectownership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectownership (id, project_id, raw, schema, fallthrough, date_created, last_updated, is_active) FROM stdin;
\.


--
-- Data for Name: sentry_projectplatform; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectplatform (id, project_id, platform, date_added, last_seen) FROM stdin;
\.


--
-- Data for Name: sentry_projectredirect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectredirect (id, redirect_slug, project_id, organization_id, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_projectsymcachefile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectsymcachefile (id, project_id, cache_file_id, dsym_file_id, checksum, version) FROM stdin;
\.


--
-- Data for Name: sentry_projectteam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_projectteam (id, project_id, team_id) FROM stdin;
1	1	1
\.


--
-- Data for Name: sentry_promptsactivity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_promptsactivity (id, project_id, user_id, feature, data, date_added, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_pull_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_pull_request (id, organization_id, repository_id, key, date_added, title, message, author_id, merge_commit_sha) FROM stdin;
\.


--
-- Data for Name: sentry_pullrequest_commit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_pullrequest_commit (id, pull_request_id, commit_id) FROM stdin;
\.


--
-- Data for Name: sentry_rawevent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_rawevent (id, project_id, event_id, datetime, data) FROM stdin;
\.


--
-- Data for Name: sentry_recentsearch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_recentsearch (id, organization_id, user_id, type, query, query_hash, last_seen, date_added) FROM stdin;
\.


--
-- Data for Name: sentry_relay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_relay (id, relay_id, public_key, first_seen, last_seen, is_internal) FROM stdin;
\.


--
-- Data for Name: sentry_release; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_release (id, project_id, version, date_added, date_released, ref, url, date_started, data, new_groups, owner_id, organization_id, commit_count, last_commit_id, authors, total_deploys, last_deploy_id) FROM stdin;
\.


--
-- Data for Name: sentry_release_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_release_project (id, project_id, release_id, new_groups) FROM stdin;
\.


--
-- Data for Name: sentry_releasecommit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_releasecommit (id, project_id, release_id, commit_id, "order", organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_releasefile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_releasefile (id, project_id, release_id, file_id, ident, name, organization_id, dist_id) FROM stdin;
\.


--
-- Data for Name: sentry_releaseheadcommit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_releaseheadcommit (id, organization_id, repository_id, release_id, commit_id) FROM stdin;
\.


--
-- Data for Name: sentry_releaseprojectenvironment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_releaseprojectenvironment (id, release_id, project_id, environment_id, new_issues_count, first_seen, last_seen, last_deploy_id) FROM stdin;
\.


--
-- Data for Name: sentry_repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_repository (id, organization_id, name, date_added, url, provider, external_id, config, status, integration_id) FROM stdin;
\.


--
-- Data for Name: sentry_reprocessingreport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_reprocessingreport (id, project_id, event_id, datetime) FROM stdin;
\.


--
-- Data for Name: sentry_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_rule (id, project_id, label, data, date_added, status, environment_id) FROM stdin;
1	1	Send a notification for new issues	eJxlj80OAiEMhO99ETgRd/0/GqNHLzzAhgCrJAiEosm+vXRl48FbZzr9JuUmdSCZjsG44mJABqkH7tMauEmbunKmWts6oA0lTyK/vEXxOxCjy1gGtDYM9l0z4kqGrPpC8rwkK2YHqFAypZeqPVUdqOoI97+SlhMhFjdOjX6bxYw+6cbtVl/wUxX9IE0/Ke9p7AHFBx5HTWU=	2022-12-22 12:24:22.219459+00	0	\N
\.


--
-- Data for Name: sentry_savedsearch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_savedsearch (id, project_id, name, query, date_added, is_default, owner_id, is_global, organization_id, type) FROM stdin;
1	\N	Unresolved Issues	is:unresolved	2022-12-22 12:23:11.616865+00	f	\N	t	\N	0
2	\N	Needs Triage	is:unresolved is:unassigned	2022-12-22 12:23:11.617245+00	f	\N	t	\N	0
3	\N	Assigned To Me	is:unresolved assigned:me	2022-12-22 12:23:11.617508+00	f	\N	t	\N	0
4	\N	My Bookmarks	is:unresolved bookmarks:me	2022-12-22 12:23:11.617857+00	f	\N	t	\N	0
5	\N	New Today	is:unresolved age:-24h	2022-12-22 12:23:11.618088+00	f	\N	t	\N	0
6	\N	Errors Only	is:unresolved level:error	2022-12-22 12:24:18.006615+00	f	\N	t	\N	0
7	1	Unresolved Issues	is:unresolved	2022-12-22 12:24:22.23323+00	t	\N	f	\N	0
8	1	Needs Triage	is:unresolved is:unassigned	2022-12-22 12:24:22.240625+00	f	\N	f	\N	0
9	1	Assigned To Me	is:unresolved assigned:me	2022-12-22 12:24:22.247346+00	f	\N	f	\N	0
10	1	My Bookmarks	is:unresolved bookmarks:me	2022-12-22 12:24:22.253726+00	f	\N	f	\N	0
11	1	New Today	is:unresolved age:-24h	2022-12-22 12:24:22.261478+00	f	\N	f	\N	0
\.


--
-- Data for Name: sentry_savedsearch_userdefault; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_savedsearch_userdefault (id, savedsearch_id, project_id, user_id) FROM stdin;
\.


--
-- Data for Name: sentry_scheduleddeletion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_scheduleddeletion (id, guid, app_label, model_name, object_id, date_added, date_scheduled, actor_id, data, in_progress, aborted) FROM stdin;
\.


--
-- Data for Name: sentry_scheduledjob; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_scheduledjob (id, name, payload, date_added, date_scheduled) FROM stdin;
\.


--
-- Data for Name: sentry_sentryapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_sentryapp (id, date_deleted, application_id, proxy_user_id, owner_id, scopes, scope_list, name, slug, uuid, webhook_url, date_added, date_updated, status, redirect_url, overview, is_alertable, events, schema, author) FROM stdin;
\.


--
-- Data for Name: sentry_sentryappavatar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_sentryappavatar (id, file_id, ident, sentry_app_id, avatar_type) FROM stdin;
\.


--
-- Data for Name: sentry_sentryappcomponent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_sentryappcomponent (id, uuid, sentry_app_id, type, schema) FROM stdin;
\.


--
-- Data for Name: sentry_sentryappinstallation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_sentryappinstallation (id, date_deleted, sentry_app_id, organization_id, authorization_id, api_grant_id, uuid, date_added, date_updated) FROM stdin;
\.


--
-- Data for Name: sentry_servicehook; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_servicehook (id, guid, application_id, actor_id, project_id, url, secret, events, status, version, date_added, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_servicehookproject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_servicehookproject (id, service_hook_id, project_id) FROM stdin;
\.


--
-- Data for Name: sentry_team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_team (id, slug, name, date_added, status, organization_id) FROM stdin;
1	sentry	Sentry	2022-12-22 12:24:22.175009+00	0	1
\.


--
-- Data for Name: sentry_teamavatar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_teamavatar (id, file_id, ident, team_id, avatar_type) FROM stdin;
\.


--
-- Data for Name: sentry_useravatar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_useravatar (id, user_id, file_id, ident, avatar_type) FROM stdin;
\.


--
-- Data for Name: sentry_useremail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_useremail (id, user_id, email, validation_hash, date_hash_added, is_verified) FROM stdin;
1	1	sentry@itlabs.io	qJvsz4qHyAZ3kx99OMXKO7R9AW1wrqfW	2022-12-22 12:26:15.272361+00	f
\.


--
-- Data for Name: sentry_userip; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_userip (id, user_id, ip_address, first_seen, last_seen, country_code, region_code) FROM stdin;
1	1	172.18.0.1	2022-12-22 12:40:43.171105+00	2022-12-22 12:41:22.752935+00	\N	\N
\.


--
-- Data for Name: sentry_useroption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_useroption (id, user_id, project_id, key, value, organization_id) FROM stdin;
\.


--
-- Data for Name: sentry_userpermission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_userpermission (id, user_id, permission) FROM stdin;
\.


--
-- Data for Name: sentry_userreport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_userreport (id, project_id, group_id, event_id, name, email, comments, date_added, event_user_id, environment_id) FROM stdin;
\.


--
-- Data for Name: sentry_widget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_widget (id, dashboard_id, "order", title, display_type, display_options, date_added, status) FROM stdin;
\.


--
-- Data for Name: sentry_widgetdatasource; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sentry_widgetdatasource (id, widget_id, type, name, data, "order", date_added, status) FROM stdin;
\.


--
-- Data for Name: social_auth_usersocialauth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.social_auth_usersocialauth (id, user_id, provider, uid, extra_data) FROM stdin;
\.


--
-- Data for Name: south_migrationhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.south_migrationhistory (id, app_name, migration, applied) FROM stdin;
1	sentry	0001_initial	2022-12-22 12:13:52.847485+00
2	sentry	0002_auto__del_field_groupedmessage_url__chg_field_groupedmessage_view__chg	2022-12-22 12:13:52.925058+00
3	sentry	0003_auto__add_field_message_group__del_field_groupedmessage_server_name	2022-12-22 12:13:52.972546+00
4	sentry	0004_auto__add_filtervalue__add_unique_filtervalue_key_value	2022-12-22 12:13:53.010178+00
5	sentry	0005_auto	2022-12-22 12:13:53.043662+00
6	sentry	0006_auto	2022-12-22 12:13:53.075315+00
7	sentry	0007_auto__add_field_message_site	2022-12-22 12:13:53.115746+00
8	sentry	0008_auto__chg_field_message_view__add_field_groupedmessage_data__chg_field	2022-12-22 12:13:53.192593+00
9	sentry	0009_auto__add_field_message_message_id	2022-12-22 12:13:53.234078+00
10	sentry	0010_auto__add_messageindex__add_unique_messageindex_column_value_object_id	2022-12-22 12:13:53.276611+00
11	sentry	0011_auto__add_field_groupedmessage_score	2022-12-22 12:13:53.315086+00
12	sentry	0012_auto	2022-12-22 12:13:53.353728+00
13	sentry	0013_auto__add_messagecountbyminute__add_unique_messagecountbyminute_group_	2022-12-22 12:13:53.435599+00
14	sentry	0014_auto	2022-12-22 12:13:53.487281+00
15	sentry	0014_auto__add_project__add_projectmember__add_unique_projectmember_project	2022-12-22 12:13:53.601334+00
16	sentry	0015_auto__add_field_message_project__add_field_messagecountbyminute_projec	2022-12-22 12:13:53.755416+00
17	sentry	0016_auto__add_field_projectmember_is_superuser	2022-12-22 12:13:53.828314+00
18	sentry	0017_auto__add_field_projectmember_api_key	2022-12-22 12:13:53.904144+00
19	sentry	0018_auto__chg_field_project_owner	2022-12-22 12:13:53.992469+00
20	sentry	0019_auto__del_field_projectmember_api_key__add_field_projectmember_public_	2022-12-22 12:13:54.081901+00
21	sentry	0020_auto__add_projectdomain__add_unique_projectdomain_project_domain	2022-12-22 12:13:54.185411+00
22	sentry	0021_auto__del_message__del_groupedmessage__del_unique_groupedmessage_proje	2022-12-22 12:13:54.264893+00
23	sentry	0022_auto__del_field_group_class_name__del_field_group_traceback__del_field	2022-12-22 12:13:54.34319+00
24	sentry	0023_auto__add_field_event_time_spent	2022-12-22 12:13:54.465557+00
25	sentry	0024_auto__add_field_group_time_spent_total__add_field_group_time_spent_cou	2022-12-22 12:13:54.574457+00
26	sentry	0025_auto__add_field_messagecountbyminute_time_spent_total__add_field_messa	2022-12-22 12:13:54.710567+00
27	sentry	0026_auto__add_field_project_status	2022-12-22 12:13:54.816734+00
28	sentry	0027_auto__chg_field_event_server_name	2022-12-22 12:13:54.903316+00
29	sentry	0028_auto__add_projectoptions__add_unique_projectoptions_project_key_value	2022-12-22 12:13:55.005324+00
30	sentry	0029_auto__del_field_projectmember_is_superuser__del_field_projectmember_pe	2022-12-22 12:13:55.10575+00
31	sentry	0030_auto__add_view__chg_field_event_group	2022-12-22 12:13:55.259624+00
32	sentry	0031_auto__add_field_view_verbose_name__add_field_view_verbose_name_plural_	2022-12-22 12:13:55.359835+00
33	sentry	0032_auto__add_eventmeta	2022-12-22 12:13:55.473446+00
34	sentry	0033_auto__add_option__add_unique_option_key_value	2022-12-22 12:13:55.582219+00
35	sentry	0034_auto__add_groupbookmark__add_unique_groupbookmark_project_user_group	2022-12-22 12:13:55.726133+00
36	sentry	0034_auto__add_unique_option_key__del_unique_option_value_key__del_unique_g	2022-12-22 12:13:55.858894+00
37	sentry	0036_auto__chg_field_option_value__chg_field_projectoption_value	2022-12-22 12:13:56.00963+00
38	sentry	0037_auto__add_unique_option_key__del_unique_option_value_key__del_unique_g	2022-12-22 12:13:56.130741+00
39	sentry	0038_auto__add_searchtoken__add_unique_searchtoken_document_field_token__ad	2022-12-22 12:13:56.2911+00
40	sentry	0039_auto__add_field_searchdocument_status	2022-12-22 12:13:56.418522+00
41	sentry	0040_auto__del_unique_event_event_id__add_unique_event_project_event_id	2022-12-22 12:13:56.54926+00
42	sentry	0041_auto__add_field_messagefiltervalue_last_seen__add_field_messagefilterv	2022-12-22 12:13:56.689521+00
43	sentry	0042_auto__add_projectcountbyminute__add_unique_projectcountbyminute_projec	2022-12-22 12:13:56.854454+00
44	sentry	0043_auto__chg_field_option_value__chg_field_projectoption_value	2022-12-22 12:13:57.041392+00
45	sentry	0044_auto__add_field_projectmember_is_active	2022-12-22 12:13:57.200206+00
46	sentry	0045_auto__add_pendingprojectmember__add_unique_pendingprojectmember_projec	2022-12-22 12:13:57.374452+00
47	sentry	0046_auto__add_teammember__add_unique_teammember_team_user__add_team__add_p	2022-12-22 12:13:57.605148+00
48	sentry	0047_migrate_project_slugs	2022-12-22 12:13:57.791468+00
49	sentry	0048_migrate_project_keys	2022-12-22 12:13:58.364547+00
50	sentry	0049_create_default_project_keys	2022-12-22 12:13:58.548066+00
51	sentry	0050_remove_project_keys_from_members	2022-12-22 12:13:58.737153+00
52	sentry	0051_auto__del_pendingprojectmember__del_unique_pendingprojectmember_projec	2022-12-22 12:13:58.918471+00
53	sentry	0052_migrate_project_members	2022-12-22 12:13:59.08947+00
54	sentry	0053_auto__del_projectmember__del_unique_projectmember_project_user	2022-12-22 12:13:59.256271+00
55	sentry	0054_fix_project_keys	2022-12-22 12:13:59.401859+00
56	sentry	0055_auto__del_projectdomain__del_unique_projectdomain_project_domain	2022-12-22 12:13:59.557853+00
57	sentry	0056_auto__add_field_group_resolved_at	2022-12-22 12:13:59.710061+00
58	sentry	0057_auto__add_field_group_active_at	2022-12-22 12:13:59.873085+00
59	sentry	0058_auto__add_useroption__add_unique_useroption_user_project_key	2022-12-22 12:14:00.075595+00
60	sentry	0059_auto__add_filterkey__add_unique_filterkey_project_key	2022-12-22 12:14:00.255305+00
61	sentry	0060_fill_filter_key	2022-12-22 12:14:00.434693+00
62	sentry	0061_auto__add_field_group_group_id__add_field_group_is_public	2022-12-22 12:14:00.605342+00
63	sentry	0062_correct_del_index_sentry_groupedmessage_logger__view__checksum	2022-12-22 12:14:00.767214+00
64	sentry	0063_auto	2022-12-22 12:14:00.954777+00
65	sentry	0064_index_checksum	2022-12-22 12:14:01.120171+00
66	sentry	0065_create_default_project_key	2022-12-22 12:14:01.323771+00
67	sentry	0066_auto__del_view	2022-12-22 12:14:01.490896+00
68	sentry	0067_auto__add_field_group_platform__add_field_event_platform	2022-12-22 12:14:01.653564+00
69	sentry	0068_auto__add_field_projectkey_user_added__add_field_projectkey_date_added	2022-12-22 12:14:01.837911+00
70	sentry	0069_auto__add_lostpasswordhash	2022-12-22 12:14:02.012405+00
71	sentry	0070_projectoption_key_length	2022-12-22 12:14:02.196272+00
72	sentry	0071_auto__add_field_group_users_seen	2022-12-22 12:14:02.393357+00
73	sentry	0072_auto__add_affecteduserbygroup__add_unique_affecteduserbygroup_project_	2022-12-22 12:14:02.608261+00
74	sentry	0073_auto__add_field_project_platform	2022-12-22 12:14:02.790628+00
75	sentry	0074_correct_filtervalue_index	2022-12-22 12:14:02.982705+00
76	sentry	0075_add_groupbookmark_index	2022-12-22 12:14:03.185714+00
77	sentry	0076_add_groupmeta_index	2022-12-22 12:14:03.381417+00
78	sentry	0077_auto__add_trackeduser__add_unique_trackeduser_project_ident	2022-12-22 12:14:03.578753+00
79	sentry	0078_auto__add_field_affecteduserbygroup_tuser	2022-12-22 12:14:03.793736+00
80	sentry	0079_auto__del_unique_affecteduserbygroup_project_ident_group__add_unique_a	2022-12-22 12:14:03.998177+00
81	sentry	0080_auto__chg_field_affecteduserbygroup_ident	2022-12-22 12:14:04.200401+00
82	sentry	0081_fill_trackeduser	2022-12-22 12:14:04.423357+00
83	sentry	0082_auto__add_activity__add_field_group_num_comments__add_field_event_num_	2022-12-22 12:14:04.733573+00
84	sentry	0083_migrate_dupe_groups	2022-12-22 12:14:05.055773+00
85	sentry	0084_auto__del_unique_group_project_checksum_logger_culprit__add_unique_gro	2022-12-22 12:14:05.295687+00
86	sentry	0085_auto__del_unique_project_slug__add_unique_project_slug_team	2022-12-22 12:14:05.517183+00
87	sentry	0086_auto__add_field_team_date_added	2022-12-22 12:14:05.72447+00
88	sentry	0087_auto__del_messagefiltervalue__del_unique_messagefiltervalue_project_ke	2022-12-22 12:14:05.929694+00
89	sentry	0088_auto__del_messagecountbyminute__del_unique_messagecountbyminute_projec	2022-12-22 12:14:06.145472+00
90	sentry	0089_auto__add_accessgroup__add_unique_accessgroup_team_name	2022-12-22 12:14:06.517247+00
91	sentry	0090_auto__add_grouptagkey__add_unique_grouptagkey_project_group_key__add_f	2022-12-22 12:14:06.843201+00
92	sentry	0091_auto__add_alert	2022-12-22 12:14:07.142139+00
93	sentry	0092_auto__add_alertrelatedgroup__add_unique_alertrelatedgroup_group_alert	2022-12-22 12:14:07.421383+00
94	sentry	0093_auto__add_field_alert_status	2022-12-22 12:14:07.701227+00
95	sentry	0094_auto__add_eventmapping__add_unique_eventmapping_project_event_id	2022-12-22 12:14:07.982919+00
96	sentry	0095_rebase	2022-12-22 12:14:08.263611+00
97	sentry	0096_auto__add_field_tagvalue_data	2022-12-22 12:14:08.554162+00
98	sentry	0097_auto__del_affecteduserbygroup__del_unique_affecteduserbygroup_project_	2022-12-22 12:14:08.83619+00
99	sentry	0098_auto__add_user__chg_field_team_owner__chg_field_activity_user__chg_fie	2022-12-22 12:14:09.661752+00
100	sentry	0099_auto__del_field_teammember_is_active	2022-12-22 12:14:09.97667+00
101	sentry	0100_auto__add_field_tagkey_label	2022-12-22 12:14:10.268599+00
102	sentry	0101_ensure_teams	2022-12-22 12:14:10.522921+00
103	sentry	0102_ensure_slugs	2022-12-22 12:14:10.814586+00
104	sentry	0103_ensure_non_empty_slugs	2022-12-22 12:14:11.109768+00
105	sentry	0104_auto__add_groupseen__add_unique_groupseen_group_user	2022-12-22 12:14:11.404983+00
106	sentry	0105_auto__chg_field_projectcountbyminute_time_spent_total__chg_field_group	2022-12-22 12:14:11.86831+00
107	sentry	0106_auto__del_searchtoken__del_unique_searchtoken_document_field_token__de	2022-12-22 12:14:12.158202+00
108	sentry	0107_expand_user	2022-12-22 12:14:12.444648+00
109	sentry	0108_fix_user	2022-12-22 12:14:12.7056+00
110	sentry	0109_index_filtervalue_times_seen	2022-12-22 12:14:12.954218+00
111	sentry	0110_index_filtervalue_last_seen	2022-12-22 12:14:13.177949+00
112	sentry	0111_index_filtervalue_first_seen	2022-12-22 12:14:13.513206+00
113	sentry	0112_auto__chg_field_option_value__chg_field_useroption_value__chg_field_pr	2022-12-22 12:14:13.805064+00
114	sentry	0113_auto__add_field_team_status	2022-12-22 12:14:14.073872+00
115	sentry	0114_auto__add_field_projectkey_roles	2022-12-22 12:14:14.312797+00
116	sentry	0115_auto__del_projectcountbyminute__del_unique_projectcountbyminute_projec	2022-12-22 12:14:14.586333+00
117	sentry	0116_auto__del_field_event_server_name__del_field_event_culprit__del_field_	2022-12-22 12:14:14.849294+00
118	sentry	0117_auto__add_rule	2022-12-22 12:14:15.198994+00
119	sentry	0118_create_default_rules	2022-12-22 12:14:15.488044+00
120	sentry	0119_auto__add_field_projectkey_label	2022-12-22 12:14:15.736728+00
121	sentry	0120_auto__add_grouprulestatus	2022-12-22 12:14:16.017799+00
122	sentry	0121_auto__add_unique_grouprulestatus_rule_group	2022-12-22 12:14:16.250301+00
123	sentry	0122_add_event_group_id_datetime_index	2022-12-22 12:14:16.499303+00
124	sentry	0123_auto__add_groupassignee__add_index_event_group_datetime	2022-12-22 12:14:16.871715+00
125	sentry	0124_auto__add_grouphash__add_unique_grouphash_project_hash	2022-12-22 12:14:17.142486+00
126	sentry	0125_auto__add_field_user_is_managed	2022-12-22 12:14:17.448202+00
127	sentry	0126_auto__add_field_option_last_updated	2022-12-22 12:14:17.72865+00
128	sentry	0127_auto__add_release__add_unique_release_project_version	2022-12-22 12:14:18.026888+00
129	sentry	0128_auto__add_broadcast	2022-12-22 12:14:18.35972+00
130	sentry	0129_auto__chg_field_release_id__chg_field_pendingteammember_id__chg_field_	2022-12-22 12:14:18.619147+00
131	sentry	0130_auto__del_field_project_owner	2022-12-22 12:14:18.882677+00
132	sentry	0131_auto__add_organizationmember__add_unique_organizationmember_organizati	2022-12-22 12:14:19.262425+00
133	sentry	0132_add_default_orgs	2022-12-22 12:14:19.537622+00
134	sentry	0133_add_org_members	2022-12-22 12:14:19.941245+00
135	sentry	0134_auto__chg_field_team_organization	2022-12-22 12:14:20.264369+00
136	sentry	0135_auto__chg_field_project_team	2022-12-22 12:14:20.650373+00
137	sentry	0136_auto__add_field_organizationmember_email__chg_field_organizationmember	2022-12-22 12:14:21.034854+00
138	sentry	0137_auto__add_field_organizationmember_has_global_access	2022-12-22 12:14:21.39947+00
139	sentry	0138_migrate_team_members	2022-12-22 12:14:21.71173+00
140	sentry	0139_auto__add_auditlogentry	2022-12-22 12:14:22.071348+00
141	sentry	0140_auto__add_field_organization_slug	2022-12-22 12:14:22.408237+00
142	sentry	0141_fill_org_slugs	2022-12-22 12:14:22.709801+00
143	sentry	0142_auto__add_field_project_organization__add_unique_project_organization_	2022-12-22 12:14:23.057717+00
144	sentry	0143_fill_project_orgs	2022-12-22 12:14:23.418541+00
145	sentry	0144_auto__chg_field_project_organization	2022-12-22 12:14:24.507663+00
146	sentry	0145_auto__chg_field_organization_slug	2022-12-22 12:14:24.82807+00
147	sentry	0146_auto__add_field_auditlogentry_ip_address	2022-12-22 12:14:25.134992+00
148	sentry	0147_auto__del_unique_team_slug__add_unique_team_organization_slug	2022-12-22 12:14:25.876207+00
149	sentry	0148_auto__add_helppage	2022-12-22 12:14:26.268108+00
150	sentry	0149_auto__chg_field_groupseen_project__chg_field_groupseen_user__chg_field	2022-12-22 12:14:26.621903+00
151	sentry	0150_fix_broken_rules	2022-12-22 12:14:27.048269+00
152	sentry	0151_auto__add_file	2022-12-22 12:14:27.408758+00
153	sentry	0152_auto__add_field_file_checksum__chg_field_file_name__add_unique_file_na	2022-12-22 12:14:27.806814+00
154	sentry	0153_auto__add_field_grouprulestatus_last_active	2022-12-22 12:14:28.169331+00
155	sentry	0154_auto__add_field_tagkey_status	2022-12-22 12:14:28.559486+00
156	sentry	0155_auto__add_field_projectkey_status	2022-12-22 12:14:28.931117+00
157	sentry	0156_auto__add_apikey	2022-12-22 12:14:29.31443+00
158	sentry	0157_auto__add_authidentity__add_unique_authidentity_auth_provider_ident__a	2022-12-22 12:14:29.758288+00
159	sentry	0158_auto__add_unique_authidentity_auth_provider_user	2022-12-22 12:14:30.154224+00
160	sentry	0159_auto__add_field_authidentity_last_verified__add_field_organizationmemb	2022-12-22 12:14:30.548637+00
161	sentry	0160_auto__add_field_authprovider_default_global_access	2022-12-22 12:14:30.96524+00
162	sentry	0161_auto__chg_field_authprovider_config	2022-12-22 12:14:31.440209+00
163	sentry	0162_auto__chg_field_authidentity_data	2022-12-22 12:14:31.869955+00
164	sentry	0163_auto__add_field_authidentity_last_synced	2022-12-22 12:14:32.230669+00
165	sentry	0164_auto__add_releasefile__add_unique_releasefile_release_ident__add_field	2022-12-22 12:14:32.733765+00
166	sentry	0165_auto__del_unique_file_name_checksum	2022-12-22 12:14:33.175043+00
167	sentry	0166_auto__chg_field_user_id__add_field_apikey_allowed_origins	2022-12-22 12:14:33.606943+00
168	sentry	0167_auto__add_field_authprovider_flags	2022-12-22 12:14:34.000862+00
169	sentry	0168_unfill_projectkey_user	2022-12-22 12:14:34.416019+00
170	sentry	0169_auto__del_field_projectkey_user	2022-12-22 12:14:34.8278+00
171	sentry	0170_auto__add_organizationmemberteam__add_unique_organizationmemberteam_te	2022-12-22 12:14:35.378471+00
172	sentry	0171_auto__chg_field_team_owner	2022-12-22 12:14:35.858297+00
173	sentry	0172_auto__del_field_team_owner	2022-12-22 12:14:36.546127+00
174	sentry	0173_auto__del_teammember__del_unique_teammember_team_user	2022-12-22 12:14:37.209972+00
175	sentry	0174_auto__del_field_projectkey_user_added	2022-12-22 12:14:37.864332+00
176	sentry	0175_auto__del_pendingteammember__del_unique_pendingteammember_team_email	2022-12-22 12:14:38.351882+00
177	sentry	0176_auto__add_field_organizationmember_counter__add_unique_organizationmem	2022-12-22 12:14:38.815242+00
178	sentry	0177_fill_member_counters	2022-12-22 12:14:39.251555+00
179	sentry	0178_auto__del_unique_organizationmember_organization_counter	2022-12-22 12:14:39.663611+00
180	sentry	0179_auto__add_field_release_date_released	2022-12-22 12:14:40.100496+00
181	sentry	0180_auto__add_field_release_environment__add_field_release_ref__add_field_	2022-12-22 12:14:40.627685+00
182	sentry	0181_auto__del_field_release_environment__del_unique_release_project_versio	2022-12-22 12:14:41.126886+00
183	sentry	0182_auto__add_field_auditlogentry_actor_label__add_field_auditlogentry_act	2022-12-22 12:14:41.549925+00
184	sentry	0183_auto__del_index_grouphash_hash	2022-12-22 12:14:42.026799+00
185	sentry	0184_auto__del_field_group_checksum__del_unique_group_project_checksum__del	2022-12-22 12:14:42.436096+00
186	sentry	0185_auto__add_savedsearch__add_unique_savedsearch_project_name	2022-12-22 12:14:42.877333+00
187	sentry	0186_auto__add_field_group_first_release	2022-12-22 12:14:43.299951+00
188	sentry	0187_auto__add_index_group_project_first_release	2022-12-22 12:14:43.73119+00
189	sentry	0188_auto__add_userreport	2022-12-22 12:14:44.17108+00
190	sentry	0189_auto__add_index_userreport_project_event_id	2022-12-22 12:14:45.884905+00
191	sentry	0190_auto__add_field_release_new_groups	2022-12-22 12:14:46.485874+00
192	sentry	0191_auto__del_alert__del_alertrelatedgroup__del_unique_alertrelatedgroup_g	2022-12-22 12:14:47.02072+00
193	sentry	0192_add_model_groupemailthread	2022-12-22 12:14:47.482646+00
194	sentry	0193_auto__del_unique_groupemailthread_msgid__add_unique_groupemailthread_e	2022-12-22 12:14:47.957938+00
195	sentry	0194_auto__del_field_project_platform	2022-12-22 12:14:48.413209+00
196	sentry	0195_auto__chg_field_organization_owner	2022-12-22 12:14:48.884695+00
197	sentry	0196_auto__del_field_organization_owner	2022-12-22 12:14:49.28242+00
198	sentry	0197_auto__del_accessgroup__del_unique_accessgroup_team_name	2022-12-22 12:14:49.75812+00
199	sentry	0198_auto__add_field_release_primary_owner	2022-12-22 12:14:50.195589+00
200	sentry	0199_auto__add_field_project_first_event	2022-12-22 12:14:50.671327+00
201	sentry	0200_backfill_first_event	2022-12-22 12:14:51.125603+00
202	sentry	0201_auto__add_eventuser__add_unique_eventuser_project_ident__add_index_eve	2022-12-22 12:14:51.559992+00
203	sentry	0202_auto__add_field_eventuser_hash__add_unique_eventuser_project_hash	2022-12-22 12:14:52.136145+00
204	sentry	0203_auto__chg_field_eventuser_username__chg_field_eventuser_ident	2022-12-22 12:14:52.586284+00
205	sentry	0204_backfill_team_membership	2022-12-22 12:14:52.984516+00
206	sentry	0205_auto__add_field_organizationmember_role	2022-12-22 12:14:53.428901+00
207	sentry	0206_backfill_member_role	2022-12-22 12:14:53.822782+00
208	sentry	0207_auto__add_field_organization_default_role	2022-12-22 12:14:54.225808+00
209	sentry	0208_backfill_default_role	2022-12-22 12:14:54.738276+00
210	sentry	0209_auto__add_broadcastseen__add_unique_broadcastseen_broadcast_user	2022-12-22 12:14:55.178163+00
211	sentry	0210_auto__del_field_broadcast_badge	2022-12-22 12:14:55.635173+00
212	sentry	0211_auto__add_field_broadcast_title	2022-12-22 12:14:56.066913+00
213	sentry	0212_auto__add_fileblob__add_field_file_blob	2022-12-22 12:14:56.626749+00
214	sentry	0212_auto__add_organizationoption__add_unique_organizationoption_organizati	2022-12-22 12:14:57.170949+00
215	sentry	0213_migrate_file_blobs	2022-12-22 12:14:57.619042+00
216	sentry	0214_auto__add_field_broadcast_upstream_id	2022-12-22 12:14:58.085021+00
217	sentry	0215_auto__add_field_broadcast_date_expires	2022-12-22 12:14:58.570175+00
218	sentry	0216_auto__add_groupsnooze	2022-12-22 12:14:59.077381+00
219	sentry	0217_auto__add_groupresolution	2022-12-22 12:14:59.559775+00
220	sentry	0218_auto__add_field_groupresolution_status	2022-12-22 12:15:00.065892+00
221	sentry	0219_auto__add_field_groupbookmark_date_added	2022-12-22 12:15:00.546039+00
222	sentry	0220_auto__del_field_fileblob_storage_options__del_field_fileblob_storage__	2022-12-22 12:15:01.040994+00
223	sentry	0221_auto__chg_field_user_first_name	2022-12-22 12:15:01.513954+00
224	sentry	0222_auto__del_field_user_last_name__del_field_user_first_name__add_field_u	2022-12-22 12:15:02.063795+00
225	sentry	0223_delete_old_sentry_docs_options	2022-12-22 12:15:02.560421+00
226	sentry	0224_auto__add_index_userreport_project_date_added	2022-12-22 12:15:03.119914+00
227	sentry	0225_auto__add_fileblobindex__add_unique_fileblobindex_file_blob_offset	2022-12-22 12:15:03.648117+00
228	sentry	0226_backfill_file_size	2022-12-22 12:15:04.151531+00
229	sentry	0227_auto__del_field_activity_event	2022-12-22 12:15:04.672715+00
230	sentry	0228_auto__del_field_event_num_comments	2022-12-22 12:15:05.193556+00
231	sentry	0229_drop_event_constraints	2022-12-22 12:15:05.717272+00
232	sentry	0230_auto__del_field_eventmapping_group__del_field_eventmapping_project__ad	2022-12-22 12:15:06.224608+00
233	sentry	0231_auto__add_field_savedsearch_is_default	2022-12-22 12:15:06.948327+00
234	sentry	0232_default_savedsearch	2022-12-22 12:15:07.599463+00
235	sentry	0233_add_new_savedsearch	2022-12-22 12:15:08.145892+00
236	sentry	0234_auto__add_savedsearchuserdefault__add_unique_savedsearchuserdefault_pr	2022-12-22 12:15:08.797732+00
237	sentry	0235_auto__add_projectbookmark__add_unique_projectbookmark_project_id_user_	2022-12-22 12:15:09.374461+00
238	sentry	0236_auto__add_organizationonboardingtask__add_unique_organizationonboardin	2022-12-22 12:15:09.969495+00
239	sentry	0237_auto__add_eventtag__add_unique_eventtag_event_id_key_id_value_id	2022-12-22 12:15:10.541556+00
240	sentry	0238_fill_org_onboarding_tasks	2022-12-22 12:15:12.596586+00
241	sentry	0239_auto__add_projectdsymfile__add_unique_projectdsymfile_project_uuid__ad	2022-12-22 12:15:13.24903+00
242	sentry	0240_fill_onboarding_option	2022-12-22 12:15:13.934284+00
243	sentry	0241_auto__add_counter__add_unique_counter_project_ident__add_field_group_s	2022-12-22 12:15:14.609207+00
244	sentry	0242_auto__add_field_project_forced_color	2022-12-22 12:15:15.233348+00
245	sentry	0243_remove_inactive_members	2022-12-22 12:15:15.920315+00
246	sentry	0244_auto__add_groupredirect	2022-12-22 12:15:16.654253+00
247	sentry	0245_auto__del_field_project_callsign__del_unique_project_organization_call	2022-12-22 12:15:17.516191+00
248	sentry	0246_auto__add_dsymsymbol__add_unique_dsymsymbol_object_address__add_dsymsd	2022-12-22 12:15:18.282783+00
249	sentry	0247_migrate_file_blobs	2022-12-22 12:15:19.012967+00
250	sentry	0248_auto__add_projectplatform__add_unique_projectplatform_project_id_platf	2022-12-22 12:15:19.724338+00
251	sentry	0249_auto__add_index_eventtag_project_id_key_id_value_id	2022-12-22 12:15:20.464118+00
252	sentry	0250_auto__add_unique_userreport_project_event_id	2022-12-22 12:15:21.15228+00
253	sentry	0251_auto__add_useravatar	2022-12-22 12:15:21.903277+00
254	sentry	0252_default_users_to_gravatar	2022-12-22 12:15:22.647422+00
255	sentry	0253_auto__add_field_eventtag_group_id	2022-12-22 12:15:23.371624+00
256	sentry	0254_auto__add_index_eventtag_group_id_key_id_value_id	2022-12-22 12:15:24.126708+00
257	sentry	0255_auto__add_apitoken	2022-12-22 12:15:24.894182+00
258	sentry	0256_auto__add_authenticator	2022-12-22 12:15:25.647286+00
259	sentry	0257_repair_activity	2022-12-22 12:15:26.434515+00
260	sentry	0258_auto__add_field_user_is_password_expired__add_field_user_last_password	2022-12-22 12:15:27.267585+00
261	sentry	0259_auto__add_useremail__add_unique_useremail_user_email	2022-12-22 12:15:28.204513+00
262	sentry	0260_populate_email_addresses	2022-12-22 12:15:29.02976+00
263	sentry	0261_auto__add_groupsubscription__add_unique_groupsubscription_group_user	2022-12-22 12:15:29.843369+00
264	sentry	0262_fix_tag_indexes	2022-12-22 12:15:30.660605+00
265	sentry	0263_remove_default_regression_rule	2022-12-22 12:15:31.508813+00
266	sentry	0264_drop_grouptagvalue_project_index	2022-12-22 12:15:32.371086+00
267	sentry	0265_auto__add_field_rule_status	2022-12-22 12:15:33.238185+00
268	sentry	0266_auto__add_grouprelease__add_unique_grouprelease_group_id_release_id_en	2022-12-22 12:15:34.074332+00
269	sentry	0267_auto__add_environment__add_unique_environment_project_id_name__add_rel	2022-12-22 12:15:34.94861+00
270	sentry	0268_fill_environment	2022-12-22 12:15:35.794355+00
271	sentry	0269_auto__del_helppage	2022-12-22 12:15:36.641487+00
272	sentry	0270_auto__add_field_organizationmember_token	2022-12-22 12:15:37.51799+00
273	sentry	0271_auto__del_field_organizationmember_counter	2022-12-22 12:15:38.683127+00
274	sentry	0272_auto__add_unique_authenticator_user_type	2022-12-22 12:15:39.60955+00
275	sentry	0273_auto__add_repository__add_unique_repository_organization_id_name__add_	2022-12-22 12:15:40.62854+00
276	sentry	0274_auto__add_index_commit_repository_id_date_added	2022-12-22 12:15:41.640933+00
277	sentry	0275_auto__del_index_grouptagvalue_project_key_value__add_index_grouptagval	2022-12-22 12:15:42.534739+00
278	sentry	0276_auto__add_field_user_session_nonce	2022-12-22 12:15:43.471951+00
279	sentry	0277_auto__add_commitfilechange__add_unique_commitfilechange_commit_filenam	2022-12-22 12:15:44.435136+00
280	sentry	0278_auto__add_releaseproject__add_unique_releaseproject_project_release__a	2022-12-22 12:15:45.443362+00
281	sentry	0279_populate_release_orgs_and_projects	2022-12-22 12:15:46.423307+00
282	sentry	0280_auto__add_field_releasecommit_organization_id	2022-12-22 12:15:47.49544+00
283	sentry	0281_populate_release_commit_organization_id	2022-12-22 12:15:48.649803+00
284	sentry	0282_auto__add_field_releasefile_organization__add_field_releaseenvironment	2022-12-22 12:15:49.653718+00
285	sentry	0283_populate_release_environment_and_release_file_organization	2022-12-22 12:15:50.687454+00
286	sentry	0284_auto__del_field_release_project__add_field_release_project_id__chg_fie	2022-12-22 12:15:53.859622+00
287	sentry	0285_auto__chg_field_release_project_id__chg_field_releasefile_project_id	2022-12-22 12:15:54.938864+00
288	sentry	0286_drop_project_fk_release_release_file	2022-12-22 12:15:55.956405+00
289	sentry	0287_auto__add_field_releaseproject_new_groups	2022-12-22 12:15:57.079704+00
290	sentry	0288_set_release_project_new_groups_to_zero	2022-12-22 12:15:58.110716+00
291	sentry	0289_auto__add_organizationavatar	2022-12-22 12:15:59.44576+00
292	sentry	0290_populate_release_project_new_groups	2022-12-22 12:16:00.662896+00
293	sentry	0291_merge_legacy_releases	2022-12-22 12:16:01.76367+00
294	sentry	0292_auto__add_unique_release_organization_version	2022-12-22 12:16:02.910207+00
295	sentry	0293_auto__del_unique_release_project_id_version	2022-12-22 12:16:03.994096+00
296	sentry	0294_auto__add_groupcommitresolution__add_unique_groupcommitresolution_grou	2022-12-22 12:16:05.110958+00
297	sentry	0295_auto__add_environmentproject__add_unique_environmentproject_project_en	2022-12-22 12:16:06.224224+00
298	sentry	0296_populate_environment_organization_and_projects	2022-12-22 12:16:07.346907+00
299	sentry	0297_auto__add_field_project_flags	2022-12-22 12:16:08.499724+00
300	sentry	0298_backfill_project_has_releases	2022-12-22 12:16:09.858498+00
301	sentry	0299_auto__chg_field_environment_organization_id	2022-12-22 12:16:11.071735+00
302	sentry	0300_auto__add_processingissue__add_unique_processingissue_project_checksum	2022-12-22 12:16:12.393619+00
303	sentry	0301_auto__chg_field_environment_project_id__chg_field_releaseenvironment_p	2022-12-22 12:16:13.580125+00
304	sentry	0302_merge_environments	2022-12-22 12:16:14.854268+00
305	sentry	0303_fix_release_new_group_counts	2022-12-22 12:16:16.057439+00
306	sentry	0304_auto__add_deploy	2022-12-22 12:16:17.805471+00
307	sentry	0305_auto__chg_field_authidentity_data__chg_field_useroption_value__chg_fie	2022-12-22 12:16:19.531193+00
308	sentry	0306_auto__add_apigrant__add_apiauthorization__add_unique_apiauthorization_	2022-12-22 12:16:21.281402+00
309	sentry	0307_auto__add_field_apigrant_scope_list__add_field_apitoken_scope_list__ad	2022-12-22 12:16:22.771618+00
310	sentry	0308_auto__add_versiondsymfile__add_unique_versiondsymfile_dsym_file_versio	2022-12-22 12:16:24.455714+00
311	sentry	0308_backfill_scopes_list	2022-12-22 12:16:25.887829+00
312	sentry	0309_fix_application_state	2022-12-22 12:16:27.305007+00
313	sentry	0310_auto__add_field_savedsearch_owner	2022-12-22 12:16:28.741135+00
314	sentry	0311_auto__add_releaseheadcommit__add_unique_releaseheadcommit_repository_i	2022-12-22 12:16:30.470509+00
315	sentry	0312_create_missing_emails	2022-12-22 12:16:31.993429+00
316	sentry	0313_auto__add_field_commitauthor_external_id__add_unique_commitauthor_orga	2022-12-22 12:16:33.416047+00
317	sentry	0314_auto__add_distribution__add_unique_distribution_release_name__add_fiel	2022-12-22 12:16:34.878239+00
318	sentry	0315_auto__add_field_useroption_organization__add_unique_useroption_user_or	2022-12-22 12:16:36.398256+00
319	sentry	0316_auto__del_field_grouptagvalue_project__del_field_grouptagvalue_group__	2022-12-22 12:16:37.858146+00
320	sentry	0317_drop_grouptagvalue_constraints	2022-12-22 12:16:39.395582+00
321	sentry	0318_auto__add_field_deploy_notified	2022-12-22 12:16:41.132782+00
322	sentry	0319_auto__add_index_deploy_notified	2022-12-22 12:16:42.634443+00
323	sentry	0320_auto__add_index_eventtag_date_added	2022-12-22 12:16:44.164695+00
324	sentry	0321_auto__add_field_projectkey_rate_limit_count__add_field_projectkey_rate	2022-12-22 12:16:45.625689+00
325	sentry	0321_auto__add_unique_environment_organization_id_name	2022-12-22 12:16:47.076504+00
326	sentry	0322_merge_0321_migrations	2022-12-22 12:16:48.583965+00
327	sentry	0323_auto__add_unique_releaseenvironment_organization_id_release_id_environ	2022-12-22 12:16:50.33825+00
328	sentry	0324_auto__add_field_eventuser_name__add_field_userreport_event_user_id	2022-12-22 12:16:52.13032+00
329	sentry	0325_auto__add_scheduleddeletion__add_unique_scheduleddeletion_app_label_mo	2022-12-22 12:16:53.812615+00
330	sentry	0326_auto__add_field_groupsnooze_count__add_field_groupsnooze_window__add_f	2022-12-22 12:16:55.352902+00
331	sentry	0327_auto__add_field_release_commit_count__add_field_release_last_commit_id	2022-12-22 12:16:59.610374+00
332	sentry	0328_backfill_release_stats	2022-12-22 12:17:01.635319+00
333	sentry	0329_auto__del_dsymsymbol__del_unique_dsymsymbol_object_address__del_global	2022-12-22 12:17:03.185528+00
334	sentry	0330_auto__add_field_grouphash_state	2022-12-22 12:17:04.725809+00
335	sentry	0331_auto__del_index_releasecommit_project_id__del_index_releaseenvironment	2022-12-22 12:17:06.286615+00
336	sentry	0332_auto__add_featureadoption__add_unique_featureadoption_organization_fea	2022-12-22 12:17:07.811255+00
337	sentry	0333_auto__add_field_groupresolution_type__add_field_groupresolution_actor_	2022-12-22 12:17:09.310539+00
338	sentry	0334_auto__add_field_project_platform	2022-12-22 12:17:11.41333+00
339	sentry	0334_auto__add_scheduledjob	2022-12-22 12:17:13.539896+00
340	sentry	0335_auto__add_field_groupsnooze_actor_id	2022-12-22 12:17:15.213064+00
341	sentry	0336_auto__add_field_user_last_active	2022-12-22 12:17:17.025627+00
342	sentry	0337_fix_out_of_order_migrations	2022-12-22 12:17:18.66092+00
343	sentry	0338_fix_null_user_last_active	2022-12-22 12:17:20.356042+00
344	sentry	0339_backfill_first_project_feature	2022-12-22 12:17:22.014352+00
345	sentry	0340_auto__add_grouptombstone__add_field_grouphash_group_tombstone_id	2022-12-22 12:17:23.781728+00
346	sentry	0341_auto__add_organizationintegration__add_unique_organizationintegration_	2022-12-22 12:17:25.690322+00
347	sentry	0342_projectplatform	2022-12-22 12:17:27.383727+00
348	sentry	0343_auto__add_index_groupcommitresolution_commit_id	2022-12-22 12:17:29.08786+00
349	sentry	0344_add_index_ProjectPlatform_last_seen	2022-12-22 12:17:30.752252+00
350	sentry	0345_add_citext	2022-12-22 12:17:32.600152+00
351	sentry	0346_auto__del_field_tagkey_project__add_field_tagkey_project_id__del_uniqu	2022-12-22 12:17:34.281983+00
352	sentry	0347_auto__add_index_grouptagvalue_project_id__add_index_grouptagvalue_grou	2022-12-22 12:17:35.928724+00
353	sentry	0348_fix_project_key_rate_limit_window_unit	2022-12-22 12:17:37.603225+00
354	sentry	0349_drop_constraints_filterkey_filtervalue_grouptagkey	2022-12-22 12:17:39.416345+00
355	sentry	0350_auto__add_email	2022-12-22 12:17:41.158151+00
356	sentry	0351_backfillemail	2022-12-22 12:17:43.255691+00
357	sentry	0352_add_index_release_coalesce_date_released_date_added	2022-12-22 12:17:45.504047+00
358	sentry	0353_auto__del_field_eventuser_project__add_field_eventuser_project_id__del	2022-12-22 12:17:47.547011+00
359	sentry	0354_auto__chg_field_commitfilechange_filename	2022-12-22 12:17:49.760786+00
360	sentry	0355_auto__add_field_organizationintegration_config__add_field_organization	2022-12-22 12:17:51.794345+00
361	sentry	0356_auto__add_useridentity__add_unique_useridentity_user_identity__add_ide	2022-12-22 12:17:53.865069+00
362	sentry	0357_auto__add_projectteam__add_unique_projectteam_project_team	2022-12-22 12:17:55.643545+00
363	sentry	0358_auto__add_projectsymcachefile__add_unique_projectsymcachefile_project_	2022-12-22 12:17:57.519292+00
364	sentry	0359_auto__add_index_tagvalue_project_id_key_last_seen	2022-12-22 12:17:59.847553+00
365	sentry	0360_auto__add_groupshare	2022-12-22 12:18:02.097176+00
366	sentry	0361_auto__add_minidumpfile	2022-12-22 12:18:04.158955+00
367	sentry	0362_auto__add_userip__add_unique_userip_user_ip_address	2022-12-22 12:18:06.232332+00
368	sentry	0363_auto__add_grouplink__add_unique_grouplink_group_id_linked_type_linked_	2022-12-22 12:18:08.239466+00
369	sentry	0364_backfill_grouplink_from_groupcommitresolution	2022-12-22 12:18:10.26577+00
370	sentry	0365_auto__del_index_eventtag_project_id_key_id_value_id	2022-12-22 12:18:12.489883+00
371	sentry	0366_backfill_first_project_heroku	2022-12-22 12:18:14.703113+00
372	sentry	0367_auto__chg_field_release_ref__chg_field_release_version	2022-12-22 12:18:16.784635+00
373	sentry	0368_auto__add_deletedorganization__add_deletedteam__add_deletedproject	2022-12-22 12:18:19.056688+00
374	sentry	0369_remove_old_grouphash_last_processed_event_data	2022-12-22 12:18:21.230135+00
375	sentry	0370_correct_groupsnooze_windows	2022-12-22 12:18:23.324868+00
376	sentry	0371_auto__add_servicehook	2022-12-22 12:18:25.855496+00
377	sentry	0371_auto__del_minidumpfile	2022-12-22 12:18:28.020764+00
378	sentry	0372_resolve_migration_conflict	2022-12-22 12:18:30.23976+00
379	sentry	0373_backfill_projectteam	2022-12-22 12:18:36.661075+00
380	sentry	0374_auto__del_useridentity__del_unique_useridentity_user_identity__del_ide	2022-12-22 12:18:39.113688+00
381	sentry	0375_auto__add_identityprovider__add_unique_identityprovider_type_organizat	2022-12-22 12:18:41.766439+00
382	sentry	0376_auto__add_userpermission__add_unique_userpermission_user_permission	2022-12-22 12:18:44.021935+00
383	sentry	0377_auto__add_pullrequest__add_unique_pullrequest_repository_id_key__add_i	2022-12-22 12:18:46.664862+00
384	sentry	0378_delete_outdated_projectteam	2022-12-22 12:18:48.955797+00
385	sentry	0379_auto__add_unique_projectteam_project	2022-12-22 12:18:51.261779+00
386	sentry	0380_auto__chg_field_servicehook_url	2022-12-22 12:18:53.666219+00
387	sentry	0381_auto__del_field_deletedproject_team_name__del_field_deletedproject_tea	2022-12-22 12:18:56.088471+00
388	sentry	0382_auto__add_groupenvironment__add_unique_groupenvironment_group_id_envir	2022-12-22 12:18:58.546384+00
389	sentry	0383_auto__chg_field_project_team	2022-12-22 12:19:00.926629+00
390	sentry	0384_auto__del_unique_projectteam_project	2022-12-22 12:19:03.477983+00
391	sentry	0385_auto__add_field_rule_environment_id	2022-12-22 12:19:05.862848+00
392	sentry	0386_auto__del_unique_project_team_slug	2022-12-22 12:19:08.429121+00
393	sentry	0387_auto__add_field_groupassignee_team__chg_field_groupassignee_user	2022-12-22 12:19:10.835244+00
394	sentry	0388_auto__add_field_environmentproject_is_hidden	2022-12-22 12:19:13.353238+00
395	sentry	0389_auto__add_field_groupenvironment_first_release_id__add_index_groupenvi	2022-12-22 12:19:15.905154+00
396	sentry	0390_auto__add_field_userreport_environment	2022-12-22 12:19:18.943996+00
397	sentry	0391_auto__add_fileblobowner__add_unique_fileblobowner_blob_organization__a	2022-12-22 12:19:21.899148+00
398	sentry	0392_auto__add_projectownership	2022-12-22 12:19:24.611334+00
399	sentry	0393_auto__add_assistantactivity__add_unique_assistantactivity_user_guide_i	2022-12-22 12:19:27.109417+00
400	sentry	0394_auto__chg_field_project_team	2022-12-22 12:19:29.720266+00
401	sentry	0395_auto__add_releaseprojectenvironment__add_unique_releaseprojectenvironm	2022-12-22 12:19:32.282178+00
402	sentry	0396_auto__del_field_project_team	2022-12-22 12:19:34.600012+00
403	sentry	0397_auto__add_latestrelease__add_unique_latestrelease_repository_id_enviro	2022-12-22 12:19:36.940317+00
404	sentry	0397_auto__add_unique_identity_idp_user	2022-12-22 12:19:40.01899+00
405	sentry	0398_auto__add_pullrequestcommit__add_unique_pullrequestcommit_pull_request	2022-12-22 12:19:42.76029+00
406	sentry	0399_auto__chg_field_user_last_login__add_unique_identity_idp_user	2022-12-22 12:19:45.40225+00
407	sentry	0400_auto__add_projectredirect__add_unique_projectredirect_organization_red	2022-12-22 12:19:47.987661+00
408	sentry	0401_auto__chg_field_projectdsymfile_uuid	2022-12-22 12:19:51.352075+00
409	sentry	0402_auto__add_field_organizationintegration_date_added__add_field_identity	2022-12-22 12:19:54.053796+00
410	sentry	0403_auto__add_teamavatar	2022-12-22 12:19:56.61477+00
411	sentry	0404_auto__del_unique_environment_project_id_name	2022-12-22 12:19:59.446526+00
412	sentry	0405_auto__add_field_user_flags	2022-12-22 12:20:01.993667+00
413	sentry	0406_auto__add_projectavatar	2022-12-22 12:20:04.596824+00
414	sentry	0407_auto__add_field_identityprovider_external_id__add_unique_identityprovi	2022-12-22 12:20:07.159817+00
415	sentry	0408_identity_provider_external_id	2022-12-22 12:20:09.809027+00
416	sentry	0409_auto__add_field_releaseprojectenvironment_last_deploy_id	2022-12-22 12:20:12.439108+00
417	sentry	0410_auto__del_unique_identityprovider_type_organization	2022-12-22 12:20:15.015815+00
418	sentry	0411_auto__add_field_projectkey_data	2022-12-22 12:20:17.840768+00
419	sentry	0412_auto__chg_field_file_name	2022-12-22 12:20:21.050934+00
420	sentry	0413_auto__add_externalissue__add_unique_externalissue_organization_id_inte	2022-12-22 12:20:23.8519+00
421	sentry	0414_backfill_release_project_environment_last_deploy_id	2022-12-22 12:20:26.407424+00
422	sentry	0415_auto__add_relay	2022-12-22 12:20:29.086638+00
423	sentry	0416_auto__del_field_identityprovider_organization__add_field_identityprovi	2022-12-22 12:20:31.886596+00
424	sentry	0417_migrate_identities	2022-12-22 12:20:34.696013+00
425	sentry	0418_delete_old_idps	2022-12-22 12:20:37.486802+00
426	sentry	0419_auto__add_unique_identityprovider_type_external_id	2022-12-22 12:20:40.395418+00
427	sentry	0420_auto__chg_field_identityprovider_organization_id	2022-12-22 12:20:43.098698+00
428	sentry	0421_auto__del_field_identityprovider_organization_id__del_unique_identityp	2022-12-22 12:20:45.559935+00
429	sentry	0422_auto__add_grouphashtombstone__add_unique_grouphashtombstone_project_ha	2022-12-22 12:20:48.168934+00
430	sentry	0423_auto__add_index_grouphashtombstone_deleted_at	2022-12-22 12:20:58.958596+00
431	sentry	0424_auto__add_field_integration_status	2022-12-22 12:21:02.320714+00
432	sentry	0425_auto__add_index_pullrequest_organization_id_merge_commit_sha	2022-12-22 12:21:05.277676+00
433	sentry	0425_remove_invalid_github_idps	2022-12-22 12:21:08.208068+00
434	sentry	0426_auto__add_sentryappinstallation__add_sentryapp__add_field_user_is_sent	2022-12-22 12:21:11.321679+00
435	sentry	0427_auto__add_eventattachment__add_unique_eventattachment_project_id_event	2022-12-22 12:21:14.415963+00
436	sentry	0428_auto__add_index_eventattachment_project_id_date_added	2022-12-22 12:21:17.499974+00
437	sentry	0429_auto__add_integrationexternalproject__add_unique_integrationexternalpr	2022-12-22 12:21:20.552455+00
438	sentry	0430_auto__add_field_organizationintegration_status	2022-12-22 12:21:23.926665+00
439	sentry	0431_auto__add_field_externalissue_metadata	2022-12-22 12:21:26.983008+00
440	sentry	0432_auto__add_field_relay_is_internal	2022-12-22 12:21:30.163584+00
441	sentry	0432_auto__add_index_userreport_date_added__add_index_eventattachment_date_	2022-12-22 12:21:33.604529+00
442	sentry	0433_auto__add_field_relay_is_internal__add_field_userip_country_code__add_	2022-12-22 12:21:36.64762+00
443	sentry	0434_auto__add_discoversavedqueryproject__add_unique_discoversavedqueryproj	2022-12-22 12:21:40.019993+00
444	sentry	0435_auto__add_field_discoversavedquery_created_by	2022-12-22 12:21:43.639135+00
445	sentry	0436_rename_projectdsymfile_to_projectdebugfile	2022-12-22 12:21:47.167268+00
446	sentry	0437_auto__add_field_sentryapp_status	2022-12-22 12:21:50.41615+00
447	sentry	0438_auto__add_index_sentryapp_status__chg_field_sentryapp_proxy_user__chg_	2022-12-22 12:21:53.619801+00
448	sentry	0439_auto__chg_field_sentryapp_owner	2022-12-22 12:21:57.160388+00
449	sentry	0440_auto__del_unique_projectdebugfile_project_debug_id__add_index_projectd	2022-12-22 12:22:00.91397+00
450	sentry	0441_auto__add_field_projectdebugfile_data	2022-12-22 12:22:04.663804+00
451	sentry	0442_auto__add_projectcficachefile__add_unique_projectcficachefile_project_	2022-12-22 12:22:08.554183+00
452	sentry	0443_auto__add_field_organizationmember_token_expires_at	2022-12-22 12:22:12.095019+00
453	sentry	0443_auto__del_dsymapp__del_unique_dsymapp_project_platform_app_id__del_ver	2022-12-22 12:22:15.56376+00
454	sentry	0444_auto__add_sentryappavatar__add_field_sentryapp_redirect_url__add_field	2022-12-22 12:22:19.446838+00
455	sentry	0445_auto__add_promptsactivity__add_unique_promptsactivity_user_feature_org	2022-12-22 12:22:23.372161+00
456	sentry	0446_auto__add_index_promptsactivity_project_id	2022-12-22 12:22:26.919339+00
457	sentry	0447_auto__del_field_promptsactivity_organization__add_field_promptsactivit	2022-12-22 12:22:30.263939+00
458	sentry	0448_auto__add_field_sentryapp_is_alertable	2022-12-22 12:22:33.395907+00
459	sentry	0449_auto__chg_field_release_owner	2022-12-22 12:22:36.600674+00
460	sentry	0450_auto__del_grouphashtombstone__del_unique_grouphashtombstone_project_ha	2022-12-22 12:22:39.663818+00
461	sentry	0451_auto__del_field_projectbookmark_project_id__add_field_projectbookmark_	2022-12-22 12:22:42.732114+00
462	sentry	0452_auto__add_field_sentryapp_events	2022-12-22 12:22:45.752511+00
463	sentry	0452_auto__del_field_releaseenvironment_organization_id__del_field_releasee	2022-12-22 12:22:48.930175+00
464	sentry	0453_auto__add_index_releasefile_release_name	2022-12-22 12:22:52.211822+00
465	sentry	0454_resolve_duplicate_0452	2022-12-22 12:22:55.273074+00
466	sentry	0455_auto__add_field_groupenvironment_first_seen	2022-12-22 12:22:58.488869+00
467	sentry	0456_auto__add_dashboard__add_unique_dashboard_organization_title__add_widg	2022-12-22 12:23:01.6554+00
468	sentry	0457_auto__add_field_savedsearch_is_global__chg_field_savedsearch_project__	2022-12-22 12:23:04.865427+00
469	sentry	0457_auto__add_monitorcheckin__add_monitor__add_index_monitor_type_next_che	2022-12-22 12:23:08.357603+00
470	sentry	0458_global_searches_data_migration	2022-12-22 12:23:11.62857+00
471	sentry	0459_global_searches_unique_constraint	2022-12-22 12:23:15.057165+00
472	sentry	0460_auto__add_field_servicehook_organization_id	2022-12-22 12:23:18.494085+00
473	sentry	0461_event_attachment_indexes	2022-12-22 12:23:21.960976+00
474	sentry	0462_auto__add_servicehookproject	2022-12-22 12:23:25.444582+00
475	sentry	0462_releaseenvironment_project_id	2022-12-22 12:23:29.130343+00
476	sentry	0463_backfill_service_hook_project	2022-12-22 12:23:32.671816+00
477	sentry	0464_auto__add_sentryappcomponent__add_field_sentryapp_schema	2022-12-22 12:23:36.289025+00
478	sentry	0464_groupenvironment_foreignkeys	2022-12-22 12:23:40.293239+00
479	sentry	0465_sync	2022-12-22 12:23:43.966097+00
480	sentry	0466_auto__add_platformexternalissue__add_unique_platformexternalissue_grou	2022-12-22 12:23:47.699221+00
481	sentry	0467_backfill_integration_status	2022-12-22 12:23:51.367941+00
482	sentry	0468_auto__add_field_projectdebugfile_code_id__add_index_projectdebugfile_p	2022-12-22 12:23:55.27591+00
483	sentry	0468_recent_search	2022-12-22 12:23:59.12236+00
484	sentry	0469_fix_state	2022-12-22 12:24:02.815751+00
485	sentry	0470_org_saved_search	2022-12-22 12:24:14.05744+00
486	sentry	0471_global_saved_search_types	2022-12-22 12:24:18.019062+00
487	sentry	0472_auto__add_field_sentryapp_author	2022-12-22 12:24:22.127637+00
488	sentry.nodestore	0001_initial	2022-12-22 12:26:18.653396+00
489	sentry.search	0001_initial	2022-12-22 12:26:20.804688+00
490	sentry.search	0002_auto__del_searchtoken__del_unique_searchtoken_document_field_token__de	2022-12-22 12:26:20.834717+00
491	social_auth	0001_initial	2022-12-22 12:26:36.048941+00
492	social_auth	0002_auto__add_unique_nonce_timestamp_salt_server_url__add_unique_associati	2022-12-22 12:26:37.21796+00
493	social_auth	0003_auto__del_nonce__del_unique_nonce_server_url_timestamp_salt__del_assoc	2022-12-22 12:26:37.311664+00
494	social_auth	0004_auto__del_unique_usersocialauth_provider_uid__add_unique_usersocialaut	2022-12-22 12:26:37.387585+00
495	sentry.tagstore	0001_initial	2022-12-22 12:26:39.414808+00
496	sentry.tagstore	0002_auto__del_tagkey__del_unique_tagkey_project_id_environment_id_key__del	2022-12-22 12:26:39.489365+00
497	sentry.tagstore	0003_auto__add_tagkey__add_unique_tagkey_project_id_environment_id_key__add	2022-12-22 12:26:39.777658+00
498	sentry.tagstore	0004_auto__del_tagkey__del_unique_tagkey_project_id_environment_id_key__del	2022-12-22 12:26:39.851779+00
499	sentry.tagstore	0005_auto__add_tagvalue__add_unique_tagvalue_project_id__key_value__add_ind	2022-12-22 12:26:40.09455+00
500	sentry.tagstore	0006_auto__del_unique_eventtag_event_id_key_value__add_unique_eventtag_proj	2022-12-22 12:26:40.197831+00
501	sentry.tagstore	0007_auto__chg_field_tagkey_environment_id__chg_field_tagkey_project_id__ch	2022-12-22 12:26:40.594336+00
502	sentry.tagstore	0008_auto__chg_field_tagkey_environment_id	2022-12-22 12:26:40.748067+00
503	sentry_plugins.hipchat_ac	0001_initial	2022-12-22 12:26:42.743007+00
504	sentry_plugins.hipchat_ac	0002_auto__del_mentionedevent	2022-12-22 12:26:42.934022+00
505	sentry_plugins.jira_ac	0001_initial	2022-12-22 12:27:02.565099+00
\.


--
-- Data for Name: tagstore_eventtag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagstore_eventtag (id, project_id, group_id, event_id, key_id, value_id, date_added) FROM stdin;
\.


--
-- Data for Name: tagstore_grouptagkey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagstore_grouptagkey (id, project_id, group_id, key_id, values_seen) FROM stdin;
\.


--
-- Data for Name: tagstore_grouptagvalue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagstore_grouptagvalue (id, project_id, group_id, times_seen, key_id, value_id, last_seen, first_seen) FROM stdin;
\.


--
-- Data for Name: tagstore_tagkey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagstore_tagkey (id, project_id, environment_id, key, values_seen, status) FROM stdin;
\.


--
-- Data for Name: tagstore_tagvalue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagstore_tagvalue (id, project_id, key_id, value, data, times_seen, last_seen, first_seen) FROM stdin;
\.


--
-- Name: auth_authenticator_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_authenticator_id_seq', 1, false);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 430, true);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 143, true);


--
-- Name: django_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_site_id_seq', 1, true);


--
-- Name: jira_ac_tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jira_ac_tenant_id_seq', 1, false);


--
-- Name: sentry_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_activity_id_seq', 1, false);


--
-- Name: sentry_apiapplication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_apiapplication_id_seq', 1, false);


--
-- Name: sentry_apiauthorization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_apiauthorization_id_seq', 1, false);


--
-- Name: sentry_apigrant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_apigrant_id_seq', 1, false);


--
-- Name: sentry_apikey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_apikey_id_seq', 1, false);


--
-- Name: sentry_apitoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_apitoken_id_seq', 1, true);


--
-- Name: sentry_assistant_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_assistant_activity_id_seq', 1, false);


--
-- Name: sentry_auditlogentry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_auditlogentry_id_seq', 1, false);


--
-- Name: sentry_authidentity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_authidentity_id_seq', 1, false);


--
-- Name: sentry_authprovider_default_teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_authprovider_default_teams_id_seq', 1, false);


--
-- Name: sentry_authprovider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_authprovider_id_seq', 1, false);


--
-- Name: sentry_broadcast_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_broadcast_id_seq', 1, false);


--
-- Name: sentry_broadcastseen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_broadcastseen_id_seq', 1, false);


--
-- Name: sentry_commit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_commit_id_seq', 1, false);


--
-- Name: sentry_commitauthor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_commitauthor_id_seq', 1, false);


--
-- Name: sentry_commitfilechange_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_commitfilechange_id_seq', 1, false);


--
-- Name: sentry_dashboard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_dashboard_id_seq', 1, false);


--
-- Name: sentry_deletedorganization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_deletedorganization_id_seq', 1, false);


--
-- Name: sentry_deletedproject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_deletedproject_id_seq', 1, false);


--
-- Name: sentry_deletedteam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_deletedteam_id_seq', 1, false);


--
-- Name: sentry_deploy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_deploy_id_seq', 1, false);


--
-- Name: sentry_discoversavedquery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_discoversavedquery_id_seq', 1, false);


--
-- Name: sentry_discoversavedqueryproject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_discoversavedqueryproject_id_seq', 1, false);


--
-- Name: sentry_distribution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_distribution_id_seq', 1, false);


--
-- Name: sentry_email_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_email_id_seq', 1, true);


--
-- Name: sentry_environment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_environment_id_seq', 1, false);


--
-- Name: sentry_environmentproject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_environmentproject_id_seq', 1, false);


--
-- Name: sentry_environmentrelease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_environmentrelease_id_seq', 1, false);


--
-- Name: sentry_eventattachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_eventattachment_id_seq', 1, false);


--
-- Name: sentry_eventmapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_eventmapping_id_seq', 1, false);


--
-- Name: sentry_eventprocessingissue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_eventprocessingissue_id_seq', 1, false);


--
-- Name: sentry_eventtag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_eventtag_id_seq', 1, false);


--
-- Name: sentry_eventuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_eventuser_id_seq', 1, false);


--
-- Name: sentry_externalissue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_externalissue_id_seq', 1, false);


--
-- Name: sentry_featureadoption_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_featureadoption_id_seq', 1, false);


--
-- Name: sentry_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_file_id_seq', 1, false);


--
-- Name: sentry_fileblob_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_fileblob_id_seq', 1, false);


--
-- Name: sentry_fileblobindex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_fileblobindex_id_seq', 1, false);


--
-- Name: sentry_fileblobowner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_fileblobowner_id_seq', 1, false);


--
-- Name: sentry_filterkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_filterkey_id_seq', 1, false);


--
-- Name: sentry_filtervalue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_filtervalue_id_seq', 1, false);


--
-- Name: sentry_groupasignee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupasignee_id_seq', 1, false);


--
-- Name: sentry_groupbookmark_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupbookmark_id_seq', 1, false);


--
-- Name: sentry_groupcommitresolution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupcommitresolution_id_seq', 1, false);


--
-- Name: sentry_groupedmessage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupedmessage_id_seq', 1, false);


--
-- Name: sentry_groupemailthread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupemailthread_id_seq', 1, false);


--
-- Name: sentry_groupenvironment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupenvironment_id_seq', 1, false);


--
-- Name: sentry_grouphash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouphash_id_seq', 1, false);


--
-- Name: sentry_grouplink_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouplink_id_seq', 1, false);


--
-- Name: sentry_groupmeta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupmeta_id_seq', 1, false);


--
-- Name: sentry_groupredirect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupredirect_id_seq', 1, false);


--
-- Name: sentry_grouprelease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouprelease_id_seq', 1, false);


--
-- Name: sentry_groupresolution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupresolution_id_seq', 1, false);


--
-- Name: sentry_grouprulestatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouprulestatus_id_seq', 1, false);


--
-- Name: sentry_groupseen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupseen_id_seq', 1, false);


--
-- Name: sentry_groupshare_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupshare_id_seq', 1, false);


--
-- Name: sentry_groupsnooze_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupsnooze_id_seq', 1, false);


--
-- Name: sentry_groupsubscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_groupsubscription_id_seq', 1, false);


--
-- Name: sentry_grouptagkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouptagkey_id_seq', 1, false);


--
-- Name: sentry_grouptombstone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_grouptombstone_id_seq', 1, false);


--
-- Name: sentry_hipchat_ac_tenant_organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_hipchat_ac_tenant_organizations_id_seq', 1, false);


--
-- Name: sentry_hipchat_ac_tenant_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_hipchat_ac_tenant_projects_id_seq', 1, false);


--
-- Name: sentry_identity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_identity_id_seq', 1, false);


--
-- Name: sentry_identityprovider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_identityprovider_id_seq', 1, false);


--
-- Name: sentry_integration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_integration_id_seq', 1, false);


--
-- Name: sentry_integrationexternalproject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_integrationexternalproject_id_seq', 1, false);


--
-- Name: sentry_latestrelease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_latestrelease_id_seq', 1, false);


--
-- Name: sentry_lostpasswordhash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_lostpasswordhash_id_seq', 1, false);


--
-- Name: sentry_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_message_id_seq', 1, false);


--
-- Name: sentry_messagefiltervalue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_messagefiltervalue_id_seq', 1, false);


--
-- Name: sentry_messageindex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_messageindex_id_seq', 1, false);


--
-- Name: sentry_monitor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_monitor_id_seq', 1, false);


--
-- Name: sentry_monitorcheckin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_monitorcheckin_id_seq', 1, false);


--
-- Name: sentry_monitorlocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_monitorlocation_id_seq', 1, false);


--
-- Name: sentry_option_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_option_id_seq', 4, true);


--
-- Name: sentry_organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organization_id_seq', 1, true);


--
-- Name: sentry_organizationaccessrequest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationaccessrequest_id_seq', 1, false);


--
-- Name: sentry_organizationavatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationavatar_id_seq', 1, false);


--
-- Name: sentry_organizationintegration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationintegration_id_seq', 1, false);


--
-- Name: sentry_organizationmember_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationmember_id_seq', 1, true);


--
-- Name: sentry_organizationmember_teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationmember_teams_id_seq', 1, true);


--
-- Name: sentry_organizationonboardingtask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationonboardingtask_id_seq', 1, false);


--
-- Name: sentry_organizationoptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_organizationoptions_id_seq', 1, false);


--
-- Name: sentry_platformexternalissue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_platformexternalissue_id_seq', 1, false);


--
-- Name: sentry_processingissue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_processingissue_id_seq', 1, false);


--
-- Name: sentry_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_project_id_seq', 1, true);


--
-- Name: sentry_projectavatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectavatar_id_seq', 1, false);


--
-- Name: sentry_projectbookmark_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectbookmark_id_seq', 1, false);


--
-- Name: sentry_projectcficachefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectcficachefile_id_seq', 1, false);


--
-- Name: sentry_projectcounter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectcounter_id_seq', 1, false);


--
-- Name: sentry_projectdsymfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectdsymfile_id_seq', 1, false);


--
-- Name: sentry_projectintegration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectintegration_id_seq', 1, false);


--
-- Name: sentry_projectkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectkey_id_seq', 1, true);


--
-- Name: sentry_projectoptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectoptions_id_seq', 3, true);


--
-- Name: sentry_projectownership_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectownership_id_seq', 1, false);


--
-- Name: sentry_projectplatform_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectplatform_id_seq', 1, false);


--
-- Name: sentry_projectredirect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectredirect_id_seq', 1, false);


--
-- Name: sentry_projectsymcachefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectsymcachefile_id_seq', 1, false);


--
-- Name: sentry_projectteam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_projectteam_id_seq', 1, true);


--
-- Name: sentry_promptsactivity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_promptsactivity_id_seq', 1, false);


--
-- Name: sentry_pull_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_pull_request_id_seq', 1, false);


--
-- Name: sentry_pullrequest_commit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_pullrequest_commit_id_seq', 1, false);


--
-- Name: sentry_rawevent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_rawevent_id_seq', 1, false);


--
-- Name: sentry_recentsearch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_recentsearch_id_seq', 1, false);


--
-- Name: sentry_relay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_relay_id_seq', 1, false);


--
-- Name: sentry_release_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_release_id_seq', 1, false);


--
-- Name: sentry_release_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_release_project_id_seq', 1, false);


--
-- Name: sentry_releasecommit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_releasecommit_id_seq', 1, false);


--
-- Name: sentry_releasefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_releasefile_id_seq', 1, false);


--
-- Name: sentry_releaseheadcommit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_releaseheadcommit_id_seq', 1, false);


--
-- Name: sentry_releaseprojectenvironment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_releaseprojectenvironment_id_seq', 1, false);


--
-- Name: sentry_repository_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_repository_id_seq', 1, false);


--
-- Name: sentry_reprocessingreport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_reprocessingreport_id_seq', 1, false);


--
-- Name: sentry_rule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_rule_id_seq', 1, true);


--
-- Name: sentry_savedsearch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_savedsearch_id_seq', 11, true);


--
-- Name: sentry_savedsearch_userdefault_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_savedsearch_userdefault_id_seq', 1, false);


--
-- Name: sentry_scheduleddeletion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_scheduleddeletion_id_seq', 1, false);


--
-- Name: sentry_scheduledjob_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_scheduledjob_id_seq', 1, false);


--
-- Name: sentry_sentryapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_sentryapp_id_seq', 1, false);


--
-- Name: sentry_sentryappavatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_sentryappavatar_id_seq', 1, false);


--
-- Name: sentry_sentryappcomponent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_sentryappcomponent_id_seq', 1, false);


--
-- Name: sentry_sentryappinstallation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_sentryappinstallation_id_seq', 1, false);


--
-- Name: sentry_servicehook_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_servicehook_id_seq', 1, false);


--
-- Name: sentry_servicehookproject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_servicehookproject_id_seq', 1, false);


--
-- Name: sentry_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_team_id_seq', 1, true);


--
-- Name: sentry_teamavatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_teamavatar_id_seq', 1, false);


--
-- Name: sentry_useravatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_useravatar_id_seq', 1, false);


--
-- Name: sentry_useremail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_useremail_id_seq', 1, true);


--
-- Name: sentry_userip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_userip_id_seq', 1, true);


--
-- Name: sentry_useroption_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_useroption_id_seq', 1, false);


--
-- Name: sentry_userpermission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_userpermission_id_seq', 1, false);


--
-- Name: sentry_userreport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_userreport_id_seq', 1, false);


--
-- Name: sentry_widget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_widget_id_seq', 1, false);


--
-- Name: sentry_widgetdatasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sentry_widgetdatasource_id_seq', 1, false);


--
-- Name: social_auth_usersocialauth_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.social_auth_usersocialauth_id_seq', 1, false);


--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.south_migrationhistory_id_seq', 505, true);


--
-- Name: tagstore_eventtag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagstore_eventtag_id_seq', 1, false);


--
-- Name: tagstore_grouptagkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagstore_grouptagkey_id_seq', 1, false);


--
-- Name: tagstore_grouptagvalue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagstore_grouptagvalue_id_seq', 1, false);


--
-- Name: tagstore_tagkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagstore_tagkey_id_seq', 1, false);


--
-- Name: tagstore_tagvalue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagstore_tagvalue_id_seq', 1, false);


--
-- Name: auth_authenticator auth_authenticator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_authenticator
    ADD CONSTRAINT auth_authenticator_pkey PRIMARY KEY (id);


--
-- Name: auth_authenticator auth_authenticator_user_id_5774ed51577668d4_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_authenticator
    ADD CONSTRAINT auth_authenticator_user_id_5774ed51577668d4_uniq UNIQUE (user_id, type);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_key UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_key UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_key UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: jira_ac_tenant jira_ac_tenant_client_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jira_ac_tenant
    ADD CONSTRAINT jira_ac_tenant_client_key_key UNIQUE (client_key);


--
-- Name: jira_ac_tenant jira_ac_tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jira_ac_tenant
    ADD CONSTRAINT jira_ac_tenant_pkey PRIMARY KEY (id);


--
-- Name: nodestore_node nodestore_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nodestore_node
    ADD CONSTRAINT nodestore_node_pkey PRIMARY KEY (id);


--
-- Name: sentry_activity sentry_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_activity
    ADD CONSTRAINT sentry_activity_pkey PRIMARY KEY (id);


--
-- Name: sentry_apiapplication sentry_apiapplication_client_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiapplication
    ADD CONSTRAINT sentry_apiapplication_client_id_key UNIQUE (client_id);


--
-- Name: sentry_apiapplication sentry_apiapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiapplication
    ADD CONSTRAINT sentry_apiapplication_pkey PRIMARY KEY (id);


--
-- Name: sentry_apiauthorization sentry_apiauthorization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiauthorization
    ADD CONSTRAINT sentry_apiauthorization_pkey PRIMARY KEY (id);


--
-- Name: sentry_apiauthorization sentry_apiauthorization_user_id_eb16c64a7b6db1c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiauthorization
    ADD CONSTRAINT sentry_apiauthorization_user_id_eb16c64a7b6db1c_uniq UNIQUE (user_id, application_id);


--
-- Name: sentry_apigrant sentry_apigrant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apigrant
    ADD CONSTRAINT sentry_apigrant_pkey PRIMARY KEY (id);


--
-- Name: sentry_apikey sentry_apikey_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apikey
    ADD CONSTRAINT sentry_apikey_key_key UNIQUE (key);


--
-- Name: sentry_apikey sentry_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apikey
    ADD CONSTRAINT sentry_apikey_pkey PRIMARY KEY (id);


--
-- Name: sentry_apitoken sentry_apitoken_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken
    ADD CONSTRAINT sentry_apitoken_pkey PRIMARY KEY (id);


--
-- Name: sentry_apitoken sentry_apitoken_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken
    ADD CONSTRAINT sentry_apitoken_refresh_token_key UNIQUE (refresh_token);


--
-- Name: sentry_apitoken sentry_apitoken_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken
    ADD CONSTRAINT sentry_apitoken_token_key UNIQUE (token);


--
-- Name: sentry_assistant_activity sentry_assistant_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_assistant_activity
    ADD CONSTRAINT sentry_assistant_activity_pkey PRIMARY KEY (id);


--
-- Name: sentry_assistant_activity sentry_assistant_activity_user_id_63ff4731f0f1d7f9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_assistant_activity
    ADD CONSTRAINT sentry_assistant_activity_user_id_63ff4731f0f1d7f9_uniq UNIQUE (user_id, guide_id);


--
-- Name: sentry_auditlogentry sentry_auditlogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry
    ADD CONSTRAINT sentry_auditlogentry_pkey PRIMARY KEY (id);


--
-- Name: sentry_authidentity sentry_authidentity_auth_provider_id_2ac89deececdc9d7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity
    ADD CONSTRAINT sentry_authidentity_auth_provider_id_2ac89deececdc9d7_uniq UNIQUE (auth_provider_id, user_id);


--
-- Name: sentry_authidentity sentry_authidentity_auth_provider_id_72ab4375ecd728ba_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity
    ADD CONSTRAINT sentry_authidentity_auth_provider_id_72ab4375ecd728ba_uniq UNIQUE (auth_provider_id, ident);


--
-- Name: sentry_authidentity sentry_authidentity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity
    ADD CONSTRAINT sentry_authidentity_pkey PRIMARY KEY (id);


--
-- Name: sentry_authprovider_default_teams sentry_authprovider_defau_authprovider_id_352ee7f2584f4caf_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider_default_teams
    ADD CONSTRAINT sentry_authprovider_defau_authprovider_id_352ee7f2584f4caf_uniq UNIQUE (authprovider_id, team_id);


--
-- Name: sentry_authprovider_default_teams sentry_authprovider_default_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider_default_teams
    ADD CONSTRAINT sentry_authprovider_default_teams_pkey PRIMARY KEY (id);


--
-- Name: sentry_authprovider sentry_authprovider_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider
    ADD CONSTRAINT sentry_authprovider_organization_id_key UNIQUE (organization_id);


--
-- Name: sentry_authprovider sentry_authprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider
    ADD CONSTRAINT sentry_authprovider_pkey PRIMARY KEY (id);


--
-- Name: sentry_broadcast sentry_broadcast_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcast
    ADD CONSTRAINT sentry_broadcast_pkey PRIMARY KEY (id);


--
-- Name: sentry_broadcastseen sentry_broadcastseen_broadcast_id_352c833420c70bd9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcastseen
    ADD CONSTRAINT sentry_broadcastseen_broadcast_id_352c833420c70bd9_uniq UNIQUE (broadcast_id, user_id);


--
-- Name: sentry_broadcastseen sentry_broadcastseen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcastseen
    ADD CONSTRAINT sentry_broadcastseen_pkey PRIMARY KEY (id);


--
-- Name: sentry_commit sentry_commit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commit
    ADD CONSTRAINT sentry_commit_pkey PRIMARY KEY (id);


--
-- Name: sentry_commit sentry_commit_repository_id_2d25b4d8949fca93_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commit
    ADD CONSTRAINT sentry_commit_repository_id_2d25b4d8949fca93_uniq UNIQUE (repository_id, key);


--
-- Name: sentry_commitauthor sentry_commitauthor_organization_id_3cdc85e9f09bf3f3_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitauthor
    ADD CONSTRAINT sentry_commitauthor_organization_id_3cdc85e9f09bf3f3_uniq UNIQUE (organization_id, external_id);


--
-- Name: sentry_commitauthor sentry_commitauthor_organization_id_5656e6a6baa5f6c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitauthor
    ADD CONSTRAINT sentry_commitauthor_organization_id_5656e6a6baa5f6c_uniq UNIQUE (organization_id, email);


--
-- Name: sentry_commitauthor sentry_commitauthor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitauthor
    ADD CONSTRAINT sentry_commitauthor_pkey PRIMARY KEY (id);


--
-- Name: sentry_commitfilechange sentry_commitfilechange_commit_id_4c6f7ec25af34227_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitfilechange
    ADD CONSTRAINT sentry_commitfilechange_commit_id_4c6f7ec25af34227_uniq UNIQUE (commit_id, filename);


--
-- Name: sentry_commitfilechange sentry_commitfilechange_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitfilechange
    ADD CONSTRAINT sentry_commitfilechange_pkey PRIMARY KEY (id);


--
-- Name: sentry_dashboard sentry_dashboard_organization_id_6a0d54ced7f271ab_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_dashboard
    ADD CONSTRAINT sentry_dashboard_organization_id_6a0d54ced7f271ab_uniq UNIQUE (organization_id, title);


--
-- Name: sentry_dashboard sentry_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_dashboard
    ADD CONSTRAINT sentry_dashboard_pkey PRIMARY KEY (id);


--
-- Name: sentry_deletedorganization sentry_deletedorganization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedorganization
    ADD CONSTRAINT sentry_deletedorganization_pkey PRIMARY KEY (id);


--
-- Name: sentry_deletedproject sentry_deletedproject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedproject
    ADD CONSTRAINT sentry_deletedproject_pkey PRIMARY KEY (id);


--
-- Name: sentry_deletedteam sentry_deletedteam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deletedteam
    ADD CONSTRAINT sentry_deletedteam_pkey PRIMARY KEY (id);


--
-- Name: sentry_deploy sentry_deploy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deploy
    ADD CONSTRAINT sentry_deploy_pkey PRIMARY KEY (id);


--
-- Name: sentry_discoversavedquery sentry_discoversavedquery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedquery
    ADD CONSTRAINT sentry_discoversavedquery_pkey PRIMARY KEY (id);


--
-- Name: sentry_discoversavedqueryproject sentry_discoversavedqueryproje_project_id_4b4c62b89b0f85a5_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedqueryproject
    ADD CONSTRAINT sentry_discoversavedqueryproje_project_id_4b4c62b89b0f85a5_uniq UNIQUE (project_id, discover_saved_query_id);


--
-- Name: sentry_discoversavedqueryproject sentry_discoversavedqueryproject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedqueryproject
    ADD CONSTRAINT sentry_discoversavedqueryproject_pkey PRIMARY KEY (id);


--
-- Name: sentry_distribution sentry_distribution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_distribution
    ADD CONSTRAINT sentry_distribution_pkey PRIMARY KEY (id);


--
-- Name: sentry_distribution sentry_distribution_release_id_42bfea790c978c1b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_distribution
    ADD CONSTRAINT sentry_distribution_release_id_42bfea790c978c1b_uniq UNIQUE (release_id, name);


--
-- Name: sentry_email sentry_email_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_email
    ADD CONSTRAINT sentry_email_email_key UNIQUE (email);


--
-- Name: sentry_email sentry_email_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_email
    ADD CONSTRAINT sentry_email_pkey PRIMARY KEY (id);


--
-- Name: sentry_environment sentry_environment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environment
    ADD CONSTRAINT sentry_environment_pkey PRIMARY KEY (id);


--
-- Name: sentry_environmentproject sentry_environmentproject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentproject
    ADD CONSTRAINT sentry_environmentproject_pkey PRIMARY KEY (id);


--
-- Name: sentry_environmentproject sentry_environmentproject_project_id_29250c1307d3722b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentproject
    ADD CONSTRAINT sentry_environmentproject_project_id_29250c1307d3722b_uniq UNIQUE (project_id, environment_id);


--
-- Name: sentry_environmentrelease sentry_environmentrelease_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentrelease
    ADD CONSTRAINT sentry_environmentrelease_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventattachment sentry_eventattachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventattachment
    ADD CONSTRAINT sentry_eventattachment_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventattachment sentry_eventattachment_project_id_157332be57815660_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventattachment
    ADD CONSTRAINT sentry_eventattachment_project_id_157332be57815660_uniq UNIQUE (project_id, event_id, file_id);


--
-- Name: sentry_eventmapping sentry_eventmapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventmapping
    ADD CONSTRAINT sentry_eventmapping_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventmapping sentry_eventmapping_project_id_eb6c54bf8930ba6_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventmapping
    ADD CONSTRAINT sentry_eventmapping_project_id_eb6c54bf8930ba6_uniq UNIQUE (project_id, event_id);


--
-- Name: sentry_eventprocessingissue sentry_eventprocessingissue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventprocessingissue
    ADD CONSTRAINT sentry_eventprocessingissue_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventprocessingissue sentry_eventprocessingissue_raw_event_id_7751571083fd0f14_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventprocessingissue
    ADD CONSTRAINT sentry_eventprocessingissue_raw_event_id_7751571083fd0f14_uniq UNIQUE (raw_event_id, processing_issue_id);


--
-- Name: sentry_eventtag sentry_eventtag_event_id_430cef8ef4186908_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventtag
    ADD CONSTRAINT sentry_eventtag_event_id_430cef8ef4186908_uniq UNIQUE (event_id, key_id, value_id);


--
-- Name: sentry_eventtag sentry_eventtag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventtag
    ADD CONSTRAINT sentry_eventtag_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventuser sentry_eventuser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventuser
    ADD CONSTRAINT sentry_eventuser_pkey PRIMARY KEY (id);


--
-- Name: sentry_eventuser sentry_eventuser_project_id_1a96e3b719e55f9a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventuser
    ADD CONSTRAINT sentry_eventuser_project_id_1a96e3b719e55f9a_uniq UNIQUE (project_id, hash);


--
-- Name: sentry_eventuser sentry_eventuser_project_id_1dcb94833e2de5cf_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventuser
    ADD CONSTRAINT sentry_eventuser_project_id_1dcb94833e2de5cf_uniq UNIQUE (project_id, ident);


--
-- Name: sentry_externalissue sentry_externalissue_organization_id_3e15847c42683d85_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_externalissue
    ADD CONSTRAINT sentry_externalissue_organization_id_3e15847c42683d85_uniq UNIQUE (organization_id, integration_id, key);


--
-- Name: sentry_externalissue sentry_externalissue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_externalissue
    ADD CONSTRAINT sentry_externalissue_pkey PRIMARY KEY (id);


--
-- Name: sentry_featureadoption sentry_featureadoption_organization_id_78451b8747a9e638_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_featureadoption
    ADD CONSTRAINT sentry_featureadoption_organization_id_78451b8747a9e638_uniq UNIQUE (organization_id, feature_id);


--
-- Name: sentry_featureadoption sentry_featureadoption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_featureadoption
    ADD CONSTRAINT sentry_featureadoption_pkey PRIMARY KEY (id);


--
-- Name: sentry_file sentry_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_file
    ADD CONSTRAINT sentry_file_pkey PRIMARY KEY (id);


--
-- Name: sentry_fileblob sentry_fileblob_checksum_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblob
    ADD CONSTRAINT sentry_fileblob_checksum_key UNIQUE (checksum);


--
-- Name: sentry_fileblob sentry_fileblob_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblob
    ADD CONSTRAINT sentry_fileblob_pkey PRIMARY KEY (id);


--
-- Name: sentry_fileblobindex sentry_fileblobindex_file_id_56d11844195e33b2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobindex
    ADD CONSTRAINT sentry_fileblobindex_file_id_56d11844195e33b2_uniq UNIQUE (file_id, blob_id, "offset");


--
-- Name: sentry_fileblobindex sentry_fileblobindex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobindex
    ADD CONSTRAINT sentry_fileblobindex_pkey PRIMARY KEY (id);


--
-- Name: sentry_fileblobowner sentry_fileblobowner_blob_id_78037767e8554f2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobowner
    ADD CONSTRAINT sentry_fileblobowner_blob_id_78037767e8554f2_uniq UNIQUE (blob_id, organization_id);


--
-- Name: sentry_fileblobowner sentry_fileblobowner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobowner
    ADD CONSTRAINT sentry_fileblobowner_pkey PRIMARY KEY (id);


--
-- Name: sentry_filterkey sentry_filterkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filterkey
    ADD CONSTRAINT sentry_filterkey_pkey PRIMARY KEY (id);


--
-- Name: sentry_filterkey sentry_filterkey_project_id_67551b8e28dda5a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filterkey
    ADD CONSTRAINT sentry_filterkey_project_id_67551b8e28dda5a_uniq UNIQUE (project_id, key);


--
-- Name: sentry_filtervalue sentry_filtervalue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filtervalue
    ADD CONSTRAINT sentry_filtervalue_pkey PRIMARY KEY (id);


--
-- Name: sentry_filtervalue sentry_filtervalue_project_id_201b156195347397_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_filtervalue
    ADD CONSTRAINT sentry_filtervalue_project_id_201b156195347397_uniq UNIQUE (project_id, key, value);


--
-- Name: sentry_groupasignee sentry_groupasignee_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT sentry_groupasignee_group_id_key UNIQUE (group_id);


--
-- Name: sentry_groupasignee sentry_groupasignee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT sentry_groupasignee_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupbookmark sentry_groupbookmark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark
    ADD CONSTRAINT sentry_groupbookmark_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupbookmark sentry_groupbookmark_project_id_6d2bb88ad3832208_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark
    ADD CONSTRAINT sentry_groupbookmark_project_id_6d2bb88ad3832208_uniq UNIQUE (project_id, user_id, group_id);


--
-- Name: sentry_groupcommitresolution sentry_groupcommitresolution_group_id_c46e4845d76b4f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupcommitresolution
    ADD CONSTRAINT sentry_groupcommitresolution_group_id_c46e4845d76b4f_uniq UNIQUE (group_id, commit_id);


--
-- Name: sentry_groupcommitresolution sentry_groupcommitresolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupcommitresolution
    ADD CONSTRAINT sentry_groupcommitresolution_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupedmessage sentry_groupedmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupedmessage
    ADD CONSTRAINT sentry_groupedmessage_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupedmessage sentry_groupedmessage_project_id_680bfe5607002523_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupedmessage
    ADD CONSTRAINT sentry_groupedmessage_project_id_680bfe5607002523_uniq UNIQUE (project_id, short_id);


--
-- Name: sentry_groupemailthread sentry_groupemailthread_email_456f4d17524b316_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupemailthread
    ADD CONSTRAINT sentry_groupemailthread_email_456f4d17524b316_uniq UNIQUE (email, msgid);


--
-- Name: sentry_groupemailthread sentry_groupemailthread_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupemailthread
    ADD CONSTRAINT sentry_groupemailthread_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupenvironment sentry_groupenvironment_group_id_6b391aea0c56f32f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupenvironment
    ADD CONSTRAINT sentry_groupenvironment_group_id_6b391aea0c56f32f_uniq UNIQUE (group_id, environment_id);


--
-- Name: sentry_groupenvironment sentry_groupenvironment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupenvironment
    ADD CONSTRAINT sentry_groupenvironment_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouphash sentry_grouphash_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouphash
    ADD CONSTRAINT sentry_grouphash_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouphash sentry_grouphash_project_id_4a293f96a363c9a2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouphash
    ADD CONSTRAINT sentry_grouphash_project_id_4a293f96a363c9a2_uniq UNIQUE (project_id, hash);


--
-- Name: sentry_grouplink sentry_grouplink_group_id_73ee52490ebedd34_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouplink
    ADD CONSTRAINT sentry_grouplink_group_id_73ee52490ebedd34_uniq UNIQUE (group_id, linked_type, linked_id);


--
-- Name: sentry_grouplink sentry_grouplink_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouplink
    ADD CONSTRAINT sentry_grouplink_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupmeta sentry_groupmeta_key_5d9d7a3c6538b14d_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupmeta
    ADD CONSTRAINT sentry_groupmeta_key_5d9d7a3c6538b14d_uniq UNIQUE (key, group_id);


--
-- Name: sentry_groupmeta sentry_groupmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupmeta
    ADD CONSTRAINT sentry_groupmeta_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupredirect sentry_groupredirect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupredirect
    ADD CONSTRAINT sentry_groupredirect_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupredirect sentry_groupredirect_previous_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupredirect
    ADD CONSTRAINT sentry_groupredirect_previous_group_id_key UNIQUE (previous_group_id);


--
-- Name: sentry_grouprelease sentry_grouprelease_group_id_46ba6e430d088d04_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprelease
    ADD CONSTRAINT sentry_grouprelease_group_id_46ba6e430d088d04_uniq UNIQUE (group_id, release_id, environment);


--
-- Name: sentry_grouprelease sentry_grouprelease_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprelease
    ADD CONSTRAINT sentry_grouprelease_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupresolution sentry_groupresolution_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupresolution
    ADD CONSTRAINT sentry_groupresolution_group_id_key UNIQUE (group_id);


--
-- Name: sentry_groupresolution sentry_groupresolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupresolution
    ADD CONSTRAINT sentry_groupresolution_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouprulestatus sentry_grouprulestatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus
    ADD CONSTRAINT sentry_grouprulestatus_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouprulestatus sentry_grouprulestatus_rule_id_329bb0edaad3880f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus
    ADD CONSTRAINT sentry_grouprulestatus_rule_id_329bb0edaad3880f_uniq UNIQUE (rule_id, group_id);


--
-- Name: sentry_groupseen sentry_groupseen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen
    ADD CONSTRAINT sentry_groupseen_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupseen sentry_groupseen_user_id_179917bc9974d91b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen
    ADD CONSTRAINT sentry_groupseen_user_id_179917bc9974d91b_uniq UNIQUE (user_id, group_id);


--
-- Name: sentry_groupshare sentry_groupshare_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT sentry_groupshare_group_id_key UNIQUE (group_id);


--
-- Name: sentry_groupshare sentry_groupshare_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT sentry_groupshare_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupshare sentry_groupshare_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT sentry_groupshare_uuid_key UNIQUE (uuid);


--
-- Name: sentry_groupsnooze sentry_groupsnooze_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsnooze
    ADD CONSTRAINT sentry_groupsnooze_group_id_key UNIQUE (group_id);


--
-- Name: sentry_groupsnooze sentry_groupsnooze_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsnooze
    ADD CONSTRAINT sentry_groupsnooze_pkey PRIMARY KEY (id);


--
-- Name: sentry_groupsubscription sentry_groupsubscription_group_id_7e18bedd5058ccc3_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription
    ADD CONSTRAINT sentry_groupsubscription_group_id_7e18bedd5058ccc3_uniq UNIQUE (group_id, user_id);


--
-- Name: sentry_groupsubscription sentry_groupsubscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription
    ADD CONSTRAINT sentry_groupsubscription_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouptagkey sentry_grouptagkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptagkey
    ADD CONSTRAINT sentry_grouptagkey_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouptagkey sentry_grouptagkey_project_id_7b0c8092f47b509f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptagkey
    ADD CONSTRAINT sentry_grouptagkey_project_id_7b0c8092f47b509f_uniq UNIQUE (project_id, group_id, key);


--
-- Name: sentry_grouptombstone sentry_grouptombstone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptombstone
    ADD CONSTRAINT sentry_grouptombstone_pkey PRIMARY KEY (id);


--
-- Name: sentry_grouptombstone sentry_grouptombstone_previous_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptombstone
    ADD CONSTRAINT sentry_grouptombstone_previous_group_id_key UNIQUE (previous_group_id);


--
-- Name: sentry_hipchat_ac_tenant_organizations sentry_hipchat_ac_tenant_organi_tenant_id_277f40009a2aa417_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_organizations
    ADD CONSTRAINT sentry_hipchat_ac_tenant_organi_tenant_id_277f40009a2aa417_uniq UNIQUE (tenant_id, organization_id);


--
-- Name: sentry_hipchat_ac_tenant_organizations sentry_hipchat_ac_tenant_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_organizations
    ADD CONSTRAINT sentry_hipchat_ac_tenant_organizations_pkey PRIMARY KEY (id);


--
-- Name: sentry_hipchat_ac_tenant sentry_hipchat_ac_tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant
    ADD CONSTRAINT sentry_hipchat_ac_tenant_pkey PRIMARY KEY (id);


--
-- Name: sentry_hipchat_ac_tenant_projects sentry_hipchat_ac_tenant_projec_tenant_id_5308544b484f49a9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_projects
    ADD CONSTRAINT sentry_hipchat_ac_tenant_projec_tenant_id_5308544b484f49a9_uniq UNIQUE (tenant_id, project_id);


--
-- Name: sentry_hipchat_ac_tenant_projects sentry_hipchat_ac_tenant_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_projects
    ADD CONSTRAINT sentry_hipchat_ac_tenant_projects_pkey PRIMARY KEY (id);


--
-- Name: sentry_identity sentry_identity_idp_id_2355d6c6ee4f8b24_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity
    ADD CONSTRAINT sentry_identity_idp_id_2355d6c6ee4f8b24_uniq UNIQUE (idp_id, user_id);


--
-- Name: sentry_identity sentry_identity_idp_id_47d379630426f630_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity
    ADD CONSTRAINT sentry_identity_idp_id_47d379630426f630_uniq UNIQUE (idp_id, external_id);


--
-- Name: sentry_identity sentry_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity
    ADD CONSTRAINT sentry_identity_pkey PRIMARY KEY (id);


--
-- Name: sentry_identityprovider sentry_identityprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identityprovider
    ADD CONSTRAINT sentry_identityprovider_pkey PRIMARY KEY (id);


--
-- Name: sentry_identityprovider sentry_identityprovider_type_244d1ca4a8bc0cec_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identityprovider
    ADD CONSTRAINT sentry_identityprovider_type_244d1ca4a8bc0cec_uniq UNIQUE (type, external_id);


--
-- Name: sentry_integrationexternalproject sentry_integr_organization_integration_id_41be9b8c4d9f13f6_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integrationexternalproject
    ADD CONSTRAINT sentry_integr_organization_integration_id_41be9b8c4d9f13f6_uniq UNIQUE (organization_integration_id, external_id);


--
-- Name: sentry_integration sentry_integration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integration
    ADD CONSTRAINT sentry_integration_pkey PRIMARY KEY (id);


--
-- Name: sentry_integration sentry_integration_provider_e9944c77818d5f5_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integration
    ADD CONSTRAINT sentry_integration_provider_e9944c77818d5f5_uniq UNIQUE (provider, external_id);


--
-- Name: sentry_integrationexternalproject sentry_integrationexternalproject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_integrationexternalproject
    ADD CONSTRAINT sentry_integrationexternalproject_pkey PRIMARY KEY (id);


--
-- Name: sentry_latestrelease sentry_latestrelease_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_latestrelease
    ADD CONSTRAINT sentry_latestrelease_pkey PRIMARY KEY (id);


--
-- Name: sentry_latestrelease sentry_latestrelease_repository_id_72410a59af97f654_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_latestrelease
    ADD CONSTRAINT sentry_latestrelease_repository_id_72410a59af97f654_uniq UNIQUE (repository_id, environment_id);


--
-- Name: sentry_lostpasswordhash sentry_lostpasswordhash_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_lostpasswordhash
    ADD CONSTRAINT sentry_lostpasswordhash_pkey PRIMARY KEY (id);


--
-- Name: sentry_lostpasswordhash sentry_lostpasswordhash_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_lostpasswordhash
    ADD CONSTRAINT sentry_lostpasswordhash_user_id_key UNIQUE (user_id);


--
-- Name: sentry_message sentry_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_message
    ADD CONSTRAINT sentry_message_pkey PRIMARY KEY (id);


--
-- Name: sentry_message sentry_message_project_id_b6b4e75e438ca83_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_message
    ADD CONSTRAINT sentry_message_project_id_b6b4e75e438ca83_uniq UNIQUE (project_id, message_id);


--
-- Name: sentry_messagefiltervalue sentry_messagefiltervalue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_messagefiltervalue
    ADD CONSTRAINT sentry_messagefiltervalue_pkey PRIMARY KEY (id);


--
-- Name: sentry_messageindex sentry_messageindex_column_23431fca14e385c1_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_messageindex
    ADD CONSTRAINT sentry_messageindex_column_23431fca14e385c1_uniq UNIQUE ("column", value, object_id);


--
-- Name: sentry_messageindex sentry_messageindex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_messageindex
    ADD CONSTRAINT sentry_messageindex_pkey PRIMARY KEY (id);


--
-- Name: sentry_monitor sentry_monitor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitor
    ADD CONSTRAINT sentry_monitor_pkey PRIMARY KEY (id);


--
-- Name: sentry_monitorcheckin sentry_monitorcheckin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorcheckin
    ADD CONSTRAINT sentry_monitorcheckin_pkey PRIMARY KEY (id);


--
-- Name: sentry_monitorlocation sentry_monitorlocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorlocation
    ADD CONSTRAINT sentry_monitorlocation_pkey PRIMARY KEY (id);


--
-- Name: sentry_option sentry_option_key_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_option
    ADD CONSTRAINT sentry_option_key_uniq UNIQUE (key);


--
-- Name: sentry_option sentry_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_option
    ADD CONSTRAINT sentry_option_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationmember_teams sentry_organization_organizationmember_id_1634015042409685_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember_teams
    ADD CONSTRAINT sentry_organization_organizationmember_id_1634015042409685_uniq UNIQUE (organizationmember_id, team_id);


--
-- Name: sentry_organization sentry_organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organization
    ADD CONSTRAINT sentry_organization_pkey PRIMARY KEY (id);


--
-- Name: sentry_organization sentry_organization_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organization
    ADD CONSTRAINT sentry_organization_slug_key UNIQUE (slug);


--
-- Name: sentry_organizationaccessrequest sentry_organizationaccessrequest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationaccessrequest
    ADD CONSTRAINT sentry_organizationaccessrequest_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationaccessrequest sentry_organizationaccessrequest_team_id_2a38219fe738f1d7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationaccessrequest
    ADD CONSTRAINT sentry_organizationaccessrequest_team_id_2a38219fe738f1d7_uniq UNIQUE (team_id, member_id);


--
-- Name: sentry_organizationavatar sentry_organizationavatar_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT sentry_organizationavatar_file_id_key UNIQUE (file_id);


--
-- Name: sentry_organizationavatar sentry_organizationavatar_ident_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT sentry_organizationavatar_ident_key UNIQUE (ident);


--
-- Name: sentry_organizationavatar sentry_organizationavatar_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT sentry_organizationavatar_organization_id_key UNIQUE (organization_id);


--
-- Name: sentry_organizationavatar sentry_organizationavatar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT sentry_organizationavatar_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationintegration sentry_organizationintegr_organization_id_77bd763ea752b4b7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationintegration
    ADD CONSTRAINT sentry_organizationintegr_organization_id_77bd763ea752b4b7_uniq UNIQUE (organization_id, integration_id);


--
-- Name: sentry_organizationintegration sentry_organizationintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationintegration
    ADD CONSTRAINT sentry_organizationintegration_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationmember sentry_organizationmember_organization_id_404770fc5e3a794_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT sentry_organizationmember_organization_id_404770fc5e3a794_uniq UNIQUE (organization_id, user_id);


--
-- Name: sentry_organizationmember sentry_organizationmember_organization_id_59ee8d99c683b0e7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT sentry_organizationmember_organization_id_59ee8d99c683b0e7_uniq UNIQUE (organization_id, email);


--
-- Name: sentry_organizationmember sentry_organizationmember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT sentry_organizationmember_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationmember_teams sentry_organizationmember_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember_teams
    ADD CONSTRAINT sentry_organizationmember_teams_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationmember sentry_organizationmember_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT sentry_organizationmember_token_key UNIQUE (token);


--
-- Name: sentry_organizationonboardingtask sentry_organizationonboar_organization_id_47e98e05cae29cf3_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationonboardingtask
    ADD CONSTRAINT sentry_organizationonboar_organization_id_47e98e05cae29cf3_uniq UNIQUE (organization_id, task);


--
-- Name: sentry_organizationonboardingtask sentry_organizationonboardingtask_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationonboardingtask
    ADD CONSTRAINT sentry_organizationonboardingtask_pkey PRIMARY KEY (id);


--
-- Name: sentry_organizationoptions sentry_organizationoption_organization_id_613ac9b501bd6e71_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationoptions
    ADD CONSTRAINT sentry_organizationoption_organization_id_613ac9b501bd6e71_uniq UNIQUE (organization_id, key);


--
-- Name: sentry_organizationoptions sentry_organizationoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationoptions
    ADD CONSTRAINT sentry_organizationoptions_pkey PRIMARY KEY (id);


--
-- Name: sentry_platformexternalissue sentry_platformexternalissue_group_id_7a4ac4d34cc5224a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_platformexternalissue
    ADD CONSTRAINT sentry_platformexternalissue_group_id_7a4ac4d34cc5224a_uniq UNIQUE (group_id, service_type);


--
-- Name: sentry_platformexternalissue sentry_platformexternalissue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_platformexternalissue
    ADD CONSTRAINT sentry_platformexternalissue_pkey PRIMARY KEY (id);


--
-- Name: sentry_processingissue sentry_processingissue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_processingissue
    ADD CONSTRAINT sentry_processingissue_pkey PRIMARY KEY (id);


--
-- Name: sentry_processingissue sentry_processingissue_project_id_4cf2c364095eb2b9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_processingissue
    ADD CONSTRAINT sentry_processingissue_project_id_4cf2c364095eb2b9_uniq UNIQUE (project_id, checksum, type);


--
-- Name: sentry_project sentry_project_organization_id_3017a54aeb676236_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_project
    ADD CONSTRAINT sentry_project_organization_id_3017a54aeb676236_uniq UNIQUE (organization_id, slug);


--
-- Name: sentry_project sentry_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_project
    ADD CONSTRAINT sentry_project_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectavatar sentry_projectavatar_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT sentry_projectavatar_file_id_key UNIQUE (file_id);


--
-- Name: sentry_projectavatar sentry_projectavatar_ident_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT sentry_projectavatar_ident_key UNIQUE (ident);


--
-- Name: sentry_projectavatar sentry_projectavatar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT sentry_projectavatar_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectavatar sentry_projectavatar_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT sentry_projectavatar_project_id_key UNIQUE (project_id);


--
-- Name: sentry_projectbookmark sentry_projectbookmark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectbookmark
    ADD CONSTRAINT sentry_projectbookmark_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectbookmark sentry_projectbookmark_project_id_450321e77adb9106_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectbookmark
    ADD CONSTRAINT sentry_projectbookmark_project_id_450321e77adb9106_uniq UNIQUE (project_id, user_id);


--
-- Name: sentry_projectcficachefile sentry_projectcficachefile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile
    ADD CONSTRAINT sentry_projectcficachefile_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectcficachefile sentry_projectcficachefile_project_id_6223b471c7fff044_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile
    ADD CONSTRAINT sentry_projectcficachefile_project_id_6223b471c7fff044_uniq UNIQUE (project_id, dsym_file_id);


--
-- Name: sentry_projectcounter sentry_projectcounter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcounter
    ADD CONSTRAINT sentry_projectcounter_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectcounter sentry_projectcounter_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcounter
    ADD CONSTRAINT sentry_projectcounter_project_id_key UNIQUE (project_id);


--
-- Name: sentry_projectdsymfile sentry_projectdsymfile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectdsymfile
    ADD CONSTRAINT sentry_projectdsymfile_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectintegration sentry_projectintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectintegration
    ADD CONSTRAINT sentry_projectintegration_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectintegration sentry_projectintegration_project_id_b772982487a62fd_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectintegration
    ADD CONSTRAINT sentry_projectintegration_project_id_b772982487a62fd_uniq UNIQUE (project_id, integration_id);


--
-- Name: sentry_projectkey sentry_projectkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectkey
    ADD CONSTRAINT sentry_projectkey_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectkey sentry_projectkey_public_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectkey
    ADD CONSTRAINT sentry_projectkey_public_key_key UNIQUE (public_key);


--
-- Name: sentry_projectkey sentry_projectkey_secret_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectkey
    ADD CONSTRAINT sentry_projectkey_secret_key_key UNIQUE (secret_key);


--
-- Name: sentry_projectoptions sentry_projectoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectoptions
    ADD CONSTRAINT sentry_projectoptions_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectoptions sentry_projectoptions_project_id_2d0b5c5d84cdbe8f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectoptions
    ADD CONSTRAINT sentry_projectoptions_project_id_2d0b5c5d84cdbe8f_uniq UNIQUE (project_id, key);


--
-- Name: sentry_projectownership sentry_projectownership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectownership
    ADD CONSTRAINT sentry_projectownership_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectownership sentry_projectownership_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectownership
    ADD CONSTRAINT sentry_projectownership_project_id_key UNIQUE (project_id);


--
-- Name: sentry_projectplatform sentry_projectplatform_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectplatform
    ADD CONSTRAINT sentry_projectplatform_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectplatform sentry_projectplatform_project_id_4750cc420a30bf84_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectplatform
    ADD CONSTRAINT sentry_projectplatform_project_id_4750cc420a30bf84_uniq UNIQUE (project_id, platform);


--
-- Name: sentry_projectredirect sentry_projectredirect_organization_id_4af3204682f7beca_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectredirect
    ADD CONSTRAINT sentry_projectredirect_organization_id_4af3204682f7beca_uniq UNIQUE (organization_id, redirect_slug);


--
-- Name: sentry_projectredirect sentry_projectredirect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectredirect
    ADD CONSTRAINT sentry_projectredirect_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectsymcachefile sentry_projectsymcachefile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile
    ADD CONSTRAINT sentry_projectsymcachefile_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectsymcachefile sentry_projectsymcachefile_project_id_1d82672e636477c9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile
    ADD CONSTRAINT sentry_projectsymcachefile_project_id_1d82672e636477c9_uniq UNIQUE (project_id, dsym_file_id);


--
-- Name: sentry_projectteam sentry_projectteam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectteam
    ADD CONSTRAINT sentry_projectteam_pkey PRIMARY KEY (id);


--
-- Name: sentry_projectteam sentry_projectteam_project_id_4b99b03421a3c6e9_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectteam
    ADD CONSTRAINT sentry_projectteam_project_id_4b99b03421a3c6e9_uniq UNIQUE (project_id, team_id);


--
-- Name: sentry_promptsactivity sentry_promptsactivity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_promptsactivity
    ADD CONSTRAINT sentry_promptsactivity_pkey PRIMARY KEY (id);


--
-- Name: sentry_promptsactivity sentry_promptsactivity_user_id_71757f214e5509d4_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_promptsactivity
    ADD CONSTRAINT sentry_promptsactivity_user_id_71757f214e5509d4_uniq UNIQUE (user_id, feature, organization_id, project_id);


--
-- Name: sentry_pull_request sentry_pull_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pull_request
    ADD CONSTRAINT sentry_pull_request_pkey PRIMARY KEY (id);


--
-- Name: sentry_pull_request sentry_pull_request_repository_id_281e60c02c27ae91_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pull_request
    ADD CONSTRAINT sentry_pull_request_repository_id_281e60c02c27ae91_uniq UNIQUE (repository_id, key);


--
-- Name: sentry_pullrequest_commit sentry_pullrequest_commit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pullrequest_commit
    ADD CONSTRAINT sentry_pullrequest_commit_pkey PRIMARY KEY (id);


--
-- Name: sentry_pullrequest_commit sentry_pullrequest_commit_pull_request_id_2247e8c7140cbd07_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pullrequest_commit
    ADD CONSTRAINT sentry_pullrequest_commit_pull_request_id_2247e8c7140cbd07_uniq UNIQUE (pull_request_id, commit_id);


--
-- Name: sentry_rawevent sentry_rawevent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rawevent
    ADD CONSTRAINT sentry_rawevent_pkey PRIMARY KEY (id);


--
-- Name: sentry_rawevent sentry_rawevent_project_id_67074d89f7075a2e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rawevent
    ADD CONSTRAINT sentry_rawevent_project_id_67074d89f7075a2e_uniq UNIQUE (project_id, event_id);


--
-- Name: sentry_recentsearch sentry_recentsearch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_recentsearch
    ADD CONSTRAINT sentry_recentsearch_pkey PRIMARY KEY (id);


--
-- Name: sentry_recentsearch sentry_recentsearch_user_id_6a0df1c80b29d349_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_recentsearch
    ADD CONSTRAINT sentry_recentsearch_user_id_6a0df1c80b29d349_uniq UNIQUE (user_id, organization_id, type, query_hash);


--
-- Name: sentry_relay sentry_relay_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_relay
    ADD CONSTRAINT sentry_relay_pkey PRIMARY KEY (id);


--
-- Name: sentry_relay sentry_relay_relay_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_relay
    ADD CONSTRAINT sentry_relay_relay_id_key UNIQUE (relay_id);


--
-- Name: sentry_release sentry_release_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release
    ADD CONSTRAINT sentry_release_pkey PRIMARY KEY (id);


--
-- Name: sentry_release_project sentry_release_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release_project
    ADD CONSTRAINT sentry_release_project_pkey PRIMARY KEY (id);


--
-- Name: sentry_release_project sentry_release_project_project_id_35add08b8e678ec7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release_project
    ADD CONSTRAINT sentry_release_project_project_id_35add08b8e678ec7_uniq UNIQUE (project_id, release_id);


--
-- Name: sentry_releasecommit sentry_releasecommit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit
    ADD CONSTRAINT sentry_releasecommit_pkey PRIMARY KEY (id);


--
-- Name: sentry_releasecommit sentry_releasecommit_release_id_4394bda1d741e954_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit
    ADD CONSTRAINT sentry_releasecommit_release_id_4394bda1d741e954_uniq UNIQUE (release_id, "order");


--
-- Name: sentry_releasecommit sentry_releasecommit_release_id_4ce87699e8e032b3_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit
    ADD CONSTRAINT sentry_releasecommit_release_id_4ce87699e8e032b3_uniq UNIQUE (release_id, commit_id);


--
-- Name: sentry_releasefile sentry_releasefile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT sentry_releasefile_pkey PRIMARY KEY (id);


--
-- Name: sentry_releasefile sentry_releasefile_release_id_7809ae7ca24c9589_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT sentry_releasefile_release_id_7809ae7ca24c9589_uniq UNIQUE (release_id, ident);


--
-- Name: sentry_releaseheadcommit sentry_releaseheadcommit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseheadcommit
    ADD CONSTRAINT sentry_releaseheadcommit_pkey PRIMARY KEY (id);


--
-- Name: sentry_releaseheadcommit sentry_releaseheadcommit_repository_id_401c869de623265e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseheadcommit
    ADD CONSTRAINT sentry_releaseheadcommit_repository_id_401c869de623265e_uniq UNIQUE (repository_id, release_id);


--
-- Name: sentry_releaseprojectenvironment sentry_releaseprojectenvironmen_project_id_d2be2f28c78caf7_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment
    ADD CONSTRAINT sentry_releaseprojectenvironmen_project_id_d2be2f28c78caf7_uniq UNIQUE (project_id, release_id, environment_id);


--
-- Name: sentry_releaseprojectenvironment sentry_releaseprojectenvironment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment
    ADD CONSTRAINT sentry_releaseprojectenvironment_pkey PRIMARY KEY (id);


--
-- Name: sentry_repository sentry_repository_organization_id_2bbb7c67744745b6_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_repository
    ADD CONSTRAINT sentry_repository_organization_id_2bbb7c67744745b6_uniq UNIQUE (organization_id, name);


--
-- Name: sentry_repository sentry_repository_organization_id_6369691ee795aeaf_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_repository
    ADD CONSTRAINT sentry_repository_organization_id_6369691ee795aeaf_uniq UNIQUE (organization_id, provider, external_id);


--
-- Name: sentry_repository sentry_repository_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_repository
    ADD CONSTRAINT sentry_repository_pkey PRIMARY KEY (id);


--
-- Name: sentry_reprocessingreport sentry_reprocessingreport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_reprocessingreport
    ADD CONSTRAINT sentry_reprocessingreport_pkey PRIMARY KEY (id);


--
-- Name: sentry_reprocessingreport sentry_reprocessingreport_project_id_1b8c4565a54fb40e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_reprocessingreport
    ADD CONSTRAINT sentry_reprocessingreport_project_id_1b8c4565a54fb40e_uniq UNIQUE (project_id, event_id);


--
-- Name: sentry_rule sentry_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rule
    ADD CONSTRAINT sentry_rule_pkey PRIMARY KEY (id);


--
-- Name: sentry_savedsearch sentry_savedsearch_organization_id_48379b0f7f6794f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT sentry_savedsearch_organization_id_48379b0f7f6794f_uniq UNIQUE (organization_id, owner_id, type);


--
-- Name: sentry_savedsearch sentry_savedsearch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT sentry_savedsearch_pkey PRIMARY KEY (id);


--
-- Name: sentry_savedsearch sentry_savedsearch_project_id_4a2cf58e27d0cc59_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT sentry_savedsearch_project_id_4a2cf58e27d0cc59_uniq UNIQUE (project_id, name);


--
-- Name: sentry_savedsearch_userdefault sentry_savedsearch_userdefault_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault
    ADD CONSTRAINT sentry_savedsearch_userdefault_pkey PRIMARY KEY (id);


--
-- Name: sentry_savedsearch_userdefault sentry_savedsearch_userdefault_project_id_19fbb9813d6a20ef_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault
    ADD CONSTRAINT sentry_savedsearch_userdefault_project_id_19fbb9813d6a20ef_uniq UNIQUE (project_id, user_id);


--
-- Name: sentry_scheduleddeletion sentry_scheduleddeletion_app_label_740edc97d666ad4_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduleddeletion
    ADD CONSTRAINT sentry_scheduleddeletion_app_label_740edc97d666ad4_uniq UNIQUE (app_label, model_name, object_id);


--
-- Name: sentry_scheduleddeletion sentry_scheduleddeletion_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduleddeletion
    ADD CONSTRAINT sentry_scheduleddeletion_guid_key UNIQUE (guid);


--
-- Name: sentry_scheduleddeletion sentry_scheduleddeletion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduleddeletion
    ADD CONSTRAINT sentry_scheduleddeletion_pkey PRIMARY KEY (id);


--
-- Name: sentry_scheduledjob sentry_scheduledjob_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_scheduledjob
    ADD CONSTRAINT sentry_scheduledjob_pkey PRIMARY KEY (id);


--
-- Name: sentry_sentryapp sentry_sentryapp_application_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT sentry_sentryapp_application_id_key UNIQUE (application_id);


--
-- Name: sentry_sentryapp sentry_sentryapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT sentry_sentryapp_pkey PRIMARY KEY (id);


--
-- Name: sentry_sentryapp sentry_sentryapp_proxy_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT sentry_sentryapp_proxy_user_id_key UNIQUE (proxy_user_id);


--
-- Name: sentry_sentryapp sentry_sentryapp_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT sentry_sentryapp_slug_key UNIQUE (slug);


--
-- Name: sentry_sentryappavatar sentry_sentryappavatar_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT sentry_sentryappavatar_file_id_key UNIQUE (file_id);


--
-- Name: sentry_sentryappavatar sentry_sentryappavatar_ident_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT sentry_sentryappavatar_ident_key UNIQUE (ident);


--
-- Name: sentry_sentryappavatar sentry_sentryappavatar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT sentry_sentryappavatar_pkey PRIMARY KEY (id);


--
-- Name: sentry_sentryappavatar sentry_sentryappavatar_sentry_app_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT sentry_sentryappavatar_sentry_app_id_key UNIQUE (sentry_app_id);


--
-- Name: sentry_sentryappcomponent sentry_sentryappcomponent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappcomponent
    ADD CONSTRAINT sentry_sentryappcomponent_pkey PRIMARY KEY (id);


--
-- Name: sentry_sentryappcomponent sentry_sentryappcomponent_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappcomponent
    ADD CONSTRAINT sentry_sentryappcomponent_uuid_key UNIQUE (uuid);


--
-- Name: sentry_sentryappinstallation sentry_sentryappinstallation_api_grant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT sentry_sentryappinstallation_api_grant_id_key UNIQUE (api_grant_id);


--
-- Name: sentry_sentryappinstallation sentry_sentryappinstallation_authorization_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT sentry_sentryappinstallation_authorization_id_key UNIQUE (authorization_id);


--
-- Name: sentry_sentryappinstallation sentry_sentryappinstallation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT sentry_sentryappinstallation_pkey PRIMARY KEY (id);


--
-- Name: sentry_servicehook sentry_servicehook_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehook
    ADD CONSTRAINT sentry_servicehook_guid_key UNIQUE (guid);


--
-- Name: sentry_servicehook sentry_servicehook_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehook
    ADD CONSTRAINT sentry_servicehook_pkey PRIMARY KEY (id);


--
-- Name: sentry_servicehookproject sentry_servicehookproject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehookproject
    ADD CONSTRAINT sentry_servicehookproject_pkey PRIMARY KEY (id);


--
-- Name: sentry_team sentry_team_organization_id_1e0ece47434a2ed_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_team
    ADD CONSTRAINT sentry_team_organization_id_1e0ece47434a2ed_uniq UNIQUE (organization_id, slug);


--
-- Name: sentry_team sentry_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_team
    ADD CONSTRAINT sentry_team_pkey PRIMARY KEY (id);


--
-- Name: sentry_teamavatar sentry_teamavatar_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT sentry_teamavatar_file_id_key UNIQUE (file_id);


--
-- Name: sentry_teamavatar sentry_teamavatar_ident_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT sentry_teamavatar_ident_key UNIQUE (ident);


--
-- Name: sentry_teamavatar sentry_teamavatar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT sentry_teamavatar_pkey PRIMARY KEY (id);


--
-- Name: sentry_teamavatar sentry_teamavatar_team_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT sentry_teamavatar_team_id_key UNIQUE (team_id);


--
-- Name: sentry_useravatar sentry_useravatar_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT sentry_useravatar_file_id_key UNIQUE (file_id);


--
-- Name: sentry_useravatar sentry_useravatar_ident_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT sentry_useravatar_ident_key UNIQUE (ident);


--
-- Name: sentry_useravatar sentry_useravatar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT sentry_useravatar_pkey PRIMARY KEY (id);


--
-- Name: sentry_useravatar sentry_useravatar_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT sentry_useravatar_user_id_key UNIQUE (user_id);


--
-- Name: sentry_useremail sentry_useremail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useremail
    ADD CONSTRAINT sentry_useremail_pkey PRIMARY KEY (id);


--
-- Name: sentry_useremail sentry_useremail_user_id_469ffbb142507df2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useremail
    ADD CONSTRAINT sentry_useremail_user_id_469ffbb142507df2_uniq UNIQUE (user_id, email);


--
-- Name: sentry_userip sentry_userip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userip
    ADD CONSTRAINT sentry_userip_pkey PRIMARY KEY (id);


--
-- Name: sentry_userip sentry_userip_user_id_5e5a95a35f9f6063_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userip
    ADD CONSTRAINT sentry_userip_user_id_5e5a95a35f9f6063_uniq UNIQUE (user_id, ip_address);


--
-- Name: sentry_useroption sentry_useroption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT sentry_useroption_pkey PRIMARY KEY (id);


--
-- Name: sentry_useroption sentry_useroption_user_id_4d4ce0b1f7bb578b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT sentry_useroption_user_id_4d4ce0b1f7bb578b_uniq UNIQUE (user_id, project_id, key);


--
-- Name: sentry_useroption sentry_useroption_user_id_7d51ec93e4fc570e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT sentry_useroption_user_id_7d51ec93e4fc570e_uniq UNIQUE (user_id, organization_id, key);


--
-- Name: sentry_userpermission sentry_userpermission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userpermission
    ADD CONSTRAINT sentry_userpermission_pkey PRIMARY KEY (id);


--
-- Name: sentry_userpermission sentry_userpermission_user_id_2617e7a04f784a10_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userpermission
    ADD CONSTRAINT sentry_userpermission_user_id_2617e7a04f784a10_uniq UNIQUE (user_id, permission);


--
-- Name: sentry_userreport sentry_userreport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport
    ADD CONSTRAINT sentry_userreport_pkey PRIMARY KEY (id);


--
-- Name: sentry_userreport sentry_userreport_project_id_1ac377e052723c91_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport
    ADD CONSTRAINT sentry_userreport_project_id_1ac377e052723c91_uniq UNIQUE (project_id, event_id);


--
-- Name: sentry_widget sentry_widget_dashboard_id_1f954428c0ab12c0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widget
    ADD CONSTRAINT sentry_widget_dashboard_id_1f954428c0ab12c0_uniq UNIQUE (dashboard_id, "order");


--
-- Name: sentry_widget sentry_widget_dashboard_id_34b4d393729c7d82_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widget
    ADD CONSTRAINT sentry_widget_dashboard_id_34b4d393729c7d82_uniq UNIQUE (dashboard_id, title);


--
-- Name: sentry_widget sentry_widget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widget
    ADD CONSTRAINT sentry_widget_pkey PRIMARY KEY (id);


--
-- Name: sentry_widgetdatasource sentry_widgetdatasource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widgetdatasource
    ADD CONSTRAINT sentry_widgetdatasource_pkey PRIMARY KEY (id);


--
-- Name: sentry_widgetdatasource sentry_widgetdatasource_widget_id_178ae87e7aeaebe6_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widgetdatasource
    ADD CONSTRAINT sentry_widgetdatasource_widget_id_178ae87e7aeaebe6_uniq UNIQUE (widget_id, name);


--
-- Name: sentry_widgetdatasource sentry_widgetdatasource_widget_id_785f0baf52dc0e02_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widgetdatasource
    ADD CONSTRAINT sentry_widgetdatasource_widget_id_785f0baf52dc0e02_uniq UNIQUE (widget_id, "order");


--
-- Name: social_auth_usersocialauth social_auth_usersocialauth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_auth_usersocialauth
    ADD CONSTRAINT social_auth_usersocialauth_pkey PRIMARY KEY (id);


--
-- Name: social_auth_usersocialauth social_auth_usersocialauth_provider_69933d2ea493fc8c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_auth_usersocialauth
    ADD CONSTRAINT social_auth_usersocialauth_provider_69933d2ea493fc8c_uniq UNIQUE (provider, uid, user_id);


--
-- Name: south_migrationhistory south_migrationhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.south_migrationhistory
    ADD CONSTRAINT south_migrationhistory_pkey PRIMARY KEY (id);


--
-- Name: tagstore_eventtag tagstore_eventtag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_eventtag
    ADD CONSTRAINT tagstore_eventtag_pkey PRIMARY KEY (id);


--
-- Name: tagstore_eventtag tagstore_eventtag_project_id_be033ea3de90db0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_eventtag
    ADD CONSTRAINT tagstore_eventtag_project_id_be033ea3de90db0_uniq UNIQUE (project_id, event_id, key_id, value_id);


--
-- Name: tagstore_grouptagkey tagstore_grouptagkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagkey
    ADD CONSTRAINT tagstore_grouptagkey_pkey PRIMARY KEY (id);


--
-- Name: tagstore_grouptagkey tagstore_grouptagkey_project_id_704698b8620b6fd2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagkey
    ADD CONSTRAINT tagstore_grouptagkey_project_id_704698b8620b6fd2_uniq UNIQUE (project_id, group_id, key_id);


--
-- Name: tagstore_grouptagvalue tagstore_grouptagvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagvalue
    ADD CONSTRAINT tagstore_grouptagvalue_pkey PRIMARY KEY (id);


--
-- Name: tagstore_grouptagvalue tagstore_grouptagvalue_project_id_54aadd1ff1633928_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagvalue
    ADD CONSTRAINT tagstore_grouptagvalue_project_id_54aadd1ff1633928_uniq UNIQUE (project_id, group_id, key_id, value_id);


--
-- Name: tagstore_tagkey tagstore_tagkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagkey
    ADD CONSTRAINT tagstore_tagkey_pkey PRIMARY KEY (id);


--
-- Name: tagstore_tagkey tagstore_tagkey_project_id_91aff351fd9ee2b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagkey
    ADD CONSTRAINT tagstore_tagkey_project_id_91aff351fd9ee2b_uniq UNIQUE (project_id, environment_id, key);


--
-- Name: tagstore_tagvalue tagstore_tagvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagvalue
    ADD CONSTRAINT tagstore_tagvalue_pkey PRIMARY KEY (id);


--
-- Name: tagstore_tagvalue tagstore_tagvalue_project_id_90bbcbdf6a46fc1_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagvalue
    ADD CONSTRAINT tagstore_tagvalue_project_id_90bbcbdf6a46fc1_uniq UNIQUE (project_id, key_id, value);


--
-- Name: auth_authenticator_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_authenticator_user_id ON public.auth_authenticator USING btree (user_id);


--
-- Name: auth_group_name_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_username_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: jira_ac_tenant_client_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jira_ac_tenant_client_key_like ON public.jira_ac_tenant USING btree (client_key varchar_pattern_ops);


--
-- Name: jira_ac_tenant_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jira_ac_tenant_organization_id ON public.jira_ac_tenant USING btree (organization_id);


--
-- Name: nodestore_node_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nodestore_node_id_like ON public.nodestore_node USING btree (id varchar_pattern_ops);


--
-- Name: nodestore_node_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nodestore_node_timestamp ON public.nodestore_node USING btree ("timestamp");


--
-- Name: sentry_activity_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_activity_group_id ON public.sentry_activity USING btree (group_id);


--
-- Name: sentry_activity_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_activity_project_id ON public.sentry_activity USING btree (project_id);


--
-- Name: sentry_activity_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_activity_user_id ON public.sentry_activity USING btree (user_id);


--
-- Name: sentry_apiapplication_client_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apiapplication_client_id_like ON public.sentry_apiapplication USING btree (client_id varchar_pattern_ops);


--
-- Name: sentry_apiapplication_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apiapplication_owner_id ON public.sentry_apiapplication USING btree (owner_id);


--
-- Name: sentry_apiapplication_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apiapplication_status ON public.sentry_apiapplication USING btree (status);


--
-- Name: sentry_apiauthorization_application_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apiauthorization_application_id ON public.sentry_apiauthorization USING btree (application_id);


--
-- Name: sentry_apiauthorization_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apiauthorization_user_id ON public.sentry_apiauthorization USING btree (user_id);


--
-- Name: sentry_apigrant_application_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apigrant_application_id ON public.sentry_apigrant USING btree (application_id);


--
-- Name: sentry_apigrant_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apigrant_code ON public.sentry_apigrant USING btree (code);


--
-- Name: sentry_apigrant_code_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apigrant_code_like ON public.sentry_apigrant USING btree (code varchar_pattern_ops);


--
-- Name: sentry_apigrant_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apigrant_expires_at ON public.sentry_apigrant USING btree (expires_at);


--
-- Name: sentry_apigrant_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apigrant_user_id ON public.sentry_apigrant USING btree (user_id);


--
-- Name: sentry_apikey_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apikey_key_like ON public.sentry_apikey USING btree (key varchar_pattern_ops);


--
-- Name: sentry_apikey_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apikey_organization_id ON public.sentry_apikey USING btree (organization_id);


--
-- Name: sentry_apikey_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apikey_status ON public.sentry_apikey USING btree (status);


--
-- Name: sentry_apitoken_application_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apitoken_application_id ON public.sentry_apitoken USING btree (application_id);


--
-- Name: sentry_apitoken_refresh_token_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apitoken_refresh_token_like ON public.sentry_apitoken USING btree (refresh_token varchar_pattern_ops);


--
-- Name: sentry_apitoken_token_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apitoken_token_like ON public.sentry_apitoken USING btree (token varchar_pattern_ops);


--
-- Name: sentry_apitoken_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_apitoken_user_id ON public.sentry_apitoken USING btree (user_id);


--
-- Name: sentry_assistant_activity_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_assistant_activity_user_id ON public.sentry_assistant_activity USING btree (user_id);


--
-- Name: sentry_auditlogentry_actor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_auditlogentry_actor_id ON public.sentry_auditlogentry USING btree (actor_id);


--
-- Name: sentry_auditlogentry_actor_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_auditlogentry_actor_key_id ON public.sentry_auditlogentry USING btree (actor_key_id);


--
-- Name: sentry_auditlogentry_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_auditlogentry_organization_id ON public.sentry_auditlogentry USING btree (organization_id);


--
-- Name: sentry_auditlogentry_target_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_auditlogentry_target_user_id ON public.sentry_auditlogentry USING btree (target_user_id);


--
-- Name: sentry_authidentity_auth_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_authidentity_auth_provider_id ON public.sentry_authidentity USING btree (auth_provider_id);


--
-- Name: sentry_authidentity_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_authidentity_user_id ON public.sentry_authidentity USING btree (user_id);


--
-- Name: sentry_authprovider_default_teams_authprovider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_authprovider_default_teams_authprovider_id ON public.sentry_authprovider_default_teams USING btree (authprovider_id);


--
-- Name: sentry_authprovider_default_teams_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_authprovider_default_teams_team_id ON public.sentry_authprovider_default_teams USING btree (team_id);


--
-- Name: sentry_broadcast_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_broadcast_is_active ON public.sentry_broadcast USING btree (is_active);


--
-- Name: sentry_broadcastseen_broadcast_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_broadcastseen_broadcast_id ON public.sentry_broadcastseen USING btree (broadcast_id);


--
-- Name: sentry_broadcastseen_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_broadcastseen_user_id ON public.sentry_broadcastseen USING btree (user_id);


--
-- Name: sentry_commit_author_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commit_author_id ON public.sentry_commit USING btree (author_id);


--
-- Name: sentry_commit_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commit_organization_id ON public.sentry_commit USING btree (organization_id);


--
-- Name: sentry_commit_repository_id_5b0d06238a42bbfc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commit_repository_id_5b0d06238a42bbfc ON public.sentry_commit USING btree (repository_id, date_added);


--
-- Name: sentry_commitauthor_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commitauthor_organization_id ON public.sentry_commitauthor USING btree (organization_id);


--
-- Name: sentry_commitfilechange_commit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commitfilechange_commit_id ON public.sentry_commitfilechange USING btree (commit_id);


--
-- Name: sentry_commitfilechange_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_commitfilechange_organization_id ON public.sentry_commitfilechange USING btree (organization_id);


--
-- Name: sentry_dashboard_created_by_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_dashboard_created_by_id ON public.sentry_dashboard USING btree (created_by_id);


--
-- Name: sentry_dashboard_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_dashboard_organization_id ON public.sentry_dashboard USING btree (organization_id);


--
-- Name: sentry_deploy_environment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_deploy_environment_id ON public.sentry_deploy USING btree (environment_id);


--
-- Name: sentry_deploy_notified; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_deploy_notified ON public.sentry_deploy USING btree (notified);


--
-- Name: sentry_deploy_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_deploy_organization_id ON public.sentry_deploy USING btree (organization_id);


--
-- Name: sentry_deploy_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_deploy_release_id ON public.sentry_deploy USING btree (release_id);


--
-- Name: sentry_discoversavedquery_created_by_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_discoversavedquery_created_by_id ON public.sentry_discoversavedquery USING btree (created_by_id);


--
-- Name: sentry_discoversavedquery_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_discoversavedquery_organization_id ON public.sentry_discoversavedquery USING btree (organization_id);


--
-- Name: sentry_discoversavedqueryproject_discover_saved_query_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_discoversavedqueryproject_discover_saved_query_id ON public.sentry_discoversavedqueryproject USING btree (discover_saved_query_id);


--
-- Name: sentry_discoversavedqueryproject_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_discoversavedqueryproject_project_id ON public.sentry_discoversavedqueryproject USING btree (project_id);


--
-- Name: sentry_distribution_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_distribution_organization_id ON public.sentry_distribution USING btree (organization_id);


--
-- Name: sentry_distribution_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_distribution_release_id ON public.sentry_distribution USING btree (release_id);


--
-- Name: sentry_environment_organization_id_6c9098a3d53d6a9a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_environment_organization_id_6c9098a3d53d6a9a ON public.sentry_environment USING btree (organization_id, name);


--
-- Name: sentry_environmentproject_environment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentproject_environment_id ON public.sentry_environmentproject USING btree (environment_id);


--
-- Name: sentry_environmentproject_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentproject_project_id ON public.sentry_environmentproject USING btree (project_id);


--
-- Name: sentry_environmentrelease_environment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentrelease_environment_id ON public.sentry_environmentrelease USING btree (environment_id);


--
-- Name: sentry_environmentrelease_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentrelease_last_seen ON public.sentry_environmentrelease USING btree (last_seen);


--
-- Name: sentry_environmentrelease_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentrelease_organization_id ON public.sentry_environmentrelease USING btree (organization_id);


--
-- Name: sentry_environmentrelease_organization_id_394c1c5e67253784; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_environmentrelease_organization_id_394c1c5e67253784 ON public.sentry_environmentrelease USING btree (organization_id, release_id, environment_id);


--
-- Name: sentry_environmentrelease_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_environmentrelease_release_id ON public.sentry_environmentrelease USING btree (release_id);


--
-- Name: sentry_eventattachment_date_added; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventattachment_date_added ON public.sentry_eventattachment USING btree (date_added);


--
-- Name: sentry_eventattachment_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventattachment_event_id ON public.sentry_eventattachment USING btree (event_id);


--
-- Name: sentry_eventattachment_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventattachment_file_id ON public.sentry_eventattachment USING btree (file_id);


--
-- Name: sentry_eventattachment_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventattachment_group_id ON public.sentry_eventattachment USING btree (group_id);


--
-- Name: sentry_eventattachment_project_id_25d761e1f446d2ff; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventattachment_project_id_25d761e1f446d2ff ON public.sentry_eventattachment USING btree (project_id, date_added);


--
-- Name: sentry_eventmapping_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventmapping_group_id ON public.sentry_eventmapping USING btree (group_id);


--
-- Name: sentry_eventmapping_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventmapping_project_id ON public.sentry_eventmapping USING btree (project_id);


--
-- Name: sentry_eventprocessingissue_processing_issue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventprocessingissue_processing_issue_id ON public.sentry_eventprocessingissue USING btree (processing_issue_id);


--
-- Name: sentry_eventprocessingissue_raw_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventprocessingissue_raw_event_id ON public.sentry_eventprocessingissue USING btree (raw_event_id);


--
-- Name: sentry_eventtag_date_added; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventtag_date_added ON public.sentry_eventtag USING btree (date_added);


--
-- Name: sentry_eventtag_group_id_5ad9abfe8e1fa62b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventtag_group_id_5ad9abfe8e1fa62b ON public.sentry_eventtag USING btree (group_id, key_id, value_id);


--
-- Name: sentry_eventuser_date_added; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventuser_date_added ON public.sentry_eventuser USING btree (date_added);


--
-- Name: sentry_eventuser_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventuser_project_id ON public.sentry_eventuser USING btree (project_id);


--
-- Name: sentry_eventuser_project_id_58b4a7f2595290e6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventuser_project_id_58b4a7f2595290e6 ON public.sentry_eventuser USING btree (project_id, ip_address);


--
-- Name: sentry_eventuser_project_id_7684267daffc292f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventuser_project_id_7684267daffc292f ON public.sentry_eventuser USING btree (project_id, email);


--
-- Name: sentry_eventuser_project_id_8868307f60b6a92; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_eventuser_project_id_8868307f60b6a92 ON public.sentry_eventuser USING btree (project_id, username);


--
-- Name: sentry_featureadoption_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_featureadoption_organization_id ON public.sentry_featureadoption USING btree (organization_id);


--
-- Name: sentry_file_blob_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_file_blob_id ON public.sentry_file USING btree (blob_id);


--
-- Name: sentry_file_checksum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_file_checksum ON public.sentry_file USING btree (checksum);


--
-- Name: sentry_file_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_file_timestamp ON public.sentry_file USING btree ("timestamp");


--
-- Name: sentry_fileblob_checksum_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblob_checksum_like ON public.sentry_fileblob USING btree (checksum varchar_pattern_ops);


--
-- Name: sentry_fileblob_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblob_timestamp ON public.sentry_fileblob USING btree ("timestamp");


--
-- Name: sentry_fileblobindex_blob_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblobindex_blob_id ON public.sentry_fileblobindex USING btree (blob_id);


--
-- Name: sentry_fileblobindex_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblobindex_file_id ON public.sentry_fileblobindex USING btree (file_id);


--
-- Name: sentry_fileblobowner_blob_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblobowner_blob_id ON public.sentry_fileblobowner USING btree (blob_id);


--
-- Name: sentry_fileblobowner_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_fileblobowner_organization_id ON public.sentry_fileblobowner USING btree (organization_id);


--
-- Name: sentry_filterkey_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filterkey_project_id ON public.sentry_filterkey USING btree (project_id);


--
-- Name: sentry_filtervalue_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_first_seen ON public.sentry_filtervalue USING btree (first_seen);


--
-- Name: sentry_filtervalue_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_last_seen ON public.sentry_filtervalue USING btree (last_seen);


--
-- Name: sentry_filtervalue_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_project_id ON public.sentry_filtervalue USING btree (project_id);


--
-- Name: sentry_filtervalue_project_id_20cb80e47b504ee6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_project_id_20cb80e47b504ee6 ON public.sentry_filtervalue USING btree (project_id, key, last_seen);


--
-- Name: sentry_filtervalue_project_id_27377f6151fcab56; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_project_id_27377f6151fcab56 ON public.sentry_filtervalue USING btree (project_id, value, last_seen);


--
-- Name: sentry_filtervalue_project_id_2b3fdfeac62987c7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_project_id_2b3fdfeac62987c7 ON public.sentry_filtervalue USING btree (project_id, value, first_seen);


--
-- Name: sentry_filtervalue_project_id_737632cad2909511; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_filtervalue_project_id_737632cad2909511 ON public.sentry_filtervalue USING btree (project_id, value, times_seen);


--
-- Name: sentry_groupasignee_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupasignee_project_id ON public.sentry_groupasignee USING btree (project_id);


--
-- Name: sentry_groupasignee_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupasignee_team_id ON public.sentry_groupasignee USING btree (team_id);


--
-- Name: sentry_groupasignee_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupasignee_user_id ON public.sentry_groupasignee USING btree (user_id);


--
-- Name: sentry_groupbookmark_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupbookmark_group_id ON public.sentry_groupbookmark USING btree (group_id);


--
-- Name: sentry_groupbookmark_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupbookmark_project_id ON public.sentry_groupbookmark USING btree (project_id);


--
-- Name: sentry_groupbookmark_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupbookmark_user_id ON public.sentry_groupbookmark USING btree (user_id);


--
-- Name: sentry_groupbookmark_user_id_5eedb134f529cf58; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupbookmark_user_id_5eedb134f529cf58 ON public.sentry_groupbookmark USING btree (user_id, group_id);


--
-- Name: sentry_groupcommitresolution_commit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupcommitresolution_commit_id ON public.sentry_groupcommitresolution USING btree (commit_id);


--
-- Name: sentry_groupcommitresolution_datetime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupcommitresolution_datetime ON public.sentry_groupcommitresolution USING btree (datetime);


--
-- Name: sentry_groupedmessage_active_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_active_at ON public.sentry_groupedmessage USING btree (active_at);


--
-- Name: sentry_groupedmessage_first_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_first_release_id ON public.sentry_groupedmessage USING btree (first_release_id);


--
-- Name: sentry_groupedmessage_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_first_seen ON public.sentry_groupedmessage USING btree (first_seen);


--
-- Name: sentry_groupedmessage_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_last_seen ON public.sentry_groupedmessage USING btree (last_seen);


--
-- Name: sentry_groupedmessage_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_level ON public.sentry_groupedmessage USING btree (level);


--
-- Name: sentry_groupedmessage_logger; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_logger ON public.sentry_groupedmessage USING btree (logger);


--
-- Name: sentry_groupedmessage_logger_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_logger_like ON public.sentry_groupedmessage USING btree (logger varchar_pattern_ops);


--
-- Name: sentry_groupedmessage_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_project_id ON public.sentry_groupedmessage USING btree (project_id);


--
-- Name: sentry_groupedmessage_project_id_31335ae34c8ef983; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_project_id_31335ae34c8ef983 ON public.sentry_groupedmessage USING btree (project_id, first_release_id);


--
-- Name: sentry_groupedmessage_resolved_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_resolved_at ON public.sentry_groupedmessage USING btree (resolved_at);


--
-- Name: sentry_groupedmessage_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_status ON public.sentry_groupedmessage USING btree (status);


--
-- Name: sentry_groupedmessage_times_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_times_seen ON public.sentry_groupedmessage USING btree (times_seen);


--
-- Name: sentry_groupedmessage_view; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_view ON public.sentry_groupedmessage USING btree (view);


--
-- Name: sentry_groupedmessage_view_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupedmessage_view_like ON public.sentry_groupedmessage USING btree (view varchar_pattern_ops);


--
-- Name: sentry_groupemailthread_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupemailthread_date ON public.sentry_groupemailthread USING btree (date);


--
-- Name: sentry_groupemailthread_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupemailthread_group_id ON public.sentry_groupemailthread USING btree (group_id);


--
-- Name: sentry_groupemailthread_msgid_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupemailthread_msgid_like ON public.sentry_groupemailthread USING btree (msgid varchar_pattern_ops);


--
-- Name: sentry_groupemailthread_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupemailthread_project_id ON public.sentry_groupemailthread USING btree (project_id);


--
-- Name: sentry_groupenvironment_environment_id_602c33c133ccdf18; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupenvironment_environment_id_602c33c133ccdf18 ON public.sentry_groupenvironment USING btree (environment_id, first_release_id);


--
-- Name: sentry_groupenvironment_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupenvironment_first_seen ON public.sentry_groupenvironment USING btree (first_seen);


--
-- Name: sentry_grouphash_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouphash_group_id ON public.sentry_grouphash USING btree (group_id);


--
-- Name: sentry_grouphash_group_tombstone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouphash_group_tombstone_id ON public.sentry_grouphash USING btree (group_tombstone_id);


--
-- Name: sentry_grouphash_hash_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouphash_hash_like ON public.sentry_grouphash USING btree (hash varchar_pattern_ops);


--
-- Name: sentry_grouphash_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouphash_project_id ON public.sentry_grouphash USING btree (project_id);


--
-- Name: sentry_grouplink_datetime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouplink_datetime ON public.sentry_grouplink USING btree (datetime);


--
-- Name: sentry_grouplink_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouplink_project_id ON public.sentry_grouplink USING btree (project_id);


--
-- Name: sentry_groupmeta_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupmeta_group_id ON public.sentry_groupmeta USING btree (group_id);


--
-- Name: sentry_groupredirect_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupredirect_group_id ON public.sentry_groupredirect USING btree (group_id);


--
-- Name: sentry_grouprelease_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprelease_last_seen ON public.sentry_grouprelease USING btree (last_seen);


--
-- Name: sentry_grouprelease_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprelease_project_id ON public.sentry_grouprelease USING btree (project_id);


--
-- Name: sentry_grouprelease_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprelease_release_id ON public.sentry_grouprelease USING btree (release_id);


--
-- Name: sentry_groupresolution_datetime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupresolution_datetime ON public.sentry_groupresolution USING btree (datetime);


--
-- Name: sentry_groupresolution_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupresolution_release_id ON public.sentry_groupresolution USING btree (release_id);


--
-- Name: sentry_grouprulestatus_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprulestatus_group_id ON public.sentry_grouprulestatus USING btree (group_id);


--
-- Name: sentry_grouprulestatus_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprulestatus_project_id ON public.sentry_grouprulestatus USING btree (project_id);


--
-- Name: sentry_grouprulestatus_rule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouprulestatus_rule_id ON public.sentry_grouprulestatus USING btree (rule_id);


--
-- Name: sentry_groupseen_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupseen_group_id ON public.sentry_groupseen USING btree (group_id);


--
-- Name: sentry_groupseen_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupseen_project_id ON public.sentry_groupseen USING btree (project_id);


--
-- Name: sentry_groupshare_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupshare_project_id ON public.sentry_groupshare USING btree (project_id);


--
-- Name: sentry_groupshare_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupshare_user_id ON public.sentry_groupshare USING btree (user_id);


--
-- Name: sentry_groupshare_uuid_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupshare_uuid_like ON public.sentry_groupshare USING btree (uuid varchar_pattern_ops);


--
-- Name: sentry_groupsubscription_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupsubscription_group_id ON public.sentry_groupsubscription USING btree (group_id);


--
-- Name: sentry_groupsubscription_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupsubscription_project_id ON public.sentry_groupsubscription USING btree (project_id);


--
-- Name: sentry_groupsubscription_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_groupsubscription_user_id ON public.sentry_groupsubscription USING btree (user_id);


--
-- Name: sentry_grouptagkey_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouptagkey_group_id ON public.sentry_grouptagkey USING btree (group_id);


--
-- Name: sentry_grouptagkey_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouptagkey_project_id ON public.sentry_grouptagkey USING btree (project_id);


--
-- Name: sentry_grouptombstone_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_grouptombstone_project_id ON public.sentry_grouptombstone USING btree (project_id);


--
-- Name: sentry_hipchat_ac_tenant_auth_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_auth_user_id ON public.sentry_hipchat_ac_tenant USING btree (auth_user_id);


--
-- Name: sentry_hipchat_ac_tenant_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_id_like ON public.sentry_hipchat_ac_tenant USING btree (id varchar_pattern_ops);


--
-- Name: sentry_hipchat_ac_tenant_organizations_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_organizations_organization_id ON public.sentry_hipchat_ac_tenant_organizations USING btree (organization_id);


--
-- Name: sentry_hipchat_ac_tenant_organizations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_organizations_tenant_id ON public.sentry_hipchat_ac_tenant_organizations USING btree (tenant_id);


--
-- Name: sentry_hipchat_ac_tenant_organizations_tenant_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_organizations_tenant_id_like ON public.sentry_hipchat_ac_tenant_organizations USING btree (tenant_id varchar_pattern_ops);


--
-- Name: sentry_hipchat_ac_tenant_projects_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_projects_project_id ON public.sentry_hipchat_ac_tenant_projects USING btree (project_id);


--
-- Name: sentry_hipchat_ac_tenant_projects_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_projects_tenant_id ON public.sentry_hipchat_ac_tenant_projects USING btree (tenant_id);


--
-- Name: sentry_hipchat_ac_tenant_projects_tenant_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_hipchat_ac_tenant_projects_tenant_id_like ON public.sentry_hipchat_ac_tenant_projects USING btree (tenant_id varchar_pattern_ops);


--
-- Name: sentry_identity_idp_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_identity_idp_id ON public.sentry_identity USING btree (idp_id);


--
-- Name: sentry_identity_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_identity_user_id ON public.sentry_identity USING btree (user_id);


--
-- Name: sentry_integrationexternalproject_organization_integration_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_integrationexternalproject_organization_integration_id ON public.sentry_integrationexternalproject USING btree (organization_integration_id);


--
-- Name: sentry_message_datetime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_message_datetime ON public.sentry_message USING btree (datetime);


--
-- Name: sentry_message_group_id_5f63ffbd9aac1141; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_message_group_id_5f63ffbd9aac1141 ON public.sentry_message USING btree (group_id, datetime);


--
-- Name: sentry_message_message_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_message_message_id_like ON public.sentry_message USING btree (message_id varchar_pattern_ops);


--
-- Name: sentry_message_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_message_project_id ON public.sentry_message USING btree (project_id);


--
-- Name: sentry_messagefiltervalue_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_messagefiltervalue_first_seen ON public.sentry_messagefiltervalue USING btree (first_seen);


--
-- Name: sentry_messagefiltervalue_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_messagefiltervalue_group_id ON public.sentry_messagefiltervalue USING btree (group_id);


--
-- Name: sentry_messagefiltervalue_group_id_59490523e6ee451f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_messagefiltervalue_group_id_59490523e6ee451f ON public.sentry_messagefiltervalue USING btree (group_id, key, value);


--
-- Name: sentry_messagefiltervalue_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_messagefiltervalue_last_seen ON public.sentry_messagefiltervalue USING btree (last_seen);


--
-- Name: sentry_messagefiltervalue_project_id_6852dd47401b2d7d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_messagefiltervalue_project_id_6852dd47401b2d7d ON public.sentry_messagefiltervalue USING btree (project_id, key, value, last_seen);


--
-- Name: sentry_monitor_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitor_organization_id ON public.sentry_monitor USING btree (organization_id);


--
-- Name: sentry_monitor_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitor_project_id ON public.sentry_monitor USING btree (project_id);


--
-- Name: sentry_monitor_type_28e22042b04e8b81; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitor_type_28e22042b04e8b81 ON public.sentry_monitor USING btree (type, next_checkin);


--
-- Name: sentry_monitorcheckin_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitorcheckin_location_id ON public.sentry_monitorcheckin USING btree (location_id);


--
-- Name: sentry_monitorcheckin_monitor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitorcheckin_monitor_id ON public.sentry_monitorcheckin USING btree (monitor_id);


--
-- Name: sentry_monitorcheckin_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_monitorcheckin_project_id ON public.sentry_monitorcheckin USING btree (project_id);


--
-- Name: sentry_organization_slug_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organization_slug_like ON public.sentry_organization USING btree (slug varchar_pattern_ops);


--
-- Name: sentry_organizationaccessrequest_member_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationaccessrequest_member_id ON public.sentry_organizationaccessrequest USING btree (member_id);


--
-- Name: sentry_organizationaccessrequest_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationaccessrequest_team_id ON public.sentry_organizationaccessrequest USING btree (team_id);


--
-- Name: sentry_organizationavatar_ident_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationavatar_ident_like ON public.sentry_organizationavatar USING btree (ident varchar_pattern_ops);


--
-- Name: sentry_organizationintegration_default_auth_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationintegration_default_auth_id ON public.sentry_organizationintegration USING btree (default_auth_id);


--
-- Name: sentry_organizationintegration_integration_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationintegration_integration_id ON public.sentry_organizationintegration USING btree (integration_id);


--
-- Name: sentry_organizationintegration_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationintegration_organization_id ON public.sentry_organizationintegration USING btree (organization_id);


--
-- Name: sentry_organizationmember_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationmember_organization_id ON public.sentry_organizationmember USING btree (organization_id);


--
-- Name: sentry_organizationmember_teams_organizationmember_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationmember_teams_organizationmember_id ON public.sentry_organizationmember_teams USING btree (organizationmember_id);


--
-- Name: sentry_organizationmember_teams_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationmember_teams_team_id ON public.sentry_organizationmember_teams USING btree (team_id);


--
-- Name: sentry_organizationmember_token_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationmember_token_like ON public.sentry_organizationmember USING btree (token varchar_pattern_ops);


--
-- Name: sentry_organizationmember_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationmember_user_id ON public.sentry_organizationmember USING btree (user_id);


--
-- Name: sentry_organizationonboardingtask_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationonboardingtask_organization_id ON public.sentry_organizationonboardingtask USING btree (organization_id);


--
-- Name: sentry_organizationonboardingtask_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationonboardingtask_user_id ON public.sentry_organizationonboardingtask USING btree (user_id);


--
-- Name: sentry_organizationoptions_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_organizationoptions_organization_id ON public.sentry_organizationoptions USING btree (organization_id);


--
-- Name: sentry_processingissue_checksum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_processingissue_checksum ON public.sentry_processingissue USING btree (checksum);


--
-- Name: sentry_processingissue_checksum_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_processingissue_checksum_like ON public.sentry_processingissue USING btree (checksum varchar_pattern_ops);


--
-- Name: sentry_processingissue_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_processingissue_project_id ON public.sentry_processingissue USING btree (project_id);


--
-- Name: sentry_project_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_project_organization_id ON public.sentry_project USING btree (organization_id);


--
-- Name: sentry_project_slug_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_project_slug_like ON public.sentry_project USING btree (slug varchar_pattern_ops);


--
-- Name: sentry_project_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_project_status ON public.sentry_project USING btree (status);


--
-- Name: sentry_projectavatar_ident_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectavatar_ident_like ON public.sentry_projectavatar USING btree (ident varchar_pattern_ops);


--
-- Name: sentry_projectbookmark_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectbookmark_user_id ON public.sentry_projectbookmark USING btree (user_id);


--
-- Name: sentry_projectcficachefile_cache_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectcficachefile_cache_file_id ON public.sentry_projectcficachefile USING btree (cache_file_id);


--
-- Name: sentry_projectcficachefile_dsym_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectcficachefile_dsym_file_id ON public.sentry_projectcficachefile USING btree (dsym_file_id);


--
-- Name: sentry_projectcficachefile_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectcficachefile_project_id ON public.sentry_projectcficachefile USING btree (project_id);


--
-- Name: sentry_projectdsymfile_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectdsymfile_file_id ON public.sentry_projectdsymfile USING btree (file_id);


--
-- Name: sentry_projectdsymfile_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectdsymfile_project_id ON public.sentry_projectdsymfile USING btree (project_id);


--
-- Name: sentry_projectdsymfile_project_id_52cf645985146f12; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectdsymfile_project_id_52cf645985146f12 ON public.sentry_projectdsymfile USING btree (project_id, uuid);


--
-- Name: sentry_projectdsymfile_project_id_7807418137c3b433; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectdsymfile_project_id_7807418137c3b433 ON public.sentry_projectdsymfile USING btree (project_id, code_id);


--
-- Name: sentry_projectintegration_integration_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectintegration_integration_id ON public.sentry_projectintegration USING btree (integration_id);


--
-- Name: sentry_projectintegration_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectintegration_project_id ON public.sentry_projectintegration USING btree (project_id);


--
-- Name: sentry_projectkey_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectkey_project_id ON public.sentry_projectkey USING btree (project_id);


--
-- Name: sentry_projectkey_public_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectkey_public_key_like ON public.sentry_projectkey USING btree (public_key varchar_pattern_ops);


--
-- Name: sentry_projectkey_secret_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectkey_secret_key_like ON public.sentry_projectkey USING btree (secret_key varchar_pattern_ops);


--
-- Name: sentry_projectkey_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectkey_status ON public.sentry_projectkey USING btree (status);


--
-- Name: sentry_projectoptions_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectoptions_project_id ON public.sentry_projectoptions USING btree (project_id);


--
-- Name: sentry_projectplatform_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectplatform_last_seen ON public.sentry_projectplatform USING btree (last_seen);


--
-- Name: sentry_projectredirect_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectredirect_organization_id ON public.sentry_projectredirect USING btree (organization_id);


--
-- Name: sentry_projectredirect_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectredirect_project_id ON public.sentry_projectredirect USING btree (project_id);


--
-- Name: sentry_projectredirect_redirect_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectredirect_redirect_slug ON public.sentry_projectredirect USING btree (redirect_slug);


--
-- Name: sentry_projectredirect_redirect_slug_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectredirect_redirect_slug_like ON public.sentry_projectredirect USING btree (redirect_slug varchar_pattern_ops);


--
-- Name: sentry_projectsymcachefile_cache_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectsymcachefile_cache_file_id ON public.sentry_projectsymcachefile USING btree (cache_file_id);


--
-- Name: sentry_projectsymcachefile_dsym_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectsymcachefile_dsym_file_id ON public.sentry_projectsymcachefile USING btree (dsym_file_id);


--
-- Name: sentry_projectsymcachefile_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectsymcachefile_project_id ON public.sentry_projectsymcachefile USING btree (project_id);


--
-- Name: sentry_projectteam_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectteam_project_id ON public.sentry_projectteam USING btree (project_id);


--
-- Name: sentry_projectteam_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_projectteam_team_id ON public.sentry_projectteam USING btree (team_id);


--
-- Name: sentry_promptsactivity_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_promptsactivity_organization_id ON public.sentry_promptsactivity USING btree (organization_id);


--
-- Name: sentry_promptsactivity_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_promptsactivity_project_id ON public.sentry_promptsactivity USING btree (project_id);


--
-- Name: sentry_promptsactivity_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_promptsactivity_user_id ON public.sentry_promptsactivity USING btree (user_id);


--
-- Name: sentry_pull_request_author_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pull_request_author_id ON public.sentry_pull_request USING btree (author_id);


--
-- Name: sentry_pull_request_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pull_request_organization_id ON public.sentry_pull_request USING btree (organization_id);


--
-- Name: sentry_pull_request_organization_id_589974f80d75bac5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pull_request_organization_id_589974f80d75bac5 ON public.sentry_pull_request USING btree (organization_id, merge_commit_sha);


--
-- Name: sentry_pull_request_repository_id_38520c7bdded6f5a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pull_request_repository_id_38520c7bdded6f5a ON public.sentry_pull_request USING btree (repository_id, date_added);


--
-- Name: sentry_pullrequest_commit_commit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pullrequest_commit_commit_id ON public.sentry_pullrequest_commit USING btree (commit_id);


--
-- Name: sentry_pullrequest_commit_pull_request_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_pullrequest_commit_pull_request_id ON public.sentry_pullrequest_commit USING btree (pull_request_id);


--
-- Name: sentry_rawevent_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_rawevent_project_id ON public.sentry_rawevent USING btree (project_id);


--
-- Name: sentry_recentsearch_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_recentsearch_organization_id ON public.sentry_recentsearch USING btree (organization_id);


--
-- Name: sentry_relay_relay_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_relay_relay_id_like ON public.sentry_relay USING btree (relay_id varchar_pattern_ops);


--
-- Name: sentry_release_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_organization_id ON public.sentry_release USING btree (organization_id);


--
-- Name: sentry_release_organization_id_b3241759a1649e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_organization_id_b3241759a1649e ON public.sentry_release USING btree (organization_id, COALESCE(date_released, date_added));


--
-- Name: sentry_release_organization_id_f0a7ec9ba96de76; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_release_organization_id_f0a7ec9ba96de76 ON public.sentry_release USING btree (organization_id, version);


--
-- Name: sentry_release_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_owner_id ON public.sentry_release USING btree (owner_id);


--
-- Name: sentry_release_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_project_id ON public.sentry_release USING btree (project_id);


--
-- Name: sentry_release_project_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_project_project_id ON public.sentry_release_project USING btree (project_id);


--
-- Name: sentry_release_project_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_release_project_release_id ON public.sentry_release_project USING btree (release_id);


--
-- Name: sentry_releasecommit_commit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasecommit_commit_id ON public.sentry_releasecommit USING btree (commit_id);


--
-- Name: sentry_releasecommit_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasecommit_organization_id ON public.sentry_releasecommit USING btree (organization_id);


--
-- Name: sentry_releasecommit_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasecommit_release_id ON public.sentry_releasecommit USING btree (release_id);


--
-- Name: sentry_releasefile_dist_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_dist_id ON public.sentry_releasefile USING btree (dist_id);


--
-- Name: sentry_releasefile_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_file_id ON public.sentry_releasefile USING btree (file_id);


--
-- Name: sentry_releasefile_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_organization_id ON public.sentry_releasefile USING btree (organization_id);


--
-- Name: sentry_releasefile_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_project_id ON public.sentry_releasefile USING btree (project_id);


--
-- Name: sentry_releasefile_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_release_id ON public.sentry_releasefile USING btree (release_id);


--
-- Name: sentry_releasefile_release_id_1303592d47a118c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releasefile_release_id_1303592d47a118c9 ON public.sentry_releasefile USING btree (release_id, name);


--
-- Name: sentry_releaseheadcommit_commit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseheadcommit_commit_id ON public.sentry_releaseheadcommit USING btree (commit_id);


--
-- Name: sentry_releaseheadcommit_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseheadcommit_organization_id ON public.sentry_releaseheadcommit USING btree (organization_id);


--
-- Name: sentry_releaseheadcommit_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseheadcommit_release_id ON public.sentry_releaseheadcommit USING btree (release_id);


--
-- Name: sentry_releaseprojectenvironment_environment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseprojectenvironment_environment_id ON public.sentry_releaseprojectenvironment USING btree (environment_id);


--
-- Name: sentry_releaseprojectenvironment_last_deploy_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseprojectenvironment_last_deploy_id ON public.sentry_releaseprojectenvironment USING btree (last_deploy_id);


--
-- Name: sentry_releaseprojectenvironment_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseprojectenvironment_last_seen ON public.sentry_releaseprojectenvironment USING btree (last_seen);


--
-- Name: sentry_releaseprojectenvironment_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseprojectenvironment_project_id ON public.sentry_releaseprojectenvironment USING btree (project_id);


--
-- Name: sentry_releaseprojectenvironment_release_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_releaseprojectenvironment_release_id ON public.sentry_releaseprojectenvironment USING btree (release_id);


--
-- Name: sentry_repository_integration_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_repository_integration_id ON public.sentry_repository USING btree (integration_id);


--
-- Name: sentry_repository_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_repository_organization_id ON public.sentry_repository USING btree (organization_id);


--
-- Name: sentry_repository_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_repository_status ON public.sentry_repository USING btree (status);


--
-- Name: sentry_reprocessingreport_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_reprocessingreport_project_id ON public.sentry_reprocessingreport USING btree (project_id);


--
-- Name: sentry_rule_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_rule_project_id ON public.sentry_rule USING btree (project_id);


--
-- Name: sentry_rule_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_rule_status ON public.sentry_rule USING btree (status);


--
-- Name: sentry_savedsearch_is_global; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_is_global ON public.sentry_savedsearch USING btree (is_global);


--
-- Name: sentry_savedsearch_is_global_6793a2f9e1b59b95; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_savedsearch_is_global_6793a2f9e1b59b95 ON public.sentry_savedsearch USING btree (is_global, name) WHERE is_global;


--
-- Name: sentry_savedsearch_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_organization_id ON public.sentry_savedsearch USING btree (organization_id);


--
-- Name: sentry_savedsearch_organization_id_313a24e907cdef99; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sentry_savedsearch_organization_id_313a24e907cdef99 ON public.sentry_savedsearch USING btree (organization_id, name, type) WHERE (owner_id IS NULL);


--
-- Name: sentry_savedsearch_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_owner_id ON public.sentry_savedsearch USING btree (owner_id);


--
-- Name: sentry_savedsearch_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_project_id ON public.sentry_savedsearch USING btree (project_id);


--
-- Name: sentry_savedsearch_userdefault_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_userdefault_project_id ON public.sentry_savedsearch_userdefault USING btree (project_id);


--
-- Name: sentry_savedsearch_userdefault_savedsearch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_userdefault_savedsearch_id ON public.sentry_savedsearch_userdefault USING btree (savedsearch_id);


--
-- Name: sentry_savedsearch_userdefault_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_savedsearch_userdefault_user_id ON public.sentry_savedsearch_userdefault USING btree (user_id);


--
-- Name: sentry_scheduleddeletion_guid_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_scheduleddeletion_guid_like ON public.sentry_scheduleddeletion USING btree (guid varchar_pattern_ops);


--
-- Name: sentry_sentryapp_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryapp_owner_id ON public.sentry_sentryapp USING btree (owner_id);


--
-- Name: sentry_sentryapp_slug_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryapp_slug_like ON public.sentry_sentryapp USING btree (slug varchar_pattern_ops);


--
-- Name: sentry_sentryappavatar_ident_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryappavatar_ident_like ON public.sentry_sentryappavatar USING btree (ident varchar_pattern_ops);


--
-- Name: sentry_sentryappcomponent_sentry_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryappcomponent_sentry_app_id ON public.sentry_sentryappcomponent USING btree (sentry_app_id);


--
-- Name: sentry_sentryappinstallation_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryappinstallation_organization_id ON public.sentry_sentryappinstallation USING btree (organization_id);


--
-- Name: sentry_sentryappinstallation_sentry_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_sentryappinstallation_sentry_app_id ON public.sentry_sentryappinstallation USING btree (sentry_app_id);


--
-- Name: sentry_servicehook_actor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_actor_id ON public.sentry_servicehook USING btree (actor_id);


--
-- Name: sentry_servicehook_application_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_application_id ON public.sentry_servicehook USING btree (application_id);


--
-- Name: sentry_servicehook_guid_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_guid_like ON public.sentry_servicehook USING btree (guid varchar_pattern_ops);


--
-- Name: sentry_servicehook_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_organization_id ON public.sentry_servicehook USING btree (organization_id);


--
-- Name: sentry_servicehook_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_project_id ON public.sentry_servicehook USING btree (project_id);


--
-- Name: sentry_servicehook_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehook_status ON public.sentry_servicehook USING btree (status);


--
-- Name: sentry_servicehookproject_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehookproject_project_id ON public.sentry_servicehookproject USING btree (project_id);


--
-- Name: sentry_servicehookproject_service_hook_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_servicehookproject_service_hook_id ON public.sentry_servicehookproject USING btree (service_hook_id);


--
-- Name: sentry_team_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_team_organization_id ON public.sentry_team USING btree (organization_id);


--
-- Name: sentry_team_slug_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_team_slug_like ON public.sentry_team USING btree (slug varchar_pattern_ops);


--
-- Name: sentry_teamavatar_ident_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_teamavatar_ident_like ON public.sentry_teamavatar USING btree (ident varchar_pattern_ops);


--
-- Name: sentry_useravatar_ident_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_useravatar_ident_like ON public.sentry_useravatar USING btree (ident varchar_pattern_ops);


--
-- Name: sentry_useremail_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_useremail_user_id ON public.sentry_useremail USING btree (user_id);


--
-- Name: sentry_userip_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userip_user_id ON public.sentry_userip USING btree (user_id);


--
-- Name: sentry_useroption_organization_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_useroption_organization_id ON public.sentry_useroption USING btree (organization_id);


--
-- Name: sentry_useroption_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_useroption_project_id ON public.sentry_useroption USING btree (project_id);


--
-- Name: sentry_useroption_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_useroption_user_id ON public.sentry_useroption USING btree (user_id);


--
-- Name: sentry_userpermission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userpermission_user_id ON public.sentry_userpermission USING btree (user_id);


--
-- Name: sentry_userreport_date_added; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_date_added ON public.sentry_userreport USING btree (date_added);


--
-- Name: sentry_userreport_environment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_environment_id ON public.sentry_userreport USING btree (environment_id);


--
-- Name: sentry_userreport_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_group_id ON public.sentry_userreport USING btree (group_id);


--
-- Name: sentry_userreport_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_project_id ON public.sentry_userreport USING btree (project_id);


--
-- Name: sentry_userreport_project_id_1ac377e052723c91; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_project_id_1ac377e052723c91 ON public.sentry_userreport USING btree (project_id, event_id);


--
-- Name: sentry_userreport_project_id_1c06c9ecc190b2e6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_userreport_project_id_1c06c9ecc190b2e6 ON public.sentry_userreport USING btree (project_id, date_added);


--
-- Name: sentry_widget_dashboard_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_widget_dashboard_id ON public.sentry_widget USING btree (dashboard_id);


--
-- Name: sentry_widgetdatasource_widget_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sentry_widgetdatasource_widget_id ON public.sentry_widgetdatasource USING btree (widget_id);


--
-- Name: social_auth_usersocialauth_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX social_auth_usersocialauth_user_id ON public.social_auth_usersocialauth USING btree (user_id);


--
-- Name: tagstore_eventtag_date_added; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_eventtag_date_added ON public.tagstore_eventtag USING btree (date_added);


--
-- Name: tagstore_eventtag_group_id_49cb2edc39d902d9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_eventtag_group_id_49cb2edc39d902d9 ON public.tagstore_eventtag USING btree (group_id, key_id, value_id);


--
-- Name: tagstore_eventtag_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_eventtag_key_id ON public.tagstore_eventtag USING btree (key_id);


--
-- Name: tagstore_eventtag_project_id_3479ea564384cd3f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_eventtag_project_id_3479ea564384cd3f ON public.tagstore_eventtag USING btree (project_id, key_id, value_id);


--
-- Name: tagstore_eventtag_value_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_eventtag_value_id ON public.tagstore_eventtag USING btree (value_id);


--
-- Name: tagstore_grouptagkey_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagkey_group_id ON public.tagstore_grouptagkey USING btree (group_id);


--
-- Name: tagstore_grouptagkey_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagkey_key_id ON public.tagstore_grouptagkey USING btree (key_id);


--
-- Name: tagstore_grouptagkey_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagkey_project_id ON public.tagstore_grouptagkey USING btree (project_id);


--
-- Name: tagstore_grouptagvalue_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_first_seen ON public.tagstore_grouptagvalue USING btree (first_seen);


--
-- Name: tagstore_grouptagvalue_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_group_id ON public.tagstore_grouptagvalue USING btree (group_id);


--
-- Name: tagstore_grouptagvalue_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_key_id ON public.tagstore_grouptagvalue USING btree (key_id);


--
-- Name: tagstore_grouptagvalue_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_last_seen ON public.tagstore_grouptagvalue USING btree (last_seen);


--
-- Name: tagstore_grouptagvalue_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_project_id ON public.tagstore_grouptagvalue USING btree (project_id);


--
-- Name: tagstore_grouptagvalue_project_id_7b2704754ded7e70; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_project_id_7b2704754ded7e70 ON public.tagstore_grouptagvalue USING btree (project_id, key_id, value_id, last_seen);


--
-- Name: tagstore_grouptagvalue_value_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_grouptagvalue_value_id ON public.tagstore_grouptagvalue USING btree (value_id);


--
-- Name: tagstore_tagkey_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagkey_project_id ON public.tagstore_tagkey USING btree (project_id);


--
-- Name: tagstore_tagvalue_first_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagvalue_first_seen ON public.tagstore_tagvalue USING btree (first_seen);


--
-- Name: tagstore_tagvalue_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagvalue_key_id ON public.tagstore_tagvalue USING btree (key_id);


--
-- Name: tagstore_tagvalue_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagvalue_last_seen ON public.tagstore_tagvalue USING btree (last_seen);


--
-- Name: tagstore_tagvalue_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagvalue_project_id ON public.tagstore_tagvalue USING btree (project_id);


--
-- Name: tagstore_tagvalue_project_id_407ef2b73029a6bc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagstore_tagvalue_project_id_407ef2b73029a6bc ON public.tagstore_tagvalue USING btree (project_id, key_id, last_seen);


--
-- Name: sentry_auditlogentry actor_id_refs_id_cac0f7f5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry
    ADD CONSTRAINT actor_id_refs_id_cac0f7f5 FOREIGN KEY (actor_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_auditlogentry actor_key_id_refs_id_cc2fc30c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry
    ADD CONSTRAINT actor_key_id_refs_id_cc2fc30c FOREIGN KEY (actor_key_id) REFERENCES public.sentry_apikey(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappinstallation api_grant_id_refs_id_a2930dbf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT api_grant_id_refs_id_a2930dbf FOREIGN KEY (api_grant_id) REFERENCES public.sentry_apigrant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apitoken application_id_refs_id_153d42f0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken
    ADD CONSTRAINT application_id_refs_id_153d42f0 FOREIGN KEY (application_id) REFERENCES public.sentry_apiapplication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apiauthorization application_id_refs_id_4607bb14; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiauthorization
    ADD CONSTRAINT application_id_refs_id_4607bb14 FOREIGN KEY (application_id) REFERENCES public.sentry_apiapplication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_servicehook application_id_refs_id_6d783834; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehook
    ADD CONSTRAINT application_id_refs_id_6d783834 FOREIGN KEY (application_id) REFERENCES public.sentry_apiapplication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryapp application_id_refs_id_e7015519; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT application_id_refs_id_e7015519 FOREIGN KEY (application_id) REFERENCES public.sentry_apiapplication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apigrant application_id_refs_id_fe5530d5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apigrant
    ADD CONSTRAINT application_id_refs_id_fe5530d5 FOREIGN KEY (application_id) REFERENCES public.sentry_apiapplication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_authidentity auth_provider_id_refs_id_d9990f1d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity
    ADD CONSTRAINT auth_provider_id_refs_id_d9990f1d FOREIGN KEY (auth_provider_id) REFERENCES public.sentry_authprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_hipchat_ac_tenant auth_user_id_refs_id_615fc607; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant
    ADD CONSTRAINT auth_user_id_refs_id_615fc607 FOREIGN KEY (auth_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_commit author_id_refs_id_2f962e87; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commit
    ADD CONSTRAINT author_id_refs_id_2f962e87 FOREIGN KEY (author_id) REFERENCES public.sentry_commitauthor(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_pull_request author_id_refs_id_532d908e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pull_request
    ADD CONSTRAINT author_id_refs_id_532d908e FOREIGN KEY (author_id) REFERENCES public.sentry_commitauthor(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappinstallation authorization_id_refs_id_549dc4aa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT authorization_id_refs_id_549dc4aa FOREIGN KEY (authorization_id) REFERENCES public.sentry_apiauthorization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_authprovider_default_teams authprovider_id_refs_id_9e7068be; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider_default_teams
    ADD CONSTRAINT authprovider_id_refs_id_9e7068be FOREIGN KEY (authprovider_id) REFERENCES public.sentry_authprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_fileblobindex blob_id_refs_id_5732bcfb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobindex
    ADD CONSTRAINT blob_id_refs_id_5732bcfb FOREIGN KEY (blob_id) REFERENCES public.sentry_fileblob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_file blob_id_refs_id_912b0028; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_file
    ADD CONSTRAINT blob_id_refs_id_912b0028 FOREIGN KEY (blob_id) REFERENCES public.sentry_fileblob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_fileblobowner blob_id_refs_id_9196b9eb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobowner
    ADD CONSTRAINT blob_id_refs_id_9196b9eb FOREIGN KEY (blob_id) REFERENCES public.sentry_fileblob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_broadcastseen broadcast_id_refs_id_e214087a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcastseen
    ADD CONSTRAINT broadcast_id_refs_id_e214087a FOREIGN KEY (broadcast_id) REFERENCES public.sentry_broadcast(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectsymcachefile cache_file_id_refs_id_7cf3a92b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile
    ADD CONSTRAINT cache_file_id_refs_id_7cf3a92b FOREIGN KEY (cache_file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectcficachefile cache_file_id_refs_id_feabd263; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile
    ADD CONSTRAINT cache_file_id_refs_id_feabd263 FOREIGN KEY (cache_file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_pullrequest_commit commit_id_refs_id_2c2583d4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pullrequest_commit
    ADD CONSTRAINT commit_id_refs_id_2c2583d4 FOREIGN KEY (commit_id) REFERENCES public.sentry_commit(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releaseheadcommit commit_id_refs_id_66ff0ace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseheadcommit
    ADD CONSTRAINT commit_id_refs_id_66ff0ace FOREIGN KEY (commit_id) REFERENCES public.sentry_commit(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasecommit commit_id_refs_id_a0857449; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit
    ADD CONSTRAINT commit_id_refs_id_a0857449 FOREIGN KEY (commit_id) REFERENCES public.sentry_commit(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_commitfilechange commit_id_refs_id_f9a55f94; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_commitfilechange
    ADD CONSTRAINT commit_id_refs_id_f9a55f94 FOREIGN KEY (commit_id) REFERENCES public.sentry_commit(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log content_type_id_refs_id_93d2d1f8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT content_type_id_refs_id_93d2d1f8 FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission content_type_id_refs_id_d043b34a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT content_type_id_refs_id_d043b34a FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_discoversavedquery created_by_id_refs_id_5434669b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedquery
    ADD CONSTRAINT created_by_id_refs_id_5434669b FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_dashboard created_by_id_refs_id_eb3a532f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_dashboard
    ADD CONSTRAINT created_by_id_refs_id_eb3a532f FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_widget dashboard_id_refs_id_b905ac19; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widget
    ADD CONSTRAINT dashboard_id_refs_id_b905ac19 FOREIGN KEY (dashboard_id) REFERENCES public.sentry_dashboard(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_discoversavedqueryproject discover_saved_query_id_refs_id_e65e3128; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedqueryproject
    ADD CONSTRAINT discover_saved_query_id_refs_id_e65e3128 FOREIGN KEY (discover_saved_query_id) REFERENCES public.sentry_discoversavedquery(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasefile dist_id_refs_id_13fab125; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT dist_id_refs_id_13fab125 FOREIGN KEY (dist_id) REFERENCES public.sentry_distribution(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectcficachefile dsym_file_id_refs_id_97388d4c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile
    ADD CONSTRAINT dsym_file_id_refs_id_97388d4c FOREIGN KEY (dsym_file_id) REFERENCES public.sentry_projectdsymfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectsymcachefile dsym_file_id_refs_id_f03d3b01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile
    ADD CONSTRAINT dsym_file_id_refs_id_f03d3b01 FOREIGN KEY (dsym_file_id) REFERENCES public.sentry_projectdsymfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releaseprojectenvironment environment_id_refs_id_29efc909; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment
    ADD CONSTRAINT environment_id_refs_id_29efc909 FOREIGN KEY (environment_id) REFERENCES public.sentry_environment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_userreport environment_id_refs_id_5e0c6443; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport
    ADD CONSTRAINT environment_id_refs_id_5e0c6443 FOREIGN KEY (environment_id) REFERENCES public.sentry_environment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_environmentproject environment_id_refs_id_ab2491b4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentproject
    ADD CONSTRAINT environment_id_refs_id_ab2491b4 FOREIGN KEY (environment_id) REFERENCES public.sentry_environment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useravatar file_id_refs_id_0c8678bd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT file_id_refs_id_0c8678bd FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationavatar file_id_refs_id_2ced8ba5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT file_id_refs_id_2ced8ba5 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectavatar file_id_refs_id_3cb3b313; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT file_id_refs_id_3cb3b313 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappavatar file_id_refs_id_5be1c073; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT file_id_refs_id_5be1c073 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_fileblobindex file_id_refs_id_82747ec9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobindex
    ADD CONSTRAINT file_id_refs_id_82747ec9 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_eventattachment file_id_refs_id_8f4ac45b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventattachment
    ADD CONSTRAINT file_id_refs_id_8f4ac45b FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectdsymfile file_id_refs_id_cc76204b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectdsymfile
    ADD CONSTRAINT file_id_refs_id_cc76204b FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_teamavatar file_id_refs_id_f2752739; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT file_id_refs_id_f2752739 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasefile file_id_refs_id_fb71e922; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT file_id_refs_id_fb71e922 FOREIGN KEY (file_id) REFERENCES public.sentry_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupedmessage first_release_id_refs_id_d035a570; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupedmessage
    ADD CONSTRAINT first_release_id_refs_id_d035a570 FOREIGN KEY (first_release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupseen group_id_refs_id_09b2694a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen
    ADD CONSTRAINT group_id_refs_id_09b2694a FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupbookmark group_id_refs_id_3738447a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark
    ADD CONSTRAINT group_id_refs_id_3738447a FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupemailthread group_id_refs_id_3c3dd283; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupemailthread
    ADD CONSTRAINT group_id_refs_id_3c3dd283 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupshare group_id_refs_id_45b11130; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT group_id_refs_id_45b11130 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupasignee group_id_refs_id_47b32b76; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT group_id_refs_id_47b32b76 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouprulestatus group_id_refs_id_66981850; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus
    ADD CONSTRAINT group_id_refs_id_66981850 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_userreport group_id_refs_id_6b3d43d4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport
    ADD CONSTRAINT group_id_refs_id_6b3d43d4 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupmeta group_id_refs_id_6dc57728; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupmeta
    ADD CONSTRAINT group_id_refs_id_6dc57728 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupsnooze group_id_refs_id_7d70660e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsnooze
    ADD CONSTRAINT group_id_refs_id_7d70660e FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupsubscription group_id_refs_id_901a3390; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription
    ADD CONSTRAINT group_id_refs_id_901a3390 FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouphash group_id_refs_id_9603f6ba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouphash
    ADD CONSTRAINT group_id_refs_id_9603f6ba FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_activity group_id_refs_id_b84d67ec; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_activity
    ADD CONSTRAINT group_id_refs_id_b84d67ec FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupresolution group_id_refs_id_ed32932f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupresolution
    ADD CONSTRAINT group_id_refs_id_ed32932f FOREIGN KEY (group_id) REFERENCES public.sentry_groupedmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions group_id_refs_id_f4b32aac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT group_id_refs_id_f4b32aac FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_identity idp_id_refs_id_f0c91862; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity
    ADD CONSTRAINT idp_id_refs_id_f0c91862 FOREIGN KEY (idp_id) REFERENCES public.sentry_identityprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectintegration integration_id_refs_id_13d343b7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectintegration
    ADD CONSTRAINT integration_id_refs_id_13d343b7 FOREIGN KEY (integration_id) REFERENCES public.sentry_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationintegration integration_id_refs_id_fdcbef56; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationintegration
    ADD CONSTRAINT integration_id_refs_id_fdcbef56 FOREIGN KEY (integration_id) REFERENCES public.sentry_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_grouptagvalue key_id_refs_id_06d0d786; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagvalue
    ADD CONSTRAINT key_id_refs_id_06d0d786 FOREIGN KEY (key_id) REFERENCES public.tagstore_tagkey(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_eventtag key_id_refs_id_18e8ae17; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_eventtag
    ADD CONSTRAINT key_id_refs_id_18e8ae17 FOREIGN KEY (key_id) REFERENCES public.tagstore_tagkey(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_grouptagkey key_id_refs_id_3744a25a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagkey
    ADD CONSTRAINT key_id_refs_id_3744a25a FOREIGN KEY (key_id) REFERENCES public.tagstore_tagkey(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_tagvalue key_id_refs_id_67de5ca2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_tagvalue
    ADD CONSTRAINT key_id_refs_id_67de5ca2 FOREIGN KEY (key_id) REFERENCES public.tagstore_tagkey(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_monitorcheckin location_id_refs_id_1d21a5a7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorcheckin
    ADD CONSTRAINT location_id_refs_id_1d21a5a7 FOREIGN KEY (location_id) REFERENCES public.sentry_monitorlocation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationaccessrequest member_id_refs_id_7c8ccc01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationaccessrequest
    ADD CONSTRAINT member_id_refs_id_7c8ccc01 FOREIGN KEY (member_id) REFERENCES public.sentry_organizationmember(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_monitorcheckin monitor_id_refs_id_51b5cdcd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_monitorcheckin
    ADD CONSTRAINT monitor_id_refs_id_51b5cdcd FOREIGN KEY (monitor_id) REFERENCES public.sentry_monitor(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationonboardingtask organization_id_refs_id_2203c68b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationonboardingtask
    ADD CONSTRAINT organization_id_refs_id_2203c68b FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch organization_id_refs_id_29cc50b1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT organization_id_refs_id_29cc50b1 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationmember organization_id_refs_id_42dc8e8f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT organization_id_refs_id_42dc8e8f FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: jira_ac_tenant organization_id_refs_id_49689eb3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jira_ac_tenant
    ADD CONSTRAINT organization_id_refs_id_49689eb3 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useroption organization_id_refs_id_56961afd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT organization_id_refs_id_56961afd FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_team organization_id_refs_id_61038a42; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_team
    ADD CONSTRAINT organization_id_refs_id_61038a42 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectredirect organization_id_refs_id_686aff6a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectredirect
    ADD CONSTRAINT organization_id_refs_id_686aff6a FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_project organization_id_refs_id_6874e5b7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_project
    ADD CONSTRAINT organization_id_refs_id_6874e5b7 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_authprovider organization_id_refs_id_6a37632f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider
    ADD CONSTRAINT organization_id_refs_id_6a37632f FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_recentsearch organization_id_refs_id_7344d24c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_recentsearch
    ADD CONSTRAINT organization_id_refs_id_7344d24c FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationoptions organization_id_refs_id_83d34346; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationoptions
    ADD CONSTRAINT organization_id_refs_id_83d34346 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_fileblobowner organization_id_refs_id_8fd8a7b0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_fileblobowner
    ADD CONSTRAINT organization_id_refs_id_8fd8a7b0 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apikey organization_id_refs_id_961ec303; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apikey
    ADD CONSTRAINT organization_id_refs_id_961ec303 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_discoversavedquery organization_id_refs_id_9b467944; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedquery
    ADD CONSTRAINT organization_id_refs_id_9b467944 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationavatar organization_id_refs_id_ac0fa6a7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationavatar
    ADD CONSTRAINT organization_id_refs_id_ac0fa6a7 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_dashboard organization_id_refs_id_ae0d09f9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_dashboard
    ADD CONSTRAINT organization_id_refs_id_ae0d09f9 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_hipchat_ac_tenant_organizations organization_id_refs_id_af26d69f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_organizations
    ADD CONSTRAINT organization_id_refs_id_af26d69f FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationintegration organization_id_refs_id_af8cad03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationintegration
    ADD CONSTRAINT organization_id_refs_id_af8cad03 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_release organization_id_refs_id_ba7f8e42; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release
    ADD CONSTRAINT organization_id_refs_id_ba7f8e42 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappinstallation organization_id_refs_id_ca6d3975; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT organization_id_refs_id_ca6d3975 FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_featureadoption organization_id_refs_id_e6c64c1d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_featureadoption
    ADD CONSTRAINT organization_id_refs_id_e6c64c1d FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasefile organization_id_refs_id_ef2843cb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT organization_id_refs_id_ef2843cb FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_auditlogentry organization_id_refs_id_f5b1844e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry
    ADD CONSTRAINT organization_id_refs_id_f5b1844e FOREIGN KEY (organization_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationmember_teams organizationmember_id_refs_id_878802f4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember_teams
    ADD CONSTRAINT organizationmember_id_refs_id_878802f4 FOREIGN KEY (organizationmember_id) REFERENCES public.sentry_organizationmember(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_release owner_id_refs_id_65604067; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release
    ADD CONSTRAINT owner_id_refs_id_65604067 FOREIGN KEY (owner_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch owner_id_refs_id_865787fc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT owner_id_refs_id_865787fc FOREIGN KEY (owner_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryapp owner_id_refs_id_e7599961; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT owner_id_refs_id_e7599961 FOREIGN KEY (owner_id) REFERENCES public.sentry_organization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apiapplication owner_id_refs_id_f68b4574; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiapplication
    ADD CONSTRAINT owner_id_refs_id_f68b4574 FOREIGN KEY (owner_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_eventprocessingissue processing_issue_id_refs_id_0df012da; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventprocessingissue
    ADD CONSTRAINT processing_issue_id_refs_id_0df012da FOREIGN KEY (processing_issue_id) REFERENCES public.sentry_processingissue(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouprulestatus project_id_refs_id_09c5b95d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus
    ADD CONSTRAINT project_id_refs_id_09c5b95d FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_activity project_id_refs_id_0c94d99e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_activity
    ADD CONSTRAINT project_id_refs_id_0c94d99e FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_reprocessingreport project_id_refs_id_11918af3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_reprocessingreport
    ADD CONSTRAINT project_id_refs_id_11918af3 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupbookmark project_id_refs_id_18390fbc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark
    ADD CONSTRAINT project_id_refs_id_18390fbc FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupasignee project_id_refs_id_1b5200f8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT project_id_refs_id_1b5200f8 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_discoversavedqueryproject project_id_refs_id_1d22a310; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_discoversavedqueryproject
    ADD CONSTRAINT project_id_refs_id_1d22a310 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectsymcachefile project_id_refs_id_3a95c5b5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectsymcachefile
    ADD CONSTRAINT project_id_refs_id_3a95c5b5 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectintegration project_id_refs_id_41efed36; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectintegration
    ADD CONSTRAINT project_id_refs_id_41efed36 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch_userdefault project_id_refs_id_4bc1c005; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault
    ADD CONSTRAINT project_id_refs_id_4bc1c005 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectcficachefile project_id_refs_id_4e68b4da; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcficachefile
    ADD CONSTRAINT project_id_refs_id_4e68b4da FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectcounter project_id_refs_id_58200d0a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectcounter
    ADD CONSTRAINT project_id_refs_id_58200d0a FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupseen project_id_refs_id_67db0efd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen
    ADD CONSTRAINT project_id_refs_id_67db0efd FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouphash project_id_refs_id_6f0a9434; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouphash
    ADD CONSTRAINT project_id_refs_id_6f0a9434 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_userreport project_id_refs_id_723e0b3c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userreport
    ADD CONSTRAINT project_id_refs_id_723e0b3c FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupedmessage project_id_refs_id_77344b57; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupedmessage
    ADD CONSTRAINT project_id_refs_id_77344b57 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectavatar project_id_refs_id_80275d85; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectavatar
    ADD CONSTRAINT project_id_refs_id_80275d85 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_release_project project_id_refs_id_80894a1c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release_project
    ADD CONSTRAINT project_id_refs_id_80894a1c FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupemailthread project_id_refs_id_8419ea36; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupemailthread
    ADD CONSTRAINT project_id_refs_id_8419ea36 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouptombstone project_id_refs_id_8e12ecf7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouptombstone
    ADD CONSTRAINT project_id_refs_id_8e12ecf7 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectdsymfile project_id_refs_id_94d40917; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectdsymfile
    ADD CONSTRAINT project_id_refs_id_94d40917 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectoptions project_id_refs_id_9b845024; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectoptions
    ADD CONSTRAINT project_id_refs_id_9b845024 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupsubscription project_id_refs_id_a564d25b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription
    ADD CONSTRAINT project_id_refs_id_a564d25b FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_hipchat_ac_tenant_projects project_id_refs_id_a7eeaf92; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_projects
    ADD CONSTRAINT project_id_refs_id_a7eeaf92 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch project_id_refs_id_b18120e7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch
    ADD CONSTRAINT project_id_refs_id_b18120e7 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectredirect project_id_refs_id_c05b2172; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectredirect
    ADD CONSTRAINT project_id_refs_id_c05b2172 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_rule project_id_refs_id_c96b69eb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rule
    ADD CONSTRAINT project_id_refs_id_c96b69eb FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_environmentproject project_id_refs_id_cf2e01df; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_environmentproject
    ADD CONSTRAINT project_id_refs_id_cf2e01df FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupshare project_id_refs_id_d3771efc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT project_id_refs_id_d3771efc FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_rawevent project_id_refs_id_d849fb4d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_rawevent
    ADD CONSTRAINT project_id_refs_id_d849fb4d FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releaseprojectenvironment project_id_refs_id_dc770857; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment
    ADD CONSTRAINT project_id_refs_id_dc770857 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectkey project_id_refs_id_e4d8a857; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectkey
    ADD CONSTRAINT project_id_refs_id_e4d8a857 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useroption project_id_refs_id_eb596317; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT project_id_refs_id_eb596317 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_processingissue project_id_refs_id_f04dda9c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_processingissue
    ADD CONSTRAINT project_id_refs_id_f04dda9c FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectownership project_id_refs_id_f45bf622; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectownership
    ADD CONSTRAINT project_id_refs_id_f45bf622 FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectteam project_id_refs_id_f5d7021b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectteam
    ADD CONSTRAINT project_id_refs_id_f5d7021b FOREIGN KEY (project_id) REFERENCES public.sentry_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryapp proxy_user_id_refs_id_b5ba64b3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryapp
    ADD CONSTRAINT proxy_user_id_refs_id_b5ba64b3 FOREIGN KEY (proxy_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_pullrequest_commit pull_request_id_refs_id_103d7ab7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_pullrequest_commit
    ADD CONSTRAINT pull_request_id_refs_id_103d7ab7 FOREIGN KEY (pull_request_id) REFERENCES public.sentry_pull_request(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_eventprocessingissue raw_event_id_refs_id_c533ed8a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_eventprocessingissue
    ADD CONSTRAINT raw_event_id_refs_id_c533ed8a FOREIGN KEY (raw_event_id) REFERENCES public.sentry_rawevent(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_deploy release_id_refs_id_056a8a23; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_deploy
    ADD CONSTRAINT release_id_refs_id_056a8a23 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupresolution release_id_refs_id_0599bf90; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupresolution
    ADD CONSTRAINT release_id_refs_id_0599bf90 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasecommit release_id_refs_id_26c8c7a0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasecommit
    ADD CONSTRAINT release_id_refs_id_26c8c7a0 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releasefile release_id_refs_id_8c214aaf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releasefile
    ADD CONSTRAINT release_id_refs_id_8c214aaf FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releaseprojectenvironment release_id_refs_id_9c5c15c9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseprojectenvironment
    ADD CONSTRAINT release_id_refs_id_9c5c15c9 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_distribution release_id_refs_id_a8524557; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_distribution
    ADD CONSTRAINT release_id_refs_id_a8524557 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_release_project release_id_refs_id_add4a457; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_release_project
    ADD CONSTRAINT release_id_refs_id_add4a457 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_releaseheadcommit release_id_refs_id_b02d8da1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_releaseheadcommit
    ADD CONSTRAINT release_id_refs_id_b02d8da1 FOREIGN KEY (release_id) REFERENCES public.sentry_release(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_grouprulestatus rule_id_refs_id_39ff91f8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_grouprulestatus
    ADD CONSTRAINT rule_id_refs_id_39ff91f8 FOREIGN KEY (rule_id) REFERENCES public.sentry_rule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch_userdefault savedsearch_id_refs_id_8d85995b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault
    ADD CONSTRAINT savedsearch_id_refs_id_8d85995b FOREIGN KEY (savedsearch_id) REFERENCES public.sentry_savedsearch(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappinstallation sentry_app_id_refs_id_00a7f6dc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappinstallation
    ADD CONSTRAINT sentry_app_id_refs_id_00a7f6dc FOREIGN KEY (sentry_app_id) REFERENCES public.sentry_sentryapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappcomponent sentry_app_id_refs_id_c89a9108; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappcomponent
    ADD CONSTRAINT sentry_app_id_refs_id_c89a9108 FOREIGN KEY (sentry_app_id) REFERENCES public.sentry_sentryapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_sentryappavatar sentry_app_id_refs_id_e87c2abd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_sentryappavatar
    ADD CONSTRAINT sentry_app_id_refs_id_e87c2abd FOREIGN KEY (sentry_app_id) REFERENCES public.sentry_sentryapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_servicehookproject service_hook_id_refs_id_2038bdeb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_servicehookproject
    ADD CONSTRAINT service_hook_id_refs_id_2038bdeb FOREIGN KEY (service_hook_id) REFERENCES public.sentry_servicehook(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_auditlogentry target_user_id_refs_id_cac0f7f5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_auditlogentry
    ADD CONSTRAINT target_user_id_refs_id_cac0f7f5 FOREIGN KEY (target_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_authprovider_default_teams team_id_refs_id_10a85f7b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authprovider_default_teams
    ADD CONSTRAINT team_id_refs_id_10a85f7b FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectteam team_id_refs_id_1d6cecd2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectteam
    ADD CONSTRAINT team_id_refs_id_1d6cecd2 FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_teamavatar team_id_refs_id_25346e15; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_teamavatar
    ADD CONSTRAINT team_id_refs_id_25346e15 FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupasignee team_id_refs_id_5b32ca44; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT team_id_refs_id_5b32ca44 FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationmember_teams team_id_refs_id_d98f2858; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember_teams
    ADD CONSTRAINT team_id_refs_id_d98f2858 FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationaccessrequest team_id_refs_id_ea6e538b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationaccessrequest
    ADD CONSTRAINT team_id_refs_id_ea6e538b FOREIGN KEY (team_id) REFERENCES public.sentry_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_hipchat_ac_tenant_projects tenant_id_refs_id_6c1ae0ea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_projects
    ADD CONSTRAINT tenant_id_refs_id_6c1ae0ea FOREIGN KEY (tenant_id) REFERENCES public.sentry_hipchat_ac_tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_hipchat_ac_tenant_organizations tenant_id_refs_id_f26e0c12; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_hipchat_ac_tenant_organizations
    ADD CONSTRAINT tenant_id_refs_id_f26e0c12 FOREIGN KEY (tenant_id) REFERENCES public.sentry_hipchat_ac_tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupbookmark user_id_refs_id_05ac45cc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupbookmark
    ADD CONSTRAINT user_id_refs_id_05ac45cc FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useravatar user_id_refs_id_1a689f2e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useravatar
    ADD CONSTRAINT user_id_refs_id_1a689f2e FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_assistant_activity user_id_refs_id_21a4e278; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_assistant_activity
    ADD CONSTRAINT user_id_refs_id_21a4e278 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationonboardingtask user_id_refs_id_22c181a4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationonboardingtask
    ADD CONSTRAINT user_id_refs_id_22c181a4 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupseen user_id_refs_id_270b7315; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupseen
    ADD CONSTRAINT user_id_refs_id_270b7315 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_identity user_id_refs_id_291a5251; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_identity
    ADD CONSTRAINT user_id_refs_id_291a5251 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_projectbookmark user_id_refs_id_32679665; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_projectbookmark
    ADD CONSTRAINT user_id_refs_id_32679665 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_savedsearch_userdefault user_id_refs_id_3f7101ca; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_savedsearch_userdefault
    ADD CONSTRAINT user_id_refs_id_3f7101ca FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_userpermission user_id_refs_id_49d60dc2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userpermission
    ADD CONSTRAINT user_id_refs_id_49d60dc2 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_promptsactivity user_id_refs_id_4bc2564f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_promptsactivity
    ADD CONSTRAINT user_id_refs_id_4bc2564f FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apigrant user_id_refs_id_5368c652; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apigrant
    ADD CONSTRAINT user_id_refs_id_5368c652 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apiauthorization user_id_refs_id_55597d94; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apiauthorization
    ADD CONSTRAINT user_id_refs_id_55597d94 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_broadcastseen user_id_refs_id_5d9e5ad9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_broadcastseen
    ADD CONSTRAINT user_id_refs_id_5d9e5ad9 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_activity user_id_refs_id_6caec40e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_activity
    ADD CONSTRAINT user_id_refs_id_6caec40e FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useroption user_id_refs_id_73734413; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useroption
    ADD CONSTRAINT user_id_refs_id_73734413 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_authidentity user_id_refs_id_78163ab5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_authidentity
    ADD CONSTRAINT user_id_refs_id_78163ab5 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_apitoken user_id_refs_id_78c75ee2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_apitoken
    ADD CONSTRAINT user_id_refs_id_78c75ee2 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_authenticator user_id_refs_id_8e85b45f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_authenticator
    ADD CONSTRAINT user_id_refs_id_8e85b45f FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_userip user_id_refs_id_96273ab1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_userip
    ADD CONSTRAINT user_id_refs_id_96273ab1 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_useremail user_id_refs_id_ae956867; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_useremail
    ADD CONSTRAINT user_id_refs_id_ae956867 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_organizationmember user_id_refs_id_be455e60; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_organizationmember
    ADD CONSTRAINT user_id_refs_id_be455e60 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_lostpasswordhash user_id_refs_id_c60bdf9b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_lostpasswordhash
    ADD CONSTRAINT user_id_refs_id_c60bdf9b FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_recentsearch user_id_refs_id_e212afed; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_recentsearch
    ADD CONSTRAINT user_id_refs_id_e212afed FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: social_auth_usersocialauth user_id_refs_id_e6cbdf29; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_auth_usersocialauth
    ADD CONSTRAINT user_id_refs_id_e6cbdf29 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupshare user_id_refs_id_e7ef4954; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupshare
    ADD CONSTRAINT user_id_refs_id_e7ef4954 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupsubscription user_id_refs_id_efb4b379; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupsubscription
    ADD CONSTRAINT user_id_refs_id_efb4b379 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_groupasignee user_id_refs_id_f4dcb8d1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_groupasignee
    ADD CONSTRAINT user_id_refs_id_f4dcb8d1 FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_eventtag value_id_refs_id_1e1ecec9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_eventtag
    ADD CONSTRAINT value_id_refs_id_1e1ecec9 FOREIGN KEY (value_id) REFERENCES public.tagstore_tagvalue(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagstore_grouptagvalue value_id_refs_id_7d6cb4ac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagstore_grouptagvalue
    ADD CONSTRAINT value_id_refs_id_7d6cb4ac FOREIGN KEY (value_id) REFERENCES public.tagstore_tagvalue(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sentry_widgetdatasource widget_id_refs_id_ec03fd62; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sentry_widgetdatasource
    ADD CONSTRAINT widget_id_refs_id_ec03fd62 FOREIGN KEY (widget_id) REFERENCES public.sentry_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--
