CREATE OR REPLACE VIEW basic_view as
SELECT collection.id         AS ID,
       "CatalogueNumber",
       collect_id,
       order_.name           as Отряд,
       family.name           as Семейство,
       genus.name            as Род,
       kind.name             as Вид,
       age.name              as Возраст,
       sex.name              as Пол,
       vi.name               as "Вауч. институт",
       vouch_id              as "Ваучерный ID",
       ST_Y(point::geometry) as Latitude,
       ST_X(point::geometry) as Longtitude,
       country.name          as Страна,
       region.name           as Регион,
       subregion.name        as Субрегион,
       geo_comment           as Геокомментарий,
       CASE
           WHEN year = 0 THEN null
           WHEN day IS NULL AND month IS NULL THEN year::text
           WHEN day IS NULL THEN concat_ws('.', month, year)
           ELSE concat_ws('.', day, month, year)
           END               AS Дата,
       rna                   as RNA,
       comment               AS "Комментарий",
       string_agg(concat(c.last_name,
                            CASE WHEN c.first_name IS NOT NULL THEN concat(' ', "left"(c.first_name, 1), '.') ELSE '' END,
                            CASE WHEN c.second_name IS NOT NULL THEN concat(' ', "left"(c.second_name, 1), '.') ELSE '' END),
                  ', ')      AS "Коллекторы",
       file_url IS NOT NULL  as "Файл"
FROM collection
         JOIN kind on kind.id = collection.kind_id
         JOIN genus on genus.id = kind.genus_id
         JOIN family on family.id = genus.family_id
         JOIN "order" order_ on order_.id = family.order_id
         JOIN age on age.id = collection.age_id
         JOIN sex on collection.sex_id = sex.id
         JOIN voucher_institute vi on vi.id = collection.vouch_inst_id
         JOIN subregion on collection.subregion_id = subregion.id
         JOIN region on subregion.region_id = region.id
         JOIN country on region.country_id = country.id
         LEFT JOIN collector_to_collection ctc on collection.id = ctc.collection_id
         LEFT JOIN collector c on ctc.collector_id = c.id -- Если нет автора, то запись должна быть
GROUP BY collection.id, order_.name, family.name, genus.name, kind.name, age.name, sex.name, vi.name, country.name,
         region.name, subregion.name
ORDER BY collection.id;



DROP VIEW basic_view;

SELECT *
from basic_view;

-- DROP VIEW basic_view;

CREATE OR REPLACE FUNCTION get_age_id(age_name varchar(20))
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_sex_id(sex_name varchar(40))
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_order_id(order_name varchar(80))
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION get_family_id(name varchar(80), order_id integer)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION get_genus_id(name varchar(80), family_id integer)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_kind_id(name varchar(80), genus_id integer)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_country_id(name text)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_region_id(name text, country integer)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_subregion_id(name text, region_id integer)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_vouch_inst_id(name text)
    RETURNS integer
AS
$$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_collector_id(last_name varchar(100), first_name varchar(100) DEFAULT NULL,
                                            second_name varchar(100) DEFAULT NULL)
    RETURNS integer AS
$$
DECLARE
    collector_id integer;
BEGIN
    SELECT id
    INTO collector_id
    FROM collector
    WHERE collector.last_name = $1
      AND (collector.first_name = $2 or (collector.first_name is NULL and $2 is NULL))
      AND (collector.second_name = $3 or (collector.second_name is NULL and $3 is NULL));
    IF collector_id IS NULL THEN
        INSERT INTO collector(last_name, first_name, second_name) VALUES ($1, $2, $3);
        SELECT get_collector_id($1, $2, $3) INTO collector_id;
    END IF;
    RETURN collector_id;
END;
$$ LANGUAGE plpgsql;


SELECT get_collector_id('Панков');

DROP FUNCTION get_collector_id;


-- Добавление в коллекции
CREATE OR REPLACE FUNCTION add_collection(collect_id text default null, "order" varchar(80) default null,
                                          family varchar(80) default null, genus varchar(80) default null,
                                          kind varchar(80) default null, age varchar(20) DEFAULT 'Unknown', sex text DEFAULT 'Unknown', vauch_inst text DEFAULT NULL, vauch_id text default null,
                                          point geography(point, 4326) default null, country text default null, region text default null, subregion text default null,
                                          geocomment text default null, date_collect date default null, comment text default null,
                                          collectors text[][3] DEFAULT '{}', rna bool default false)
    RETURNS void
    LANGUAGE plpgsql
AS
$$
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
$$;
;


-- DROP PROCEDURE add_collection;

CALL add_collection(catalog_number := 'test', collect_id := 'test', "order" := 'test', family := 'test',
                    genus := 'test', kind := 'test', age := 'test', sex := 'test', vauch_inst := 'test',
                    vauch_id := 'test', point := 'POINT(0 0)', country := 'test', region := 'test', subregion := 'test',
                    geocomment := 'test', date_collect := '2004-4-4', comment := '',
                    collectors := '{{"Панков", "", "" }, {"Турсунова", "", ""}}');


