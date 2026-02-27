-- Database: carservice
CREATE TYPE employee_status AS ENUM ('работает', 'уволен', 'отпуск');
CREATE TYPE supplier_order_status AS ENUM ('формируется', 'отправлен', 'доставлен', 'отменен');
CREATE TYPE order_priority AS ENUM ('низкий', 'обычный', 'высокий', 'срочный');
CREATE TYPE order_status AS ENUM ('создан', 'в работе', 'выполнен', 'отменен');

CREATE TABLE car_model (
  id serial PRIMARY KEY,
  model_name varchar(50) NOT NULL,
  brand_name varchar(50) NOT NULL
);

CREATE TABLE car (
  id serial PRIMARY KEY,
  vin varchar(17) NOT NULL UNIQUE,
  year integer NOT NULL CHECK (year >= 1990 AND year <= EXTRACT(year FROM CURRENT_DATE)),
  license_plate varchar(15),
  color varchar(30),
  model_id integer NOT NULL REFERENCES car_model(id)
);

CREATE TABLE client (
  id serial PRIMARY KEY,
  full_name varchar(100) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  email varchar(100),
  driver_license varchar(20) UNIQUE
);

CREATE TABLE car_client (
  car_id integer NOT NULL REFERENCES car(id),
  client_id integer NOT NULL REFERENCES client(id),
  PRIMARY KEY (car_id, client_id)
);

CREATE TABLE location (
  id serial PRIMARY KEY,
  address varchar(200) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  working_hours varchar(50) NOT NULL
);

CREATE TABLE employee (
  id serial PRIMARY KEY,
  position varchar(50) NOT NULL,
  location_id integer NOT NULL REFERENCES location(id),
  status employee_status NOT NULL,
  full_name varchar(100) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  hire_date date NOT NULL
);

CREATE TABLE shift_schedule (
  id serial PRIMARY KEY,
  location_id integer NOT NULL REFERENCES location(id),
  shift_date date NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL
);

CREATE TABLE employee_shift_schedule (
  id serial PRIMARY KEY,
  shift_schedule_id integer NOT NULL REFERENCES shift_schedule(id),
  employee_id integer NOT NULL REFERENCES employee(id),
  UNIQUE (shift_schedule_id, employee_id)
);