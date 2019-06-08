CREATE OR REPLACE FUNCTION public.upd_updated_at() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- AUTOMATION


CREATE EVENT TRIGGER trg_create_table ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE add_timestamps_to_table();

CREATE OR REPLACE FUNCTION public.add_timestamps_to_table() RETURNS event_trigger
    LANGUAGE plpgsql
AS $BODY$
DECLARE table_name text;
BEGIN
    SELECT object_identity INTO STRICT table_name FROM pg_event_trigger_ddl_commands() WHERE object_type = 'table';
    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL;';
    EXECUTE 'ALTER TABLE '  || table_name || ' ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL;';
    raise notice 'table: %', REPLACE(table_name, '.', '_');
    EXECUTE 'CREATE TRIGGER t_' || REPLACE(table_name, '.', '_') || '
                 BEFORE UPDATE
                ON ' || table_name || '
                FOR EACH ROW
            EXECUTE PROCEDURE public.upd_updated_at();'
        ;
END;
$BODY$;