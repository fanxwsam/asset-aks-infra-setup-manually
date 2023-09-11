-- 0-uuid-ossp-create-extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public ;

-- 3-public.token_entry-table
CREATE TABLE public.token_entry
(
    processor_name varchar(255) not null,
    segment int not null,
    owner varchar(255),
    timestamp varchar(255) not null,
    token oid,
    token_type varchar(255),
    primary key (processor_name, segment)
);

-- 3-public.association_value_entry-table
CREATE TABLE public.association_value_entry
(
    id bigint not null
        constraint association_value_entry_pkey
            primary key,
    association_key varchar(255) not null,
    association_value varchar(255),
    saga_id varchar(255) not null,
    saga_type varchar(255)
);

CREATE INDEX idxk45eqnxkgd8hpdn6xixn8sgft
    on public.association_value_entry (saga_type, association_key, association_value);

CREATE INDEX idxgv5k1v2mh6frxuy5c0hgbau94
    on public.association_value_entry (saga_id, saga_type);

-- 3-public.saga_entry-table
CREATE TABLE public.saga_entry
(
    saga_id varchar(255) not null
        constraint saga_entry_pkey
            primary key,
    revision varchar(255),
    saga_type varchar(255),
    serialized_saga oid
);

-- 3-public.predicate-table
CREATE TABLE public.predicate
(
    id uuid
        constraint predicate_pkey
            primary key,
    name text,
    classification_id uuid,
    sub_classification_id uuid,
    predicate_group_id uuid,
    created_by uuid,
    updated_by uuid,
    created_date timestamp with time zone,
    updated_date timestamp with time zone,
    deleted_by uuid,
    deleted_date timestamp with time zone
);

-- 3-public.users-table
CREATE TABLE public.users
(
    id uuid default uuid_generate_v4()
        constraint users_pkey
            primary key,
    nickname text,
    timezone text,
    created_by uuid,
    updated_by uuid,
    created_date timestamp with time zone default current_timestamp,
    updated_date timestamp with time zone default current_timestamp,
    deleted_by uuid,
    deleted_date timestamp with time zone
);

-- 3-public.user_detail-table
CREATE TABLE public.user_detail
(
    id uuid default uuid_generate_v4()
        constraint user_detail_pkey
            primary key,
    country text,
    city text,
    gender text,
    dob timestamp with time zone,
    gender_assigned_at_birth text,
    ethnicity text,
    user_id uuid,
    created_by uuid,
    updated_by uuid,
    created_date timestamp with time zone default current_timestamp,
    updated_date timestamp with time zone default current_timestamp,
    deleted_by uuid,
    deleted_date timestamp with time zone
);

CREATE INDEX user_detail_users_user_id_idx
    on public.user_detail (user_id);

-- 3-public.user_predicate-table
CREATE TABLE public.user_predicate
(
    id uuid default uuid_generate_v4()
        constraint user_predicate_pkey
            primary key,
    user_id uuid,
    created_by uuid,
    updated_by uuid,
    created_date timestamp with time zone default current_timestamp,
    updated_date timestamp with time zone default current_timestamp,
    deleted_by uuid,
    deleted_date timestamp with time zone,
    predicate_id uuid not null,
    value text,
    numeric_value numeric
);

CREATE INDEX user_predicate_predicate_predicate_id_idx
    on public.user_predicate (predicate_id);

CREATE INDEX user_predicate_users_user_id_idx
    on public.user_predicate (user_id);

-- 3-public.user_contact-table
CREATE TABLE public.user_contact
(
    id uuid default uuid_generate_v4()
        constraint user_contact_pkey
            primary key,
    name text,
    first_name text,
    last_name text,
    email text not null,
    phone text,
    email_confirmed boolean default false,
    user_id uuid,
    created_by uuid,
    updated_by uuid,
    created_date timestamp with time zone default current_timestamp,
    updated_date timestamp with time zone default current_timestamp,
    deleted_by uuid,
    deleted_date timestamp with time zone
);

CREATE INDEX user_contact_users_user_id_idx
    on public.user_contact (user_id);

