DROP TABLE IF EXISTS detailed;
CREATE TABLE detailed (
    staff_id integer,
    amount numeric(5,2),
    payment_date timestamp,
    rental_id integer,
    first_name varchar(45),
    last_name varchar(45),
    active varchar(10),
    store_id smallint
);

DROP TABLE IF EXISTS summary;
CREATE TABLE summary (
    employee_name varchar(100),
    year_date varchar(50),
    month_date varchar(50),
    monthly_revenue numeric(15,2)
);

INSERT INTO detailed (
    staff_id, --staff
    amount, --payment
    payment_date, --payment
    rental_id,--payment
    first_name, --staff
    last_name, --staff
    active, --staff
    store_id --staff
)
SELECT
    staff.staff_id, payment.amount, payment.payment_date, payment.rental_id, staff.first_name, staff.last_name,
        CASE
        WHEN staff.active = true
            THEN 'Active'
        WHEN staff.active = false
            THEN 'Not Active'
        END active,
    staff.store_id
FROM staff
INNER JOIN payment on payment.staff_id = staff.staff_id;

-- Create Function
CREATE FUNCTION summary_refresh_new()
RETURNS TRIGGER AS $BODY$ --https://hasura.io/learn/database/postgresql/triggers/1-create-trigger/
BEGIN

DELETE FROM summary;
INSERT INTO summary(
SELECT
concat_ws(', ', last_name, first_name) AS employee_name,
extract(year from payment_date) As Year,
to_char(payment_date, 'Mon') AS Month,
sum(amount) AS monthly_revenue
FROM detailed
GROUP BY employee_name, Year, Month
ORDER BY employee_name, Year, Month
);

RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

--Create Trigger
CREATE TRIGGER summary_refresh
AFTER INSERT ON detailed
FOR EACH STATEMENT
EXECUTE PROCEDURE summary_refresh_new();

CREATE PROCEDURE refresh_tables()
AS $BODY$
BEGIN

DELETE FROM detailed;

INSERT INTO detailed(
    staff_id, --staff
    amount, --payment
    payment_date, --payment
    rental_id,--payment
    first_name, --staff
    last_name, --staff
    active, --staff
    store_id --staff
)
SELECT
    staff.staff_id, payment.amount, payment.payment_date, payment.rental_id, staff.first_name, staff.last_name,
        CASE
        WHEN staff.active = true
            THEN 'Active'
        WHEN staff.active = false
            THEN 'Not Active'
        END active,
    staff.store_id
FROM staff
INNER JOIN payment on payment.staff_id = staff.staff_id;
END;
$BODY$ LANGUAGE plpgsql;

CALL refresh_tables();

SELECT *
FROM detailed;
SELECT *
FROM summary;