-- Удаление из коллекции по ID
CREATE OR REPLACE FUNCTION public.remove_collection_by_id(col_id int)
    RETURNS void
    LANGUAGE plpgsql AS
$$
BEGIN
    DELETE FROM collection WHERE col_id = id;
END;
$$;



-- Обновление записи
CREATE OR REPLACE FUNCTION update_collection_by_id(col_id int, collect_id text DEFAULT null,
                                                   "order" varchar(80) DEFAULT null,
                                                   family varchar(80) DEFAULT null, genus varchar(80) DEFAULT null,
                                                   kind varchar(80) DEFAULT null, age varchar(20) DEFAULT 'Unknown',
                                                   sex text DEFAULT 'Unknown', vauch_inst text DEFAULT null,
                                                   vauch_id text DEFAULT null,
                                                   point geography(point, 4326) DEFAULT null, country text DEFAULT null,
                                                   region text DEFAULT null,
                                                   subregion text DEFAULT null,
                                                   geocomment text DEFAULT null, date_collect date DEFAULT null,
                                                   comment text DEFAULT null,
                                                   collectors text[][3] DEFAULT '{}', rna bool default false)
    RETURNS void
    LANGUAGE plpgsql AS
$$
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
$$;
;

SELECT update_collection_by_id(6080, catalog_number := 'Вася', collect_id := 'Вася', "order" := 'Вася',
                               family := 'test',
                               genus := 'test', kind := 'test', age := 'test', sex := 'test', vauch_inst := 'test',
                               vauch_id := 'test', point := 'POINT(0 0)', country := 'test', region := 'test',
                               subregion := 'test',
                               geocomment := 'test', date_collect := '2004-4-4', comment := '',
                               collectors := '{{"Панков", "", "" }, {"Викторов", "", ""}}');



-- Тестовая функция для тестирования циклов
CREATE OR REPLACE FUNCTION collectors_test(collectors text[])
    RETURNS int
AS
$$
DECLARE
    collector    text[];
    text_        text := '';
    collector_id integer;
BEGIN
    FOREACH collector SLICE 1 IN ARRAY $1
        LOOP
            collector_id := get_collector_id(collector[1]);
        END LOOP;
    RETURN collector_id;
END;
$$ LANGUAGE plpgsql;


SELECT collectors_test('{{"a", "b", "c"}, {"a", NULL, NULL}}');

DROP FUNCTION collectors_test;


-- Перезагрузка seqeunсов
ALTER SEQUENCE collector_id_seq RESTART 261;

ALTER SEQUENCE order_id_seq RESTART 11;

ALTER SEQUENCE family_id_seq RESTART 30;

ALTER SEQUENCE genus_id_seq RESTART 97;

ALTER SEQUENCE country_id_seq RESTART 42;

ALTER SEQUENCE region_id_seq RESTART 107;

ALTER SEQUENCE subregion_id_seq RESTART 143;

ALTER SEQUENCE voucher_institute_id_seq RESTART 35;

ALTER SEQUENCE kind_id_seq RESTART 259;

ALTER SEQUENCE collection_id_seq RESTART 6069;

-- Настройка web_anon - роль для гостей
create role web_anon nologin;
grant usage on schema public to web_anon;
grant select on all tables in schema public to web_anon;
grant select on basic_view to web_anon;
grant execute on function public.login(text, text) to web_anon;

-- работник лаборатории, может выполнять процедуры, что позволяет ему изменять базу данных
create user lab_worker;
grant web_anon to lab_worker;
grant USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to lab_worker;
grant execute on function add_collection(text, text, varchar, varchar, varchar, varchar, varchar, text, text, text,
    geography, text, text, text, text, date, text, text[], boolean) TO lab_worker;
grant execute on function update_collection_by_id(int, text, text, varchar, varchar, varchar, varchar, varchar, text, text, text,
    geography, text, text, text, text, date, text, text[], boolean) TO lab_worker;
grant insert, update on all tables in schema public to lab_worker;
revoke delete on all tables in schema public from lab_worker;
REVOKE execute on function remove_collection_by_id(int) FROM lab_worker;


-- зав. лабораторией
create user head_lab;
grant lab_worker to head_lab;
grant execute on all functions in schema public to head_lab;
grant usage on schema auth to head_lab;
grant insert, update, delete, select on all tables in schema public to head_lab;
grant insert, update, delete, select on all tables in schema auth to head_lab;


-- администратор бд - очень доверенное лицо, которое будет уверено в своих запросах
create user database_admin;
grant all privileges on schema public to database_admin;
grant all privileges on schema auth to database_admin;


-- роль для ролевого менеджера - postgrest, с помощью запросов понимает какого пользователя надо использовать
create role authenticator noinherit login password 'abobapass';
grant web_anon to authenticator;
grant lab_worker to authenticator;
grant head_lab to authenticator;



create schema auth;

DROP TABLE auth.users;

create table if not exists
    auth.users
(
    email text primary key check ( email ~* '^.+@.+\..+$' ),
    pass  text not null check (length(pass) < 512),
    role  name not null check (length(role) < 512)
);



