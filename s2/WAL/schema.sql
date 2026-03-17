--
-- PostgreSQL database dump
--

\restrict RXgbWjMTTMSpMRn3G7mdj7ZzWlhudqfxLdbGXikamzNrHR4obvHM4zZUe7dNyPU

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pageinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA public;


--
-- Name: EXTENSION pageinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pageinspect IS 'inspect the contents of database pages at a low level';


--
-- Name: pg_walinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_walinspect WITH SCHEMA public;


--
-- Name: EXTENSION pg_walinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_walinspect IS 'functions to inspect contents of PostgreSQL Write-Ahead Log';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: employee_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.employee_status AS ENUM (
    'работает',
    'уволен',
    'отпуск'
);


ALTER TYPE public.employee_status OWNER TO postgres;

--
-- Name: order_priority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_priority AS ENUM (
    'низкий',
    'обычный',
    'высокий',
    'срочный'
);


ALTER TYPE public.order_priority OWNER TO postgres;

--
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'создан',
    'в работе',
    'выполнен',
    'отменен'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- Name: supplier_order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.supplier_order_status AS ENUM (
    'формируется',
    'отправлен',
    'доставлен',
    'отменен'
);


ALTER TYPE public.supplier_order_status OWNER TO postgres;

--
-- Name: add_client_with_loyalty(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_client_with_loyalty(IN new_full_name character varying, IN new_phone_number character varying, IN new_email character varying, IN new_driver_license character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	new_client_id INT;
BEGIN
	-- вставка нового клиента
	INSERT INTO client (full_name, phone_number, email, driver_license)
	VALUES (new_full_name, new_phone_number, new_email, new_driver_license);

    -- id нового клиента
	SELECT id INTO new_client_id
	FROM client
	WHERE driver_license = new_driver_license;

    -- создание карты лояльности для клиента
	INSERT INTO loyalty_card (id_client, registration_date, points_balance)
	VALUES (new_client_id, CURRENT_DATE, 0);
END;
$$;


ALTER PROCEDURE public.add_client_with_loyalty(IN new_full_name character varying, IN new_phone_number character varying, IN new_email character varying, IN new_driver_license character varying) OWNER TO postgres;

--
-- Name: add_new_employee(character varying, integer, character varying, character varying, date); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_new_employee(IN p_position character varying, IN p_location_id integer, IN p_full_name character varying, IN p_phone_number character varying, IN p_hire_date date DEFAULT CURRENT_DATE)
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF p_full_name IN ('Иванов Петр Ильич', 'Сорокина Ярослава Тимофеевна') THEN 
		RAISE WARNING 'Вы нанимаете опасных людей!!! Они в черном списке автосервиса'; 
	END IF; 

    INSERT INTO employee (
        position,
        location_id,
        status,
        full_name,
        phone_number,
        hire_date
    ) VALUES (
        p_position,
        p_location_id,
        'работает'::employee_status,
        p_full_name,
        p_phone_number,
        p_hire_date
    );
END;
$$;


ALTER PROCEDURE public.add_new_employee(IN p_position character varying, IN p_location_id integer, IN p_full_name character varying, IN p_phone_number character varying, IN p_hire_date date) OWNER TO postgres;

--
-- Name: calculate_amount_with_sale(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_amount_with_sale(client_id integer, amount integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    result_amount INTEGER;
BEGIN
    WITH discount_calc AS (
        SELECT 
            MAX(lr.discount_percent) as discount
        FROM loyalty_card lc
        JOIN loyalty_rules lr ON lc.points_balance >= lr.min_points
        WHERE lc.id_client = client_id
    )
    SELECT 
        amount - (amount * discount / 100)
    INTO result_amount
    FROM discount_calc;
    
    RETURN result_amount;
END;
$$;


ALTER FUNCTION public.calculate_amount_with_sale(client_id integer, amount integer) OWNER TO postgres;

--
-- Name: calculate_employee_salary(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_employee_salary(employee integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    working_days INTEGER;
BEGIN
	SELECT COUNT(*) INTO working_days
	FROM employee_shift_schedule
	WHERE employee_id = employee;
    
	RETURN working_days * 3000;
END;
$$;


ALTER FUNCTION public.calculate_employee_salary(employee integer) OWNER TO postgres;

--
-- Name: calculate_oil_change_cost(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_oil_change_cost(p_car_model_id integer, p_oil_quantity integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    oil_price INTEGER;
    service_cost INTEGER;
    total_cost INTEGER;
BEGIN
    -- Получаем цену масла (берем среднюю цену)
    SELECT price INTO oil_price
    FROM product_prices pp
    JOIN nomenclature n ON pp.article = n.article
    WHERE n.name LIKE '%Моторное масло%'
    ORDER BY pp.effective_date DESC
    LIMIT 1;
    
    -- Получаем стоимость услуги замены масла
    SELECT price INTO service_cost
    FROM service_prices
    WHERE service_name = 'Замена масла'
    ORDER BY effective_date DESC
    LIMIT 1;
    
    -- Расчет общей стоимости
    total_cost := (oil_price * p_oil_quantity) + service_cost;
    
    RETURN total_cost;
END;
$$;


ALTER FUNCTION public.calculate_oil_change_cost(p_car_model_id integer, p_oil_quantity integer) OWNER TO postgres;

--
-- Name: calculate_order_total_with_discount(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_order_total_with_discount(f_order_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	total_items INT;
	total_services INT;
	total_without_discount INT;
	client_points INT;
	f_discount_percent NUMERIC;
    final_total INT;	
BEGIN
    -- Сумма всех товаров в заказе
	SELECT COALESCE(SUM(total_price), 0) INTO total_items
	FROM client_order_items
	WHERE id_order = f_order_id; 

	-- Сумма всех услуг в заказе 
	SELECT COALESCE(SUM(total_price), 0) INTO total_services
	FROM client_order_services
	WHERE id_order = f_order_id; 

	-- Общая сумма без скидки
    total_without_discount := total_items + total_services;

	-- Баллы лояльности клиента 
    SELECT COALESCE(lc.points_balance, 0) INTO client_points
    FROM client_order co
    INNER JOIN loyalty_card lc ON co.id_client = lc.id_client
    WHERE co.id = f_order_id;

	-- Максимальная доступная скидка по баллам 
    SELECT COALESCE(MAX(discount_percent), 0) INTO f_discount_percent
    FROM loyalty_rules
    WHERE min_points <= client_points;

	-- Итоговая сумма со скидкой
    final_total := total_without_discount * (1 - f_discount_percent / 100);

	RETURN final_total;
END;
$$;


ALTER FUNCTION public.calculate_order_total_with_discount(f_order_id integer) OWNER TO postgres;

--
-- Name: check_is_clients_car(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_is_clients_car() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
    is_clients_car BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM car_client 
        WHERE car_id = NEW.id_car AND client_id=NEW.id_client) 
    INTO is_clients_car;
    
    IF NOT is_clients_car THEN 
        RAISE EXCEPTION 'Автомобиль не привязан к данному клиенту';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_is_clients_car() OWNER TO postgres;

--
-- Name: check_max_created_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_max_created_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    max_created_orders INTEGER := 10;
BEGIN
    IF (SELECT COUNT(*) FROM client_order WHERE status = 'создан') > max_created_orders THEN
        RAISE EXCEPTION 'Максимум % заказов со статусом "создан"', max_created_orders;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.check_max_created_orders() OWNER TO postgres;

--
-- Name: check_parts_availability(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_parts_availability(p_article character varying, p_required_quantity integer, p_location_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_stock INTEGER;
    is_available BOOLEAN;
    part_name VARCHAR(200);
BEGIN
    -- Получаем текущий остаток и название детали
    SELECT rog.quantity, n.name 
    INTO current_stock, part_name
    FROM remains_of_goods rog
    JOIN nomenclature n ON rog.article = n.article
    WHERE rog.article = p_article 
    AND rog.location_id = p_location_id;
    
    -- Проверяем доступность
    IF current_stock >= p_required_quantity THEN
        is_available := TRUE;
        RAISE NOTICE 'Деталь "%" доступна в количестве % (требуется: %)', 
            part_name, current_stock, p_required_quantity;
    ELSE
        is_available := FALSE;
        RAISE NOTICE 'Деталь "%" недоступна! В наличии: %, требуется: %', 
            part_name, current_stock, p_required_quantity;
    END IF;
    
    RETURN is_available;
END;
$$;


ALTER FUNCTION public.check_parts_availability(p_article character varying, p_required_quantity integer, p_location_id integer) OWNER TO postgres;

--
-- Name: create_car_service_order(integer, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_car_service_order(IN p_client_id integer, IN p_car_id integer, IN p_location_id integer, IN p_employee_id integer, IN p_notes text DEFAULT NULL::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_order_id INTEGER;
BEGIN
    -- Создаем новый заказ
    INSERT INTO client_order (id_client, id_car, id_location, employee_id, notes)
    VALUES (p_client_id, p_car_id, p_location_id, p_employee_id, p_notes)
    RETURNING id INTO new_order_id;
    
    -- Обновляем дату последнего визита в карте лояльности
    UPDATE loyalty_card 
    SET last_visit_date = CURRENT_DATE 
    WHERE id_client = p_client_id;
    
    RAISE NOTICE 'Создан заказ №% для клиента ID %', new_order_id, p_client_id;
END;
$$;


ALTER PROCEDURE public.create_car_service_order(IN p_client_id integer, IN p_car_id integer, IN p_location_id integer, IN p_employee_id integer, IN p_notes text) OWNER TO postgres;

--
-- Name: fire_lazy_employees(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.fire_lazy_employees(IN n integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    lazy_employee_id INTEGER;
    i INTEGER := 0;
BEGIN
    WHILE i < n LOOP
        SELECT ess.employee_id INTO lazy_employee_id
        FROM employee_shift_schedule ess
        JOIN employee e ON e.id = ess.employee_id AND e.status != 'уволен'
        GROUP BY ess.employee_id
        ORDER BY COUNT(ess.id) ASC
        LIMIT 1;
        
        IF lazy_employee_id IS NULL THEN
            EXIT;
        END IF;
        
        UPDATE employee 
        SET status = 'уволен'
        WHERE id = lazy_employee_id;
        
        i := i + 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.fire_lazy_employees(IN n integer) OWNER TO postgres;

--
-- Name: fire_lazy_employyes(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.fire_lazy_employyes(IN n integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	lazy_employee_id INTEGER;
	i INTEGER := 0;
BEGIN
	WHILE i < n LOOP
		SELECT employee_id INTO lazy_employee_id
		FROM employee_shift_schedule 
		GROUP BY employee_id
		HAVING count(id) = (SELECT MIN(COUNT(*)) 
			FROM employee_shift_schedule 
			GROUP BY employee_id);
		
		UPDATE employee 
		SET status = 'уволен'
		WHERE id = lazy_employee_id;
		
		i := i + 1;
	END LOOP;
	
END;
$$;


ALTER PROCEDURE public.fire_lazy_employyes(IN n integer) OWNER TO postgres;

--
-- Name: get_client_points(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_client_points(f_full_name character varying, f_phone_number character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT points_balance
			FROM loyalty_card 
			INNER JOIN client ON loyalty_card.id_client = client.id
			WHERE full_name = f_full_name AND phone_number = f_phone_number);
END;
$$;


ALTER FUNCTION public.get_client_points(f_full_name character varying, f_phone_number character varying) OWNER TO postgres;

--
-- Name: get_client_status(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_client_status(client_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	registration DATE; 
	min_reg DATE; 
	max_reg DATE;
	status VARCHAR(20);
BEGIN
    SELECT registration_date INTO registration
	FROM loyalty_card 
	WHERE id_client = client_id;

	SELECT MIN(registration_date) INTO min_reg
	FROM loyalty_card; 
	
	SELECT MAX(registration_date) INTO max_reg
	FROM loyalty_card; 

	IF registration = min_reg THEN 
		status := 'старичок';
	ELSIF registration = max_reg THEN 
		status := 'сапог';
	ELSE 
		status := 'нормис';
	END IF;

	RETURN status;
END;
$$;


ALTER FUNCTION public.get_client_status(client_id integer) OWNER TO postgres;

--
-- Name: log_client_order_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_client_order_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO client_order_status_log (order_id, status)
        VALUES (NEW.id, NEW.status);
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_client_order_status() OWNER TO postgres;

--
-- Name: update_emloyee_status(integer, public.employee_status); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_emloyee_status(IN employee_id integer, IN new_status public.employee_status)
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
	UPDATE employee
	SET status = new_status
	WHERE id = employee_id;
END;
$$;


ALTER PROCEDURE public.update_emloyee_status(IN employee_id integer, IN new_status public.employee_status) OWNER TO postgres;

--
-- Name: zipf_distribution(integer, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.zipf_distribution(max_value integer, exponent double precision DEFAULT 1.5) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    result INTEGER;
    rand_val FLOAT;
BEGIN
    rand_val = random();
    result = floor(max_value * pow(rand_val, exponent)) + 1;
    RETURN result;
END;
$$;


ALTER FUNCTION public.zipf_distribution(max_value integer, exponent double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: car; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car (
    id integer NOT NULL,
    vin character varying(17) NOT NULL,
    year integer NOT NULL,
    license_plate character varying(15),
    color character varying(30),
    model_id integer NOT NULL,
    mileage integer,
    engine_volume numeric(3,1),
    transmission character varying(20),
    fuel_type character varying(20),
    features jsonb,
    maintenance_history text[],
    last_maintenance date,
    condition_score integer,
    owners_count integer,
    description text,
    status character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_update timestamp without time zone,
    CONSTRAINT car_year_check CHECK (((year >= 1990) AND ((year)::numeric <= EXTRACT(year FROM CURRENT_DATE))))
);


ALTER TABLE public.car OWNER TO postgres;

--
-- Name: car_client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car_client (
    car_id integer NOT NULL,
    client_id integer NOT NULL
);


ALTER TABLE public.car_client OWNER TO postgres;

--
-- Name: car_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.car_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.car_id_seq OWNER TO postgres;

--
-- Name: car_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.car_id_seq OWNED BY public.car.id;


--
-- Name: car_model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car_model (
    id integer NOT NULL,
    model_name character varying(50) NOT NULL,
    brand_name character varying(50) NOT NULL
);


ALTER TABLE public.car_model OWNER TO postgres;

--
-- Name: car_model_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.car_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.car_model_id_seq OWNER TO postgres;

--
-- Name: car_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.car_model_id_seq OWNED BY public.car_model.id;


--
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    phone_number character varying(12) NOT NULL,
    email character varying(100),
    driver_license character varying(20),
    age integer,
    registration_date timestamp without time zone,
    client_status integer,
    preferences jsonb,
    location point,
    activity_range int4range,
    rating numeric(3,2),
    notes text,
    contact_methods text[],
    metadata jsonb,
    CONSTRAINT client_phone_number_check CHECK (((phone_number)::text ~ '^\+7[0-9]{10}$'::text)),
    CONSTRAINT valid_age CHECK (((age >= 18) AND (age <= 100)))
);


ALTER TABLE public.client OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_id_seq OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_id_seq OWNED BY public.client.id;


--
-- Name: client_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_order (
    id integer NOT NULL,
    id_client integer NOT NULL,
    id_car integer NOT NULL,
    id_location integer NOT NULL,
    employee_id integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    total_amount integer DEFAULT 0 NOT NULL,
    status public.order_status DEFAULT 'создан'::public.order_status NOT NULL,
    completion_date timestamp without time zone,
    notes text,
    priority public.order_priority DEFAULT 'обычный'::public.order_priority NOT NULL,
    CONSTRAINT client_order_check CHECK (((completion_date IS NULL) OR (completion_date >= created_date))),
    CONSTRAINT client_order_total_amount_check CHECK ((total_amount >= 0))
);


ALTER TABLE public.client_order OWNER TO postgres;

--
-- Name: client_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_order_id_seq OWNER TO postgres;

--
-- Name: client_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_order_id_seq OWNED BY public.client_order.id;


--
-- Name: client_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_order_items (
    id integer NOT NULL,
    id_order integer NOT NULL,
    product_price_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price integer NOT NULL,
    total_price integer GENERATED ALWAYS AS ((quantity * unit_price)) STORED,
    CONSTRAINT client_order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT client_order_items_unit_price_check CHECK ((unit_price > 0))
);


ALTER TABLE public.client_order_items OWNER TO postgres;

--
-- Name: client_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_order_items_id_seq OWNER TO postgres;

--
-- Name: client_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_order_items_id_seq OWNED BY public.client_order_items.id;


--
-- Name: client_order_services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_order_services (
    id integer NOT NULL,
    id_order integer NOT NULL,
    service_price_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price integer NOT NULL,
    total_price integer GENERATED ALWAYS AS ((quantity * unit_price)) STORED,
    CONSTRAINT client_order_services_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT client_order_services_unit_price_check CHECK ((unit_price > 0))
);


ALTER TABLE public.client_order_services OWNER TO postgres;

--
-- Name: client_order_services_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_order_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_order_services_id_seq OWNER TO postgres;

--
-- Name: client_order_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_order_services_id_seq OWNED BY public.client_order_services.id;


--
-- Name: client_order_status_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_order_status_log (
    id integer NOT NULL,
    order_id integer NOT NULL,
    status public.order_status NOT NULL,
    changes_date date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.client_order_status_log OWNER TO postgres;

--
-- Name: client_order_status_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_order_status_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_order_status_log_id_seq OWNER TO postgres;

--
-- Name: client_order_status_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_order_status_log_id_seq OWNED BY public.client_order_status_log.id;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    id integer NOT NULL,
    "position" character varying(50) NOT NULL,
    location_id integer NOT NULL,
    status public.employee_status NOT NULL,
    full_name character varying(100) NOT NULL,
    phone_number character varying(12) NOT NULL,
    hire_date date NOT NULL,
    CONSTRAINT employee_phone_number_check CHECK (((phone_number)::text ~ '^\+7[0-9]{10}$'::text))
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_id_seq OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_id_seq OWNED BY public.employee.id;


--
-- Name: employee_shift_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_shift_schedule (
    id integer NOT NULL,
    shift_schedule_id integer NOT NULL,
    employee_id integer NOT NULL
);


ALTER TABLE public.employee_shift_schedule OWNER TO postgres;

--
-- Name: employee_shift_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_shift_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_shift_schedule_id_seq OWNER TO postgres;

--
-- Name: employee_shift_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_shift_schedule_id_seq OWNED BY public.employee_shift_schedule.id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location (
    id integer NOT NULL,
    address character varying(200) NOT NULL,
    phone_number character varying(12) NOT NULL,
    working_hours character varying(50) NOT NULL,
    CONSTRAINT location_phone_number_check CHECK (((phone_number)::text ~ '^\+7[0-9]{10}$'::text))
);


ALTER TABLE public.location OWNER TO postgres;

--
-- Name: location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_id_seq OWNER TO postgres;

--
-- Name: location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.location_id_seq OWNED BY public.location.id;


--
-- Name: loyalty_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loyalty_rules (
    min_points integer NOT NULL,
    discount_percent numeric(5,2) NOT NULL,
    level_name character varying(50) NOT NULL,
    CONSTRAINT loyalty_rules_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric)))
);


ALTER TABLE public.loyalty_rules OWNER TO postgres;

--
-- Name: nomenclature; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nomenclature (
    article character varying(30) NOT NULL,
    name character varying(200) NOT NULL,
    id_supplier integer NOT NULL
);


ALTER TABLE public.nomenclature OWNER TO postgres;

--
-- Name: order_to_supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_to_supplier (
    id integer NOT NULL,
    id_supplier integer NOT NULL,
    id_location integer NOT NULL,
    total_cost integer,
    status public.supplier_order_status DEFAULT 'формируется'::public.supplier_order_status NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expected_delivery_date date,
    CONSTRAINT order_to_supplier_total_cost_check CHECK ((total_cost >= 0))
);


ALTER TABLE public.order_to_supplier OWNER TO postgres;

--
-- Name: order_to_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_to_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_to_supplier_id_seq OWNER TO postgres;

--
-- Name: order_to_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_to_supplier_id_seq OWNED BY public.order_to_supplier.id;


--
-- Name: product_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_prices (
    id integer NOT NULL,
    article character varying(30) NOT NULL,
    price integer NOT NULL,
    effective_date date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT product_prices_price_check CHECK ((price > 0))
);


ALTER TABLE public.product_prices OWNER TO postgres;

--
-- Name: product_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_prices_id_seq OWNER TO postgres;

--
-- Name: product_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_prices_id_seq OWNED BY public.product_prices.id;


--
-- Name: remains_of_goods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.remains_of_goods (
    id integer NOT NULL,
    location_id integer NOT NULL,
    article character varying(30) NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT remains_of_goods_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.remains_of_goods OWNER TO postgres;

--
-- Name: remains_of_goods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.remains_of_goods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.remains_of_goods_id_seq OWNER TO postgres;

--
-- Name: remains_of_goods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.remains_of_goods_id_seq OWNED BY public.remains_of_goods.id;


--
-- Name: service; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service (
    name character varying(100) NOT NULL,
    base_price integer NOT NULL,
    lead_time integer NOT NULL,
    CONSTRAINT service_base_price_check CHECK ((base_price > 0)),
    CONSTRAINT service_lead_time_check CHECK ((lead_time > 0))
);


ALTER TABLE public.service OWNER TO postgres;

--
-- Name: service_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_prices (
    id integer NOT NULL,
    service_name character varying(100) NOT NULL,
    price integer NOT NULL,
    effective_date date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT service_prices_price_check CHECK ((price > 0))
);


ALTER TABLE public.service_prices OWNER TO postgres;

--
-- Name: service_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.service_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_prices_id_seq OWNER TO postgres;

--
-- Name: service_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.service_prices_id_seq OWNED BY public.service_prices.id;


--
-- Name: shift_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shift_schedule (
    id integer NOT NULL,
    location_id integer NOT NULL,
    shift_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL
);


ALTER TABLE public.shift_schedule OWNER TO postgres;

--
-- Name: shift_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shift_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shift_schedule_id_seq OWNER TO postgres;

--
-- Name: shift_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shift_schedule_id_seq OWNED BY public.shift_schedule.id;


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier (
    id integer NOT NULL,
    company_name character varying(200) NOT NULL,
    phone_number character varying(12) NOT NULL,
    email character varying(100),
    bank_account character varying(20) NOT NULL,
    rating numeric(3,2),
    registration_date timestamp without time zone,
    category character varying(20),
    region character varying(50),
    contract_number character varying(30),
    metadata jsonb,
    delivery_area int4range,
    location point,
    description text,
    tags text[],
    CONSTRAINT supplier_phone_number_check CHECK (((phone_number)::text ~ '^\+7[0-9]{10}$'::text))
);


ALTER TABLE public.supplier OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_id_seq OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;


--
-- Name: supplier_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_order_items (
    id integer NOT NULL,
    id_order integer NOT NULL,
    article character varying(30) NOT NULL,
    quantity integer NOT NULL,
    unit_price integer NOT NULL,
    total_price integer GENERATED ALWAYS AS ((quantity * unit_price)) STORED,
    CONSTRAINT supplier_order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT supplier_order_items_unit_price_check CHECK ((unit_price > 0))
);


ALTER TABLE public.supplier_order_items OWNER TO postgres;

--
-- Name: supplier_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_order_items_id_seq OWNER TO postgres;

--
-- Name: supplier_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_order_items_id_seq OWNED BY public.supplier_order_items.id;


--
-- Name: user_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_logs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    action_type text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_logs OWNER TO postgres;

--
-- Name: user_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_logs_id_seq OWNER TO postgres;

--
-- Name: user_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_logs_id_seq OWNED BY public.user_logs.id;


--
-- Name: car id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car ALTER COLUMN id SET DEFAULT nextval('public.car_id_seq'::regclass);


--
-- Name: car_model id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_model ALTER COLUMN id SET DEFAULT nextval('public.car_model_id_seq'::regclass);


--
-- Name: client id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client ALTER COLUMN id SET DEFAULT nextval('public.client_id_seq'::regclass);


--
-- Name: client_order id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order ALTER COLUMN id SET DEFAULT nextval('public.client_order_id_seq'::regclass);


--
-- Name: client_order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_items ALTER COLUMN id SET DEFAULT nextval('public.client_order_items_id_seq'::regclass);


--
-- Name: client_order_services id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_services ALTER COLUMN id SET DEFAULT nextval('public.client_order_services_id_seq'::regclass);


--
-- Name: client_order_status_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_status_log ALTER COLUMN id SET DEFAULT nextval('public.client_order_status_log_id_seq'::regclass);


--
-- Name: employee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT nextval('public.employee_id_seq'::regclass);


--
-- Name: employee_shift_schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shift_schedule ALTER COLUMN id SET DEFAULT nextval('public.employee_shift_schedule_id_seq'::regclass);


--
-- Name: location id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location ALTER COLUMN id SET DEFAULT nextval('public.location_id_seq'::regclass);


--
-- Name: order_to_supplier id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_to_supplier ALTER COLUMN id SET DEFAULT nextval('public.order_to_supplier_id_seq'::regclass);


--
-- Name: product_prices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_prices ALTER COLUMN id SET DEFAULT nextval('public.product_prices_id_seq'::regclass);


--
-- Name: remains_of_goods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remains_of_goods ALTER COLUMN id SET DEFAULT nextval('public.remains_of_goods_id_seq'::regclass);


--
-- Name: service_prices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_prices ALTER COLUMN id SET DEFAULT nextval('public.service_prices_id_seq'::regclass);


--
-- Name: shift_schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_schedule ALTER COLUMN id SET DEFAULT nextval('public.shift_schedule_id_seq'::regclass);


--
-- Name: supplier id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);


--
-- Name: supplier_order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_order_items ALTER COLUMN id SET DEFAULT nextval('public.supplier_order_items_id_seq'::regclass);


--
-- Name: user_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_logs ALTER COLUMN id SET DEFAULT nextval('public.user_logs_id_seq'::regclass);


--
-- Name: car_client car_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_client
    ADD CONSTRAINT car_client_pkey PRIMARY KEY (car_id, client_id);


--
-- Name: car_model car_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_model
    ADD CONSTRAINT car_model_pkey PRIMARY KEY (id);


--
-- Name: car car_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (id);


--
-- Name: client_order_items client_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_items
    ADD CONSTRAINT client_order_items_pkey PRIMARY KEY (id);


--
-- Name: client_order client_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order
    ADD CONSTRAINT client_order_pkey PRIMARY KEY (id);


--
-- Name: client_order_services client_order_services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_services
    ADD CONSTRAINT client_order_services_pkey PRIMARY KEY (id);


--
-- Name: client_order_status_log client_order_status_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_status_log
    ADD CONSTRAINT client_order_status_log_pkey PRIMARY KEY (id);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee_shift_schedule employee_shift_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shift_schedule
    ADD CONSTRAINT employee_shift_schedule_pkey PRIMARY KEY (id);


--
-- Name: employee_shift_schedule employee_shift_schedule_shift_schedule_id_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shift_schedule
    ADD CONSTRAINT employee_shift_schedule_shift_schedule_id_employee_id_key UNIQUE (shift_schedule_id, employee_id);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: loyalty_rules loyalty_rules_level_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_rules
    ADD CONSTRAINT loyalty_rules_level_name_key UNIQUE (level_name);


--
-- Name: loyalty_rules loyalty_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_rules
    ADD CONSTRAINT loyalty_rules_pkey PRIMARY KEY (min_points);


--
-- Name: nomenclature nomenclature_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclature
    ADD CONSTRAINT nomenclature_pkey PRIMARY KEY (article);


--
-- Name: order_to_supplier order_to_supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_to_supplier
    ADD CONSTRAINT order_to_supplier_pkey PRIMARY KEY (id);


--
-- Name: product_prices product_prices_article_effective_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_article_effective_date_key UNIQUE (article, effective_date);


--
-- Name: product_prices product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_pkey PRIMARY KEY (id);


--
-- Name: remains_of_goods remains_of_goods_location_id_article_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remains_of_goods
    ADD CONSTRAINT remains_of_goods_location_id_article_key UNIQUE (location_id, article);


--
-- Name: remains_of_goods remains_of_goods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remains_of_goods
    ADD CONSTRAINT remains_of_goods_pkey PRIMARY KEY (id);


--
-- Name: service service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (name);


--
-- Name: service_prices service_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_prices
    ADD CONSTRAINT service_prices_pkey PRIMARY KEY (id);


--
-- Name: service_prices service_prices_service_name_effective_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_prices
    ADD CONSTRAINT service_prices_service_name_effective_date_key UNIQUE (service_name, effective_date);


--
-- Name: shift_schedule shift_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_schedule
    ADD CONSTRAINT shift_schedule_pkey PRIMARY KEY (id);


--
-- Name: supplier_order_items supplier_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_order_items
    ADD CONSTRAINT supplier_order_items_pkey PRIMARY KEY (id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: user_logs user_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_logs
    ADD CONSTRAINT user_logs_pkey PRIMARY KEY (id);


--
-- Name: idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx ON public.car USING btree (engine_volume);


--
-- Name: idx_fearues_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fearues_gin ON public.car USING gin (features);


--
-- Name: idx_full_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_full_name ON public.client USING btree (full_name);


--
-- Name: idx_location_gist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_location_gist ON public.supplier USING gist (location);


--
-- Name: idx_registration_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_registration_date ON public.supplier USING btree (registration_date);


--
-- Name: idx_tags_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tags_gin ON public.supplier USING gist (to_tsvector('russian'::regconfig, description));


--
-- Name: idx_vin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vin ON public.car USING btree (vin);


--
-- Name: client_order change_client_order_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER change_client_order_status AFTER UPDATE ON public.client_order FOR EACH ROW EXECUTE FUNCTION public.log_client_order_status();


--
-- Name: client_order check_max_created_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_max_created_orders AFTER INSERT OR UPDATE ON public.client_order FOR EACH STATEMENT EXECUTE FUNCTION public.check_max_created_orders();


--
-- Name: client_order validate_client_order; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_client_order BEFORE INSERT OR UPDATE ON public.client_order FOR EACH ROW EXECUTE FUNCTION public.check_is_clients_car();


--
-- Name: car_client car_client_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_client
    ADD CONSTRAINT car_client_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.car(id);


--
-- Name: car_client car_client_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_client
    ADD CONSTRAINT car_client_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: car car_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.car_model(id);


--
-- Name: client_order client_order_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order
    ADD CONSTRAINT client_order_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id);


--
-- Name: client_order client_order_id_car_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order
    ADD CONSTRAINT client_order_id_car_fkey FOREIGN KEY (id_car) REFERENCES public.car(id);


--
-- Name: client_order client_order_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order
    ADD CONSTRAINT client_order_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id);


--
-- Name: client_order client_order_id_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order
    ADD CONSTRAINT client_order_id_location_fkey FOREIGN KEY (id_location) REFERENCES public.location(id);


--
-- Name: client_order_items client_order_items_id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_items
    ADD CONSTRAINT client_order_items_id_order_fkey FOREIGN KEY (id_order) REFERENCES public.client_order(id);


--
-- Name: client_order_items client_order_items_product_price_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_items
    ADD CONSTRAINT client_order_items_product_price_id_fkey FOREIGN KEY (product_price_id) REFERENCES public.product_prices(id);


--
-- Name: client_order_services client_order_services_id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_services
    ADD CONSTRAINT client_order_services_id_order_fkey FOREIGN KEY (id_order) REFERENCES public.client_order(id);


--
-- Name: client_order_services client_order_services_service_price_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_services
    ADD CONSTRAINT client_order_services_service_price_id_fkey FOREIGN KEY (service_price_id) REFERENCES public.service_prices(id);


--
-- Name: client_order_status_log client_order_status_log_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_order_status_log
    ADD CONSTRAINT client_order_status_log_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.client_order(id);


--
-- Name: employee employee_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(id);


--
-- Name: employee_shift_schedule employee_shift_schedule_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shift_schedule
    ADD CONSTRAINT employee_shift_schedule_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id);


--
-- Name: employee_shift_schedule employee_shift_schedule_shift_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shift_schedule
    ADD CONSTRAINT employee_shift_schedule_shift_schedule_id_fkey FOREIGN KEY (shift_schedule_id) REFERENCES public.shift_schedule(id);


--
-- Name: nomenclature nomenclature_id_supplier_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclature
    ADD CONSTRAINT nomenclature_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES public.supplier(id);


--
-- Name: order_to_supplier order_to_supplier_id_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_to_supplier
    ADD CONSTRAINT order_to_supplier_id_location_fkey FOREIGN KEY (id_location) REFERENCES public.location(id);


--
-- Name: order_to_supplier order_to_supplier_id_supplier_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_to_supplier
    ADD CONSTRAINT order_to_supplier_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES public.supplier(id);


--
-- Name: product_prices product_prices_article_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_article_fkey FOREIGN KEY (article) REFERENCES public.nomenclature(article);


--
-- Name: remains_of_goods remains_of_goods_article_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remains_of_goods
    ADD CONSTRAINT remains_of_goods_article_fkey FOREIGN KEY (article) REFERENCES public.nomenclature(article);


--
-- Name: remains_of_goods remains_of_goods_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remains_of_goods
    ADD CONSTRAINT remains_of_goods_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(id);


--
-- Name: service_prices service_prices_service_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_prices
    ADD CONSTRAINT service_prices_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(name);


--
-- Name: shift_schedule shift_schedule_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_schedule
    ADD CONSTRAINT shift_schedule_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(id);


--
-- Name: supplier_order_items supplier_order_items_article_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_order_items
    ADD CONSTRAINT supplier_order_items_article_fkey FOREIGN KEY (article) REFERENCES public.nomenclature(article);


--
-- Name: supplier_order_items supplier_order_items_id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_order_items
    ADD CONSTRAINT supplier_order_items_id_order_fkey FOREIGN KEY (id_order) REFERENCES public.order_to_supplier(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO client_dev;
GRANT USAGE ON SCHEMA public TO watcher;
GRANT USAGE ON SCHEMA public TO killer;


--
-- Name: TABLE car; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.car TO watcher;
GRANT DELETE ON TABLE public.car TO killer;


--
-- Name: TABLE car_client; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.car_client TO watcher;
GRANT DELETE ON TABLE public.car_client TO killer;


--
-- Name: TABLE car_model; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.car_model TO watcher;
GRANT DELETE ON TABLE public.car_model TO killer;


--
-- Name: TABLE client; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.client TO client_dev;
GRANT SELECT ON TABLE public.client TO watcher;
GRANT DELETE ON TABLE public.client TO killer;


--
-- Name: TABLE client_order; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.client_order TO watcher;
GRANT DELETE ON TABLE public.client_order TO killer;


--
-- Name: TABLE client_order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.client_order_items TO watcher;
GRANT DELETE ON TABLE public.client_order_items TO killer;


--
-- Name: TABLE client_order_services; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.client_order_services TO watcher;
GRANT DELETE ON TABLE public.client_order_services TO killer;


--
-- Name: TABLE client_order_status_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.client_order_status_log TO watcher;
GRANT DELETE ON TABLE public.client_order_status_log TO killer;


--
-- Name: TABLE employee; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.employee TO watcher;
GRANT DELETE ON TABLE public.employee TO killer;


--
-- Name: TABLE employee_shift_schedule; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.employee_shift_schedule TO watcher;
GRANT DELETE ON TABLE public.employee_shift_schedule TO killer;


--
-- Name: TABLE location; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.location TO watcher;
GRANT DELETE ON TABLE public.location TO killer;


--
-- Name: TABLE loyalty_rules; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.loyalty_rules TO watcher;
GRANT DELETE ON TABLE public.loyalty_rules TO killer;


--
-- Name: TABLE nomenclature; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.nomenclature TO watcher;
GRANT DELETE ON TABLE public.nomenclature TO killer;


--
-- Name: TABLE order_to_supplier; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.order_to_supplier TO watcher;
GRANT DELETE ON TABLE public.order_to_supplier TO killer;


--
-- Name: TABLE product_prices; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.product_prices TO watcher;
GRANT DELETE ON TABLE public.product_prices TO killer;


--
-- Name: TABLE remains_of_goods; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.remains_of_goods TO watcher;
GRANT DELETE ON TABLE public.remains_of_goods TO killer;


--
-- Name: TABLE service; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.service TO watcher;
GRANT DELETE ON TABLE public.service TO killer;


--
-- Name: TABLE service_prices; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.service_prices TO watcher;
GRANT DELETE ON TABLE public.service_prices TO killer;


--
-- Name: TABLE shift_schedule; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.shift_schedule TO watcher;
GRANT DELETE ON TABLE public.shift_schedule TO killer;


--
-- Name: TABLE supplier; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.supplier TO watcher;
GRANT DELETE ON TABLE public.supplier TO killer;


--
-- Name: TABLE supplier_order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.supplier_order_items TO watcher;
GRANT DELETE ON TABLE public.supplier_order_items TO killer;


--
-- PostgreSQL database dump complete
--

\unrestrict RXgbWjMTTMSpMRn3G7mdj7ZzWlhudqfxLdbGXikamzNrHR4obvHM4zZUe7dNyPU

