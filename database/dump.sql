--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Debian 15.3-1.pgdg110+1)
-- Dumped by pg_dump version 15.3



--
-- Name: add_collection(text, character varying, character varying, character varying, character varying, character varying, text, text, text, public.geography, text, text, text, text, date, text, text[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_collection(collect_id text DEFAULT NULL::text, "order" character varying DEFAULT NULL::character varying, family character varying DEFAULT NULL::character varying, genus character varying DEFAULT NULL::character varying, kind character varying DEFAULT NULL::character varying, age character varying DEFAULT 'Unknown'::character varying, sex text DEFAULT 'Unknown'::text, vauch_inst text DEFAULT NULL::text, vauch_id text DEFAULT NULL::text, point geography DEFAULT NULL::geography, country text DEFAULT NULL::text, region text DEFAULT NULL::text, subregion text DEFAULT NULL::text, geocomment text DEFAULT NULL::text, date_collect date DEFAULT NULL::date, comment text DEFAULT NULL::text, collectors text[] DEFAULT '{}'::text[], rna boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    kind_id_       integer;
    subregion_id_  integer DEFAULT 4;
    collection_id_ integer;
    collector      text[];
    collector_id_  integer;
BEGIN
    kind_id_ := get_kind_id($5, (get_genus_id($4, (get_family_id($3, (get_order_id($2)))))));
    IF ($11 IS NOT NULL) THEN
        subregion_id_ := get_subregion_id($13, (get_region_id($12, (get_country_id($11)))));
    END IF;
    collection_id_ := (SELECT id FROM collection ORDER BY id DESC LIMIT 1);
    INSERT INTO collection("CatalogueNumber", collect_id, kind_id, subregion_id, point, vouch_inst_id, vouch_id, sex_id,
                           age_id, day, month, year, comment, geo_comment, rna)
    VALUES (concat('ZIN-TER-M-', collection_id_), $1, kind_id_, subregion_id_, $10, get_vouch_inst_id($8), $9,
            get_sex_id($7), get_age_id($6),
            extract(day from date_collect), extract(month from date_collect), extract(year from date_collect), $16, $14,
            $18);
    collection_id_ := collection_id_ + 1;
    IF (array_length($17, 1) IS NULL) THEN RETURN;
    END IF;
    FOREACH collector SLICE 1 IN ARRAY $17
        LOOP
            collector_id_ := get_collector_id(collector[1]);
            INSERT INTO collector_to_collection(collector_id, collection_id) VALUES (collector_id_, collection_id_);
        END LOOP;
END
$_$;


--
-- Name: add_topology(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_topology("order" character varying, family character varying DEFAULT NULL::character varying, genus character varying DEFAULT NULL::character varying, kind character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM (SELECT get_kind_id(kind, get_genus_id(genus, get_family_id(family, get_order_id("order")))));
    RETURN 'ok';
END
$$;


--
-- Name: FUNCTION add_topology("order" character varying, family character varying, genus character varying, kind character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.add_topology("order" character varying, family character varying, genus character varying, kind character varying) IS 'Функция для быстрого добавления топологии';





--
-- Name: collectors_test(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.collectors_test(collectors text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    collector text[];

    text_ text := '';

    collector_id integer;

BEGIN

    FOREACH collector SLICE 1 IN ARRAY $1

    LOOP

        collector_id := get_collector_id(collector[1]);



    END LOOP;

    RETURN collector_id;

END;

$_$;


--
-- Name: get_age_id(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_age_id(age_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    age_id integer;

BEGIN

    SELECT id INTO age_id FROM age WHERE $1 = age.name;

    IF age_id IS NULL THEN

        INSERT INTO age(name) VALUES ($1);

        SELECT id INTO age_id FROM age WHERE $1 = age.name;

    END IF;

    RETURN age_id;

END;

$_$;


--
-- Name: get_collector_id(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collector_id(last_name character varying, first_name character varying DEFAULT NULL::character varying, second_name character varying DEFAULT NULL::character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    collector_id integer;

BEGIN

    SELECT id

    INTO collector_id

    FROM collector

    WHERE collector.last_name = $1

      AND (collector.first_name = $2  or (collector.first_name is NULL and $2 is NULL))

      AND (collector.second_name = $3 or (collector.second_name is NULL and $3 is NULL));

    IF collector_id IS NULL THEN

        INSERT INTO collector(last_name, first_name, second_name) VALUES ($1, $2, $3);

        SELECT get_collector_id($1, $2, $3) INTO collector_id;

    END IF;

    RETURN collector_id;

END;

$_$;


--
-- Name: get_country_id(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_country_id(name text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    country_id integer;

BEGIN

    SELECT id INTO country_id FROM country WHERE $1 = country.name;

    IF country_id IS NULL THEN

        INSERT INTO country(name) VALUES ($1);

        SELECT get_country_id($1) INTO country_id;

    END IF;

    RETURN country_id;

END;

$_$;


--
-- Name: get_family_id(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_family_id(name character varying, order_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    family_id integer;

BEGIN

    SELECT id

    INTO family_id

    FROM family

    WHERE ($1 = family.name OR ($1 is NULL AND family.name is null))

      AND $2 = family.order_id;

    IF family_id IS NULL THEN

        INSERT INTO family(name, order_id) VALUES ($1, $2);

        SELECT get_family_id($1, $2) INTO family_id;

    END IF;

    RETURN family_id;

END;

$_$;


--
-- Name: get_genus_id(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_genus_id(name character varying, family_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    genus_id integer;

BEGIN

    SELECT id

    INTO genus_id

    FROM genus

    WHERE ($1 = genus.name OR ($1 is NULL AND genus.name is null))

      AND $2 = genus.family_id;

    IF genus_id IS NULL THEN

        INSERT INTO genus(name, family_id) VALUES ($1, $2);

        SELECT get_genus_id($1, $2) INTO genus_id;

    END IF;

    RETURN genus_id;

END;

$_$;


--
-- Name: get_id_by_name(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_id_by_name(table_name text, name_ text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    smth_id integer;

BEGIN

    EXECUTE format('SELECT id FROM %1$s WHERE %1$s.name = "%2$s"',  table_name, table_name, name_) INTO smth_id;

    RETURN smth_id;

END

$_$;


--
-- Name: get_kind_id(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_kind_id(name character varying, genus_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    kind_id integer;

BEGIN

    SELECT id

    INTO kind_id

    FROM kind

    WHERE ($1 = kind.name OR ($1 is NULL AND kind.name is null))

      AND $2 = kind.genus_id;

    IF kind_id IS NULL THEN

        INSERT INTO kind(name, genus_id) VALUES ($1, $2);

        SELECT get_kind_id($1, $2) INTO kind_id;

    END IF;

    RETURN kind_id;

END;

$_$;


--
-- Name: get_order_id(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_order_id(order_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    order_id integer;

BEGIN

    SELECT id INTO order_id FROM "order" WHERE ($1 = "order".name OR ($1 is NULL AND "order".name is null));

    IF order_id IS NULL THEN

        INSERT INTO "order"(name) VALUES ($1);

        SELECT get_order_id($1) INTO order_id;

    END IF;

    RETURN order_id;

END;

$_$;


--
-- Name: get_region_id(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_region_id(name text, country integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    region_id integer;

BEGIN

    SELECT id

    INTO region_id

    FROM region

    WHERE ($1 = region.name OR ($1 is NULL AND region.name is null))

      AND $2 = region.country_id;

    IF region_id IS NULL THEN

        INSERT INTO region(country_id, name) VALUES ($2, $1);

        SELECT get_region_id($1, $2) INTO region_id;

    END IF;

    RETURN region_id;

END;

$_$;


--
-- Name: get_sex_id(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_sex_id(sex_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    sex_id integer;

BEGIN

    SELECT id INTO sex_id FROM sex WHERE $1 = sex.name;

    IF sex_id IS NULL THEN

        INSERT INTO sex(name) VALUES ($1);

        SELECT id INTO sex_id FROM sex WHERE $1 = sex.name;

    END IF;

    RETURN sex_id;

END;

$_$;


--
-- Name: get_subregion_id(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_subregion_id(name text, region_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    subregion_id integer;

BEGIN

    SELECT id

    INTO subregion_id

    FROM subregion

    WHERE ($1 = subregion.name OR ($1 is NULL AND subregion.name is null))

      AND $2 = subregion.region_id;

    IF subregion_id IS NULL THEN

        INSERT INTO subregion(region_id, name) VALUES ($2, $1);

        SELECT get_subregion_id($1, $2) INTO subregion_id;

    END IF;

    RETURN subregion_id;

END;

$_$;





--
-- Name: get_vouch_inst_id(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_vouch_inst_id(name text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

    vouch_inst_id integer;

BEGIN

    SELECT id INTO vouch_inst_id FROM voucher_institute WHERE $1 = voucher_institute.name;

    IF vouch_inst_id IS NULL THEN

        INSERT INTO voucher_institute(name) VALUES ($1);

        SELECT get_vouch_inst_id($1) INTO vouch_inst_id;

    END IF;

    RETURN vouch_inst_id;

END;

$_$;


--
-- Name: login(text, text); Type: FUNCTION; Schema: public; Owner: -
--


--
-- Name: remove_collection(integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.remove_collection(IN col_id integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM collection WHERE col_id = id;

END;

$$;


--
-- Name: remove_collection_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.remove_collection_by_id(col_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM collection WHERE col_id = id;

END;

$$;


--
-- Name: test(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.test() RETURNS text
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN 'ok';

END

$$;


--
-- Name: try_cast_double(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_double(inp text) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
  BEGIN
    BEGIN
      RETURN inp::double precision;
    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
    END;
  END;
$$;


--
-- Name: update_collection_by_id(integer, text, character varying, character varying, character varying, character varying, character varying, text, text, text, public.geography, text, text, text, text, date, text, text[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_collection_by_id(col_id integer, collect_id text DEFAULT NULL::text, "order" character varying DEFAULT NULL::character varying, family character varying DEFAULT NULL::character varying, genus character varying DEFAULT NULL::character varying, kind character varying DEFAULT NULL::character varying, age character varying DEFAULT 'Unknown'::character varying, sex text DEFAULT 'Unknown'::text, vauch_inst text DEFAULT NULL::text, vauch_id text DEFAULT NULL::text, point geography DEFAULT NULL::geography, country text DEFAULT NULL::text, region text DEFAULT NULL::text, subregion text DEFAULT NULL::text, geocomment text DEFAULT NULL::text, date_collect date DEFAULT NULL::date, comment text DEFAULT NULL::text, collectors text[] DEFAULT '{}'::text[], rna boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    kind_id_      integer;
    subregion_id_ integer DEFAULT 4;
    collector     text[];
    collector_id_ int;
BEGIN
    kind_id_ := get_kind_id($6, (get_genus_id($5, (get_family_id($4, (get_order_id($3)))))));
    IF ($12 IS NOT NULL) THEN
        subregion_id_ := get_subregion_id($14, (get_region_id($13, (get_country_id($12)))));
    END IF;
    UPDATE collection
    SET kind_id           = kind_id_,
        "CatalogueNumber" = concat('ZIN-TER-M-', col_id),
        subregion_id      = subregion_id_,
        collect_id        = $2,
        age_id            = get_age_id(age),
        sex_id            = get_sex_id(sex),
        vouch_inst_id     = get_vouch_inst_id(vauch_inst),
        vouch_id          = $10,
        point             = $11,
        geo_comment       = geocomment,
        day               = extract(day from date_collect),
        month             = extract(month from date_collect),
        year              = extract(year from date_collect),
        comment           = $17,
        rna               = $19
    WHERE id = col_id;
    DELETE FROM collector_to_collection WHERE collection_id = col_id;
    IF (array_length($18, 1) IS NULL) THEN
        RETURN;
    END IF;
    FOREACH collector SLICE 1 IN ARRAY $18
        LOOP
            collector_id_ := get_collector_id(collector[1]);
            INSERT INTO collector_to_collection(collector_id, collection_id) VALUES (collector_id_, col_id);
        END LOOP;
END
$_$;


--
-- Name: url_decode(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.url_decode(data text) RETURNS bytea
    LANGUAGE sql IMMUTABLE
    AS $$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$$;


--
-- Name: url_encode(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.url_encode(data bytea) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;


--
-- Name: verify(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS TABLE(header json, payload json, valid boolean)
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT
    jwt.header AS header,
    jwt.payload AS payload,
    jwt.signature_ok AND tstzrange(
      to_timestamp(try_cast_double(jwt.payload->>'nbf')),
      to_timestamp(try_cast_double(jwt.payload->>'exp'))
    ) @> CURRENT_TIMESTAMP AS valid
  FROM (
    SELECT
      convert_from(url_decode(r[1]), 'utf8')::json AS header,
      convert_from(url_decode(r[2]), 'utf8')::json AS payload,
      r[3] = algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS signature_ok
    FROM regexp_split_to_array(token, '\.') r
  ) jwt
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;



--
-- Name: age; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.age (
    id integer NOT NULL,
    name character varying(20)
);


--
-- Name: TABLE age; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.age IS 'Возраста животных';


--
-- Name: COLUMN age.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.age.id IS 'ID возраста';


--
-- Name: COLUMN age.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.age.name IS 'Назване возраста';


--
-- Name: age_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.age_id_seq
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


--
-- Name: age_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.age_id_seq OWNED BY public.age.id;


--
-- Name: basic_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.basic_view AS
SELECT
    NULL::integer AS id,
    NULL::text AS "CatalogueNumber",
    NULL::text AS collect_id,
    NULL::character varying(80) AS "Отряд",
    NULL::character varying(80) AS "Семейство",
    NULL::character varying(80) AS "Род",
    NULL::character varying(80) AS "Вид",
    NULL::character varying(20) AS "Возраст",
    NULL::character varying(40) AS "Пол",
    NULL::text AS "Вауч. институт",
    NULL::character varying(20) AS "Ваучерный ID",
    NULL::double precision AS latitude,
    NULL::double precision AS longtitude,
    NULL::text AS "Страна",
    NULL::text AS "Регион",
    NULL::text AS "Субрегион",
    NULL::text AS "Геокомментарий",
    NULL::text AS "Дата",
    NULL::boolean AS rna,
    NULL::text AS "Комментарий",
    NULL::text AS "Коллекторы",
    NULL::boolean AS "Файл";


--
-- Name: collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection (
    id integer NOT NULL,
    "CatalogueNumber" text,
    collect_id text,
    kind_id integer NOT NULL,
    subregion_id integer NOT NULL,
    gen_bank_id character varying(20),
    point geography(Point,4326),
    vouch_inst_id integer,
    vouch_id character varying(20),
    rna boolean DEFAULT false NOT NULL,
    sex_id integer,
    age_id integer,
    day integer,
    month integer,
    year integer NOT NULL,
    comment text,
    geo_comment text,
    file_url text,
    CONSTRAINT genbank_check CHECK ((((gen_bank_id)::text ~ 'OP\d+'::text) OR (gen_bank_id IS NULL)))
);


--
-- Name: TABLE collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.collection IS 'Коллекция лаборатории Эволюционной геномики и палеогеномики';


--
-- Name: COLUMN collection.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.id IS 'ID Taxon';


--
-- Name: COLUMN collection."CatalogueNumber"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection."CatalogueNumber" IS 'Номер в каталоге';


--
-- Name: COLUMN collection.collect_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.collect_id IS 'Номер сбора';


--
-- Name: COLUMN collection.kind_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.kind_id IS 'ID вида';


--
-- Name: COLUMN collection.subregion_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.subregion_id IS 'ID Субрегиона';


--
-- Name: COLUMN collection.gen_bank_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.gen_bank_id IS 'GENBANK';


--
-- Name: COLUMN collection.point; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.point IS 'Точка в координатах';


--
-- Name: COLUMN collection.vouch_inst_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.vouch_inst_id IS 'Вауч. Инст.';


--
-- Name: COLUMN collection.vouch_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.vouch_id IS 'Вауч. Код';


--
-- Name: COLUMN collection.sex_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.sex_id IS 'Пол';


--
-- Name: COLUMN collection.age_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.age_id IS 'ID возраста';


--
-- Name: COLUMN collection.file_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collection.file_url IS 'Ссылка на файл';


--
-- Name: CONSTRAINT genbank_check ON collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT genbank_check ON public.collection IS 'Проверка на правильность GENBANK';


--
-- Name: collection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_id_seq OWNED BY public.collection.id;


--
-- Name: collector; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collector (
    id integer NOT NULL,
    last_name character varying(100) NOT NULL,
    first_name character varying(100),
    second_name character varying(100)
);


--
-- Name: TABLE collector; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.collector IS 'Коллектор ';


--
-- Name: COLUMN collector.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collector.id IS 'ID коллектора';


--
-- Name: COLUMN collector.last_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collector.last_name IS 'Фамилия';


--
-- Name: COLUMN collector.first_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collector.first_name IS 'Имя';


--
-- Name: COLUMN collector.second_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.collector.second_name IS 'Отчество';


--
-- Name: collector_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collector_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collector_id_seq OWNED BY public.collector.id;


--
-- Name: collector_to_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collector_to_collection (
    collector_id integer NOT NULL,
    collection_id integer NOT NULL
);


--
-- Name: TABLE collector_to_collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.collector_to_collection IS 'Смежная таблица для того чтобы было несколько коллекторов к элементу коллекции';


--
-- Name: country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.country IS 'Страна';


--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_id_seq OWNED BY public.country.id;


--
-- Name: family; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.family (
    id integer NOT NULL,
    order_id integer NOT NULL,
    name character varying(80)
);


--
-- Name: TABLE family; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.family IS 'Семейство';


--
-- Name: COLUMN family.order_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.family.order_id IS 'Идентификатор отряда';


--
-- Name: COLUMN family.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.family.name IS 'Название семейства';


--
-- Name: family_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.family_id_seq OWNED BY public.family.id;


--
-- Name: genus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genus (
    id integer NOT NULL,
    family_id integer NOT NULL,
    name character varying(80)
);


--
-- Name: TABLE genus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.genus IS 'Род';


--
-- Name: COLUMN genus.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.genus.id IS 'Идентификатор рода';


--
-- Name: COLUMN genus.family_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.genus.family_id IS 'Идентиификатор семейства';


--
-- Name: COLUMN genus.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.genus.name IS 'Название рода';


--
-- Name: genus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genus_id_seq OWNED BY public.genus.id;


--
-- Name: kind; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kind (
    id integer NOT NULL,
    genus_id integer NOT NULL,
    name character varying(80)
);


--
-- Name: TABLE kind; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.kind IS 'вид';


--
-- Name: COLUMN kind.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.kind.id IS 'Идентификатор вида';


--
-- Name: COLUMN kind.genus_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.kind.genus_id IS 'Идентификатор рода';


--
-- Name: COLUMN kind.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.kind.name IS 'Название вида';


--
-- Name: kind_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kind_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kind_id_seq OWNED BY public.kind.id;


--
-- Name: order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."order" (
    id integer NOT NULL,
    name character varying(80)
);


--
-- Name: TABLE "order"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."order" IS 'Отряд';


--
-- Name: COLUMN "order".id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."order".id IS 'Идентификатор отряда';


--
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_id_seq OWNED BY public."order".id;


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id integer NOT NULL,
    country_id integer NOT NULL,
    name text
);


--
-- Name: TABLE region; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.region IS 'Регион';


--
-- Name: COLUMN region.country_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.region.country_id IS 'Идентификатор к стране, к которой этот регион относится';


--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: sex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sex (
    id integer NOT NULL,
    name character varying(40) NOT NULL
);


--
-- Name: TABLE sex; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sex IS 'Пол';


--
-- Name: COLUMN sex.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sex.id IS 'ID пола';


--
-- Name: COLUMN sex.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sex.name IS 'Название пола';


--
-- Name: sex_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sex_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sex_id_seq OWNED BY public.sex.id;


--
-- Name: subregion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subregion (
    id integer NOT NULL,
    region_id integer NOT NULL,
    name text
);


--
-- Name: TABLE subregion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.subregion IS 'Субрегион';


--
-- Name: COLUMN subregion.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.subregion.id IS 'ID региона';


--
-- Name: COLUMN subregion.region_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.subregion.region_id IS 'ID к региону, к которому принадлежит';


--
-- Name: subregion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subregion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subregion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subregion_id_seq OWNED BY public.subregion.id;


--
-- Name: voucher_institute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.voucher_institute (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE voucher_institute; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.voucher_institute IS 'Ваучерный интститут';


--
-- Name: voucher_institute_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.voucher_institute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voucher_institute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.voucher_institute_id_seq OWNED BY public.voucher_institute.id;


--
-- Name: age id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age ALTER COLUMN id SET DEFAULT nextval('public.age_id_seq'::regclass);


--
-- Name: collection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection ALTER COLUMN id SET DEFAULT nextval('public.collection_id_seq'::regclass);


--
-- Name: collector id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collector ALTER COLUMN id SET DEFAULT nextval('public.collector_id_seq'::regclass);


--
-- Name: country id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);


--
-- Name: family id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family ALTER COLUMN id SET DEFAULT nextval('public.family_id_seq'::regclass);


--
-- Name: genus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genus ALTER COLUMN id SET DEFAULT nextval('public.genus_id_seq'::regclass);


--
-- Name: kind id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kind ALTER COLUMN id SET DEFAULT nextval('public.kind_id_seq'::regclass);


--
-- Name: order id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order" ALTER COLUMN id SET DEFAULT nextval('public.order_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: sex id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sex ALTER COLUMN id SET DEFAULT nextval('public.sex_id_seq'::regclass);


--
-- Name: subregion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subregion ALTER COLUMN id SET DEFAULT nextval('public.subregion_id_seq'::regclass);


--
-- Name: voucher_institute id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voucher_institute ALTER COLUMN id SET DEFAULT nextval('public.voucher_institute_id_seq'::regclass);




--
-- Name: age age_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age
    ADD CONSTRAINT age_pk PRIMARY KEY (id);


--
-- Name: collection collection_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pk PRIMARY KEY (id);


--
-- Name: collector collector_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collector
    ADD CONSTRAINT collector_pk PRIMARY KEY (id);


--
-- Name: collector_to_collection collector_to_collection_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collector_to_collection
    ADD CONSTRAINT collector_to_collection_pk PRIMARY KEY (collector_id, collection_id);


--
-- Name: country country_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pk PRIMARY KEY (id);


--
-- Name: family family_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family
    ADD CONSTRAINT family_pk PRIMARY KEY (id);


--
-- Name: genus genus_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genus
    ADD CONSTRAINT genus_pk PRIMARY KEY (id);


--
-- Name: kind kind_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kind
    ADD CONSTRAINT kind_pk PRIMARY KEY (id);


--
-- Name: order order_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pk PRIMARY KEY (id);


--
-- Name: region region_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pk PRIMARY KEY (id);


--
-- Name: sex sex_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sex
    ADD CONSTRAINT sex_pk PRIMARY KEY (id);


--
-- Name: subregion subregion_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subregion
    ADD CONSTRAINT subregion_pk PRIMARY KEY (id);


--
-- Name: voucher_institute voucher_institute_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voucher_institute
    ADD CONSTRAINT voucher_institute_pk PRIMARY KEY (id);


--
-- Name: basic_view _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.basic_view AS
 SELECT collection.id,
    collection."CatalogueNumber",
    collection.collect_id,
    order_.name AS "Отряд",
    family.name AS "Семейство",
    genus.name AS "Род",
    kind.name AS "Вид",
    age.name AS "Возраст",
    sex.name AS "Пол",
    vi.name AS "Вауч. институт",
    collection.vouch_id AS "Ваучерный ID",
    st_y((collection.point)::geometry) AS latitude,
    st_x((collection.point)::geometry) AS longtitude,
    country.name AS "Страна",
    region.name AS "Регион",
    subregion.name AS "Субрегион",
    collection.geo_comment AS "Геокомментарий",
        CASE
            WHEN (collection.year = 0) THEN NULL::text
            WHEN ((collection.day IS NULL) AND (collection.month IS NULL)) THEN (collection.year)::text
            WHEN (collection.day IS NULL) THEN concat_ws('.'::text, collection.month, collection.year)
            ELSE concat_ws('.'::text, collection.day, collection.month, collection.year)
        END AS "Дата",
    collection.rna,
    collection.comment AS "Комментарий",
    string_agg(concat(c.last_name,
        CASE
            WHEN (c.first_name IS NOT NULL) THEN concat(' ', "left"((c.first_name)::text, 1), '.')
            ELSE ''::text
        END,
        CASE
            WHEN (c.second_name IS NOT NULL) THEN concat(' ', "left"((c.second_name)::text, 1), '.')
            ELSE ''::text
        END), ', '::text) AS "Коллекторы",
    (collection.file_url IS NOT NULL) AS "Файл"
   FROM ((((((((((((public.collection
     JOIN public.kind ON ((kind.id = collection.kind_id)))
     JOIN public.genus ON ((genus.id = kind.genus_id)))
     JOIN public.family ON ((family.id = genus.family_id)))
     JOIN public."order" order_ ON ((order_.id = family.order_id)))
     JOIN public.age ON ((age.id = collection.age_id)))
     JOIN public.sex ON ((collection.sex_id = sex.id)))
     JOIN public.voucher_institute vi ON ((vi.id = collection.vouch_inst_id)))
     JOIN public.subregion ON ((collection.subregion_id = subregion.id)))
     JOIN public.region ON ((subregion.region_id = region.id)))
     JOIN public.country ON ((region.country_id = country.id)))
     LEFT JOIN public.collector_to_collection ctc ON ((collection.id = ctc.collection_id)))
     LEFT JOIN public.collector c ON ((ctc.collector_id = c.id)))
  GROUP BY collection.id, order_.name, family.name, genus.name, kind.name, age.name, sex.name, vi.name, country.name, region.name, subregion.name
  ORDER BY collection.id;




--
-- Name: collection collection_age_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_age_id_fk FOREIGN KEY (age_id) REFERENCES public.age(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: collection collection_kind_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_kind_null_fk FOREIGN KEY (kind_id) REFERENCES public.kind(id);


--
-- Name: collection collection_sex_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_sex_id_fk FOREIGN KEY (sex_id) REFERENCES public.sex(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: collection collection_subregion_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_subregion_null_fk FOREIGN KEY (subregion_id) REFERENCES public.subregion(id);


--
-- Name: collection collection_voucher_institute_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_voucher_institute_null_fk FOREIGN KEY (vouch_inst_id) REFERENCES public.voucher_institute(id);


--
-- Name: collector_to_collection collector_to_collection_collection_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collector_to_collection
    ADD CONSTRAINT collector_to_collection_collection_null_fk FOREIGN KEY (collection_id) REFERENCES public.collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collector_to_collection collector_to_collection_collector_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collector_to_collection
    ADD CONSTRAINT collector_to_collection_collector_null_fk FOREIGN KEY (collector_id) REFERENCES public.collector(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family family_order_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family
    ADD CONSTRAINT family_order_null_fk FOREIGN KEY (order_id) REFERENCES public."order"(id);


--
-- Name: genus genus_family_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genus
    ADD CONSTRAINT genus_family_null_fk FOREIGN KEY (family_id) REFERENCES public.family(id);


--
-- Name: region region_country_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_country_null_fk FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: subregion subregion_region_null_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subregion
    ADD CONSTRAINT subregion_region_null_fk FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- PostgreSQL database dump complete
--