-- проверка существует ли роль
create or replace function
    auth.check_role_exists() returns trigger as
$$
begin
    if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
        raise foreign_key_violation using message =
                    'unknown database role: ' || new.role;
        -- return null;
    end if;
    return new;
end
$$ language plpgsql;

drop trigger if exists ensure_user_role_exists on auth.users;
create constraint trigger ensure_user_role_exists
    after insert or update
    on auth.users
    for each row
execute procedure auth.check_role_exists();


create extension if not exists pgcrypto;


-- триггер хеширования паролей
create or replace function
    auth.encrypt_pass() returns trigger as
$$
begin
    if tg_op = 'INSERT' or new.pass <> old.pass then
        new.pass = crypt(new.pass, gen_salt('bf'));
    end if;
    return new;
end
$$ language plpgsql;

drop trigger if exists encrypt_pass on auth.users;
create trigger encrypt_pass
    before insert or update
    on auth.users
    for each row
execute procedure auth.encrypt_pass();


-- получение роли(фактически авторизация)
create or replace function
    auth.user_role(login text, pass text) returns name
    language plpgsql
as
$$
begin
    return (select role
            from auth.users
            where users.login = user_role.login
              and users.pass = crypt(user_role.pass, users.pass));
end;
$$;

DROP FUNCTION auth.user_role(text, text);

-- тип token - токен для входа пользователей
CREATE TYPE auth.jwt_token AS
(
    token text
);

create extension if not exists pgjwt;


ALTER DATABASE lab_base SET "app.jwt_secret" TO 'Q5He86xPvYscMiZxQw29gy8YkbD7a4aMDH1hQFP';


-- функция авторизации, для анонимного пользователя нужно только выполненные функций
create or replace function
    public.login(login text, pass text) returns auth.jwt_token as
$$
declare
    _role  name;
    result auth.jwt_token;
begin
    -- check email and password
    select auth.user_role(login, pass) into _role;
    if _role is null then
        raise invalid_password using message = 'invalid user or password';
    end if;
    -- НЕ КОМУ НЕ СООБЩАТЬ КОД, НЕ ХРАНИТЬ ЕГО В ОТКРЫТЫХ ПЕРЕМЕННЫХ
    select sign(
                   row_to_json(r), current_setting('app.jwt_secret')
               ) as token
    from (select _role                                             as role,
                 $1                                                as login,
                 extract(epoch from now())::integer + 60 * 60 * 24 as exp) r
    into result;
    return result;
end;
$$ language plpgsql security definer;


CREATE OR REPLACE FUNCTION auth.add_user(login text, pass text, role name) RETURNS void
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO auth.users(login, pass, role) VALUES ($1, $2, $3);
END
$$ SECURITY DEFINER;


-- роль должна быть доступна в authenticator, иначе ошибка
CALL auth.add_user('pank@pank.su', 'test_pass', 'postgres');


INSERT INTO auth.users(email, pass, role)
VALUES ('test@test.com', 'test', 'lab_worker');



REVOKE postgres FROM authenticator;


CREATE TYPE user_info AS
(
    login      text,
    avatar_url text,
    role       text
);

CREATE OR REPLACE FUNCTION get_user_info() RETURNS user_info
    LANGUAGE plpgsql AS
$$
    DECLARE login_ text := current_setting('request.jwt.claims', true)::json->>'login';
    DECLARE role text := current_setting('request.jwt.claims', true)::json->>'role';
    DECLARE result user_info;
BEGIN
        SELECT avatar INTO result.avatar_url FROM auth.users WHERE login_ = login;
        result.role := role;
        result.login := login_;
        return result;
END
$$ SECURITY DEFINER;

SELECT get_user_info();

DROP FUNCTION get_user_info();

-- TOOD переделать для проверки jwt, что он вообще есть
CREATE FUNCTION test() RETURNS text AS
$$
BEGIN
    RETURN 'ok';
END
$$ LANGUAGE plpgsql;

grant execute on function test() to lab_worker;
grant execute on function test() to head_lab;
revoke execute on function test() from web_anon;

CREATE OR REPLACE FUNCTION add_topology("order" varchar(80), family varchar(80) DEFAULT null, genus varchar(80) DEFAULT null,
                             kind varchar(80) DEFAULT null) RETURNS text AS
$$
BEGIN
    PERFORM (SELECT get_kind_id(kind, get_genus_id(genus, get_family_id(family, get_order_id("order")))));
    RETURN 'ok';
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_auth() RETURNS text AS
$$
DECLARE
    login_       text := current_setting('request.jwt.claims', true)::json ->> 'login';
    role_ text := current_setting('request.jwt.claims', true)::json ->> 'role';
BEGIN
    IF EXISTS(SELECT * FROM auth.users u WHERE u.role = role_ AND u.login = login_) THEN
        RETURN 'ok';
    END IF;
    RAISE sqlstate 'PT403' using message = 'Вы неавторизованы!',
      DETAIL = 'Обновите токен',
          HINT = 'Перезайдите в аккаунт или попробуйте обновить токен';
END
$$ LANGUAGE plpgsql SECURITY DEFINER ;