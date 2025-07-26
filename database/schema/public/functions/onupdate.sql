/********************************************************************
A Function to Update the "Updated On" Field for Table Columns

By default, PostgreSQL does not support the create table syntax with
the statement:

.. code-block:: sql

    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

However, the same can be implemented by using a function and a trigger
which is equivalent to the internal functionality of other database
flavors like MySQL.

The function is defined under the "public" schema as this trigger may
be accessed by all the tables which may belong to a different schema.
Ensure the field is always named as `updated_on` in the all the tables,
else a seperate function need to be created. The trigger function is
table specific and should be created for each table.

.. code-block:: sql

    CREATE TRIGGER <trigger-name> BEFORE UPDATE
    ON <table-name> FOR EACH ROW EXECUTE PROCEDURE onupdate();

The function is defined such that the "updated_on" field is updated
whenever the row is updated, for any underlying table with a trigger.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE FUNCTION public.onupdate() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    NEW.updated_on = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
