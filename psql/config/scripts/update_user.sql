set myvars.username to :username;

DO
$do$
DECLARE
    username  TEXT;
BEGIN
   username := current_setting('myvars.username');
   IF NOT EXISTS ( SELECT FROM pg_roles  
                   WHERE  rolname = username ) THEN
      CREATE ROLE username NOLOGIN;
   END IF;
END
$do$;

ALTER DATABASE :username OWNER TO :username;
ALTER USER :username WITH LOGIN;