-- 4-public.predicate-insert-procedure
CREATE OR REPLACE PROCEDURE public.predicate_insertprocedure (
    id_paramIn uuid,
    name_paramIn text,
    classification_id_paramIn uuid,
    sub_classification_id_paramIn uuid,
    predicate_group_id_paramIn uuid,
    created_by_paramIn uuid,
    updated_by_paramIn uuid,
    created_date_paramIn timestamp with time zone,
    updated_date_paramIn timestamp with time zone,
    deleted_by_paramIn uuid,
    deleted_date_paramIn timestamp with time zone
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
INSERT INTO public.predicate(
    name,
    classification_id,
    sub_classification_id,
    predicate_group_id,
    created_by,
    updated_by,
    created_date,
    updated_date,
    deleted_by,
    deleted_date
)
VALUES
(
    name_paramIn,
    classification_id_paramIn,
    sub_classification_id_paramIn,
    predicate_group_id_paramIn,
    created_by_paramIn,
    updated_by_paramIn,
    created_date_paramIn,
    updated_date_paramIn,
    deleted_by_paramIn,
    deleted_date_paramIn
);
END;
$BODY$;

-- 4-public.users-insert-procedure
CREATE OR REPLACE PROCEDURE public.users_insertprocedure (
    id_paramIn uuid,
    nickname_paramIn text,
    timezone_paramIn text,
    created_by_paramIn uuid,
    updated_by_paramIn uuid,
    created_date_paramIn timestamp with time zone,
    updated_date_paramIn timestamp with time zone,
    deleted_by_paramIn uuid,
    deleted_date_paramIn timestamp with time zone
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
INSERT INTO public.users(
    nickname,
    timezone,
    created_by,
    updated_by,
    created_date,
    updated_date,
    deleted_by,
    deleted_date
)
VALUES
(
    nickname_paramIn,
    timezone_paramIn,
    created_by_paramIn,
    updated_by_paramIn,
    created_date_paramIn,
    updated_date_paramIn,
    deleted_by_paramIn,
    deleted_date_paramIn
);
END;
$BODY$;

-- 4-public.user_detail-insert-procedure
CREATE OR REPLACE PROCEDURE public.user_detail_insertprocedure (
    id_paramIn uuid,
    country_paramIn text,
    city_paramIn text,
    gender_paramIn text,
    dob_paramIn timestamp with time zone,
    gender_assigned_at_birth_paramIn text,
    ethnicity_paramIn text,
    user_id_paramIn uuid,
    created_by_paramIn uuid,
    updated_by_paramIn uuid,
    created_date_paramIn timestamp with time zone,
    updated_date_paramIn timestamp with time zone,
    deleted_by_paramIn uuid,
    deleted_date_paramIn timestamp with time zone
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
INSERT INTO public.user_detail(
    country,
    city,
    gender,
    dob,
    gender_assigned_at_birth,
    ethnicity,
    user_id,
    created_by,
    updated_by,
    created_date,
    updated_date,
    deleted_by,
    deleted_date
)
VALUES
(
    country_paramIn,
    city_paramIn,
    gender_paramIn,
    dob_paramIn,
    gender_assigned_at_birth_paramIn,
    ethnicity_paramIn,
    user_id_paramIn,
    created_by_paramIn,
    updated_by_paramIn,
    created_date_paramIn,
    updated_date_paramIn,
    deleted_by_paramIn,
    deleted_date_paramIn
);
END;
$BODY$;

-- 4-public.user_predicate-insert-procedure
CREATE OR REPLACE PROCEDURE public.user_predicate_insertprocedure (
    id_paramIn uuid,
    user_id_paramIn uuid,
    created_by_paramIn uuid,
    updated_by_paramIn uuid,
    created_date_paramIn timestamp with time zone,
    updated_date_paramIn timestamp with time zone,
    deleted_by_paramIn uuid,
    deleted_date_paramIn timestamp with time zone,
    predicate_id_paramIn uuid,
    value_paramIn text,
    numeric_value_paramIn numeric
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
INSERT INTO public.user_predicate(
    user_id,
    created_by,
    updated_by,
    created_date,
    updated_date,
    deleted_by,
    deleted_date,
    predicate_id,
    value,
    numeric_value
)
VALUES
(
    user_id_paramIn,
    created_by_paramIn,
    updated_by_paramIn,
    created_date_paramIn,
    updated_date_paramIn,
    deleted_by_paramIn,
    deleted_date_paramIn,
    predicate_id_paramIn,
    value_paramIn,
    numeric_value_paramIn
);
END;
$BODY$;

-- 4-public.user_contact-insert-procedure
CREATE OR REPLACE PROCEDURE public.user_contact_insertprocedure (
    id_paramIn uuid,
    name_paramIn text,
    first_name_paramIn text,
    last_name_paramIn text,
    email_paramIn text,
    phone_paramIn text,
    email_confirmed_paramIn boolean,
    user_id_paramIn uuid,
    created_by_paramIn uuid,
    updated_by_paramIn uuid,
    created_date_paramIn timestamp with time zone,
    updated_date_paramIn timestamp with time zone,
    deleted_by_paramIn uuid,
    deleted_date_paramIn timestamp with time zone
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
INSERT INTO public.user_contact(
    name,
    first_name,
    last_name,
    email,
    phone,
    email_confirmed,
    user_id,
    created_by,
    updated_by,
    created_date,
    updated_date,
    deleted_by,
    deleted_date
)
VALUES
(
    name_paramIn,
    first_name_paramIn,
    last_name_paramIn,
    email_paramIn,
    phone_paramIn,
    email_confirmed_paramIn,
    user_id_paramIn,
    created_by_paramIn,
    updated_by_paramIn,
    created_date_paramIn,
    updated_date_paramIn,
    deleted_by_paramIn,
    deleted_date_paramIn
);
END;
$BODY$;