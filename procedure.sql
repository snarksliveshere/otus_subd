CREATE OR REPLACE FUNCTION public.upd_updated_at() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;