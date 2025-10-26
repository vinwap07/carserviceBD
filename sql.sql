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

CREATE TABLE loyalty_card (
  card_number serial PRIMARY KEY,
  id_client integer NOT NULL UNIQUE REFERENCES client(id),
  registration_date date DEFAULT CURRENT_DATE NOT NULL,
  last_visit_date date,
  points_balance integer DEFAULT 0 NOT NULL
);

CREATE TABLE loyalty_rules (
  min_points integer PRIMARY KEY,
  discount_percent numeric(5,2) NOT NULL CHECK (discount_percent BETWEEN 0 AND 100),
  level_name varchar(50) NOT NULL UNIQUE
);

CREATE TABLE supplier (
  id serial PRIMARY KEY,
  company_name varchar(200) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  email varchar(100),
  bank_account varchar(20) NOT NULL
);

CREATE TABLE nomenclature (
  article varchar(30) PRIMARY KEY,
  name varchar(200) NOT NULL,
  id_supplier integer NOT NULL REFERENCES supplier(id)
);

CREATE TABLE product_prices (
  id serial PRIMARY KEY,
  article varchar(30) NOT NULL REFERENCES nomenclature(article),
  price integer NOT NULL CHECK (price > 0),
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  UNIQUE (article, effective_date)
);

CREATE TABLE remains_of_goods (
  id serial PRIMARY KEY,
  location_id integer NOT NULL REFERENCES location(id),
  article varchar(30) NOT NULL REFERENCES nomenclature(article),
  quantity integer NOT NULL CHECK (quantity >= 0),
  UNIQUE (location_id, article)
);

CREATE TABLE order_to_supplier (
  id serial PRIMARY KEY,
  id_supplier integer NOT NULL REFERENCES supplier(id),
  id_location integer NOT NULL REFERENCES location(id),
  total_cost integer CHECK (total_cost >= 0),
  status supplier_order_status DEFAULT 'формируется' NOT NULL,
  created_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  expected_delivery_date date
);

CREATE TABLE supplier_order_items (
  id serial PRIMARY KEY,
  id_order integer NOT NULL REFERENCES order_to_supplier(id),
  article varchar(30) NOT NULL REFERENCES nomenclature(article),
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price integer NOT NULL CHECK (unit_price > 0),
  total_price integer GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE service (
  name varchar(100) PRIMARY KEY,
  base_price integer NOT NULL CHECK (base_price > 0),
  lead_time integer NOT NULL CHECK (lead_time > 0)
);

CREATE TABLE service_prices (
  id serial PRIMARY KEY,
  service_name varchar(100) NOT NULL REFERENCES service(name),
  price integer NOT NULL CHECK (price > 0),
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  UNIQUE (service_name, effective_date)
);

CREATE TABLE client_order (
  id serial PRIMARY KEY,
  id_client integer NOT NULL REFERENCES client(id),
  id_car integer NOT NULL REFERENCES car(id),
  id_location integer NOT NULL REFERENCES location(id),
  employee_id integer NOT NULL REFERENCES employee(id),
  created_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  total_amount integer NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  status order_status DEFAULT 'создан' NOT NULL,
  completion_date timestamp,
  notes text,
  priority order_priority DEFAULT 'обычный' NOT NULL,
  CHECK (completion_date IS NULL OR completion_date >= created_date)
);

CREATE TABLE client_order_items (
  id serial PRIMARY KEY,
  id_order integer NOT NULL REFERENCES client_order(id),
  product_price_id integer NOT NULL REFERENCES product_prices(id),
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price integer NOT NULL CHECK (unit_price > 0),
  total_price integer GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE client_order_services (
  id serial PRIMARY KEY,
  id_order integer NOT NULL REFERENCES client_order(id),
  service_price_id integer NOT NULL REFERENCES service_prices(id),
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price integer NOT NULL CHECK (unit_price > 0),
  total_price integer GENERATED ALWAYS AS (quantity * unit_price) STORED
);




SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';




-- Заполнение таблицы car_model
INSERT INTO car_model (model_name, brand_name) VALUES
('Camry', 'Toyota'),
('Corolla', 'Toyota'),
('Civic', 'Honda'),
('Accord', 'Honda'),
('X5', 'BMW'),
('3 Series', 'BMW'),
('Focus', 'Ford'),
('Mondeo', 'Ford'),
('Logan', 'Renault'),
('Sandero', 'Renault');

-- Заполнение таблицы car
INSERT INTO car (vin, year, license_plate, color, model_id) VALUES
('JTDKN3DU4A1234567', 2020, 'А123ВС777', 'Черный', 1),
('2HGES165X8H543210', 2018, 'Е456КХ777', 'Белый', 3),
('WBAFR7C56BC654321', 2021, 'О789ТТ777', 'Синий', 5),
('VF1LCD10345678901', 2019, 'У321ММ777', 'Красный', 9),
('ZCFC75F2005678901', 2022, 'Р555АА777', 'Серый', 2),
('1G1ZB5ST6GF123456', 2017, 'Х987НН777', 'Зеленый', 7),
('JM1BL1SF8A1234987', 2020, 'С111СС777', 'Черный', 4),
('WVWZZZ1KZ8W345678', 2018, 'М222ММ777', 'Белый', 6),
('VF3WC9FPC12345678', 2021, 'К333КК777', 'Серебристый', 10),
('TMBJJ7NP3B3456789', 2019, 'В444ВВ777', 'Синий', 8);

-- Заполнение таблицы client
INSERT INTO client (full_name, phone_number, email, driver_license) VALUES
('Иванов Петр Сергеевич', '+79161234567', 'ivanov@mail.ru', '77АВ123456'),
('Смирнова Анна Владимировна', '+79162345678', 'smirnova@gmail.com', '77ВС654321'),
('Петров Алексей Иванович', '+79163456789', 'petrov@yandex.ru', '77ЕК789012'),
('Козлова Мария Дмитриевна', '+79164567890', 'kozlova@mail.ru', '77ММ345678'),
('Сидоров Дмитрий Петрович', '+79165678901', 'sidorov@gmail.com', '77НН901234'),
('Федорова Елена Александровна', '+79166789012', 'fedorova@yandex.ru', '77ОО567890'),
('Николаев Сергей Викторович', '+79167890123', 'nikolaev@mail.ru', '77РР123789'),
('Орлова Ольга Игоревна', '+79168901234', 'orlova@gmail.com', '77СС456123'),
('Васильев Андрей Николаевич', '+79169012345', 'vasilev@yandex.ru', '77ТТ789456'),
('Павлова Ирина Сергеевна', '+79160123456', 'pavlova@mail.ru', '77УУ321654');

-- Заполнение таблицы car_client
INSERT INTO car_client (car_id, client_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- Заполнение таблицы location
INSERT INTO location (address, phone_number, working_hours) VALUES
('ул. Ленина, 25, Москва', '+74951234567', '09:00-21:00'),
('пр. Мира, 15, Санкт-Петербург', '+78122456789', '08:00-20:00'),
('ул. Гагарина, 8, Казань', '+78432567890', '09:00-19:00'),
('ул. Кирова, 33, Екатеринбург', '+73436789012', '08:00-20:00'),
('пр. Победы, 12, Новосибирск', '+73834567890', '09:00-21:00');

-- Заполнение таблицы employee
INSERT INTO employee (position, location_id, status, full_name, phone_number, hire_date) VALUES
('Менеджер', 1, 'работает', 'Семенов Артем Владимирович', '+79161112233', '2020-03-15'),
('Механик', 1, 'работает', 'Григорьев Максим Олегович', '+79162223344', '2019-07-20'),
('Автослесарь', 1, 'отпуск', 'Тарасов Иван Сергеевич', '+79163334455', '2021-05-10'),
('Менеджер', 2, 'работает', 'Белова Анастасия Петровна', '+79164445566', '2020-11-03'),
('Механик', 2, 'работает', 'Киселев Денис Андреевич', '+79165556677', '2018-09-12'),
('Автослесарь', 2, 'работает', 'Морозов Павел Викторович', '+79166667788', '2022-01-25'),
('Менеджер', 3, 'работает', 'Зайцева Виктория Игоревна', '+79167778899', '2021-08-14'),
('Механик', 3, 'уволен', 'Соколов Роман Дмитриевич', '+79168889900', '2019-04-30'),
('Автослесарь', 3, 'работает', 'Волков Александр Николаевич', '+79169990011', '2020-12-01'),
('Менеджер', 4, 'работает', 'Лебедева Марина Алексеевна', '+79161001122', '2022-03-20');

-- Заполнение таблицы shift_schedule
INSERT INTO shift_schedule (location_id, shift_date, start_time, end_time) VALUES
(1, '2024-01-15', '09:00', '18:00'),
(1, '2024-01-15', '12:00', '21:00'),
(2, '2024-01-15', '08:00', '17:00'),
(1, '2024-01-16', '09:00', '18:00'),
(2, '2024-01-16', '08:00', '17:00');

-- Заполнение таблицы employee_shift_schedule
INSERT INTO employee_shift_schedule (shift_schedule_id, employee_id) VALUES
(1, 1), (1, 2), (2, 3), (3, 4), (3, 5),
(4, 1), (4, 2), (5, 4), (5, 6);

-- Заполнение таблицы loyalty_card
INSERT INTO loyalty_card (card_number, id_client, registration_date, last_visit_date, points_balance) VALUES
(1001, 1, '2023-01-15', '2024-01-10', 1500),
(1002, 2, '2023-02-20', '2024-01-12', 800),
(1003, 3, '2023-03-10', '2024-01-08', 2500),
(1004, 4, '2023-04-05', '2023-12-20', 300),
(1005, 5, '2023-05-12', '2024-01-05', 1200),
(1006, 6, '2023-06-18', '2024-01-11', 600),
(1007, 7, '2023-07-22', '2023-11-15', 1800),
(1008, 8, '2023-08-30', '2024-01-09', 900),
(1009, 9, '2023-09-14', '2024-01-07', 2100),
(1010, 10, '2023-10-25', '2024-01-13', 400);

-- Заполнение таблицы loyalty_rules
INSERT INTO loyalty_rules (min_points, discount_percent, level_name) VALUES
(0, 0.00, 'Новичок'),
(500, 5.00, 'Бронза'),
(1000, 7.50, 'Серебро'),
(2000, 10.00, 'Золото'),
(5000, 15.00, 'Платина');

-- Заполнение таблицы supplier
INSERT INTO supplier (company_name, phone_number, email, bank_account) VALUES
('АвтоДеталь Трейд', '+79167778899', 'info@avtodetal.ru', '40702810500000001234'),
('Масла и Фильтры ООО', '+79168889900', 'sales@masla-filtry.ru', '40702810600000005678'),
('Шиномонтаж Сервис', '+79169990011', 'office@shinamontag.ru', '40702810700000009012'),
('Автоэлектрика Лтд', '+79161001122', 'order@avtoelectro.ru', '40702810800000003456'),
('Кузовные детали ИП', '+79161112233', 'kp@kuzovdetali.ru', '40702810900000007890');

-- Заполнение таблицы nomenclature
INSERT INTO nomenclature (article, name, id_supplier) VALUES
('FILT12345', 'Масляный фильтр Toyota', 2),
('OIL56789', 'Моторное масло 5W-30 4л', 2),
('BRAKE987', 'Тормозные колодки передние', 1),
('SPARK456', 'Свечи зажигания NGK', 4),
('BATT7890', 'Аккумулятор 60Ач', 4),
('TIRE1234', 'Летняя шина 205/55 R16', 3),
('TIRE5678', 'Зимняя шина 205/55 R16', 3),
('OIL32165', 'Трансмиссионное масло 75W-90', 2),
('FILT9876', 'Воздушный фильтр', 2),
('LAMP4567', 'Лампа ближнего света H7', 4);

-- Заполнение таблицы product_prices
INSERT INTO product_prices (article, price, effective_date) VALUES
('FILT12345', 120000, '2024-01-01'),
('OIL56789', 250000, '2024-01-01'),
('BRAKE987', 450000, '2024-01-01'),
('SPARK456', 80000, '2024-01-01'),
('BATT7890', 550000, '2024-01-01'),
('TIRE1234', 400000, '2024-01-01'),
('TIRE5678', 480000, '2024-01-01'),
('OIL32165', 180000, '2024-01-01'),
('FILT9876', 90000, '2024-01-01'),
('LAMP4567', 60000, '2024-01-01');

-- Заполнение таблицы remains_of_goods
INSERT INTO remains_of_goods (location_id, article, quantity) VALUES
(1, 'FILT12345', 15),
(1, 'OIL56789', 8),
(1, 'BRAKE987', 5),
(1, 'SPARK456', 20),
(2, 'FILT12345', 10),
(2, 'OIL56789', 12),
(2, 'BATT7890', 3),
(2, 'TIRE1234', 8),
(3, 'OIL56789', 6),
(3, 'TIRE5678', 4);

-- Заполнение таблицы order_to_supplier
INSERT INTO order_to_supplier (id_supplier, id_location, total_cost, status, created_date, expected_delivery_date) VALUES
(1, 1, 1500000, 'доставлен', '2024-01-05 10:00:00', '2024-01-10'),
(2, 1, 800000, 'отправлен', '2024-01-10 14:30:00', '2024-01-17'),
(3, 2, 3200000, 'формируется', '2024-01-12 09:15:00', '2024-01-20'),
(4, 3, 450000, 'доставлен', '2024-01-08 11:20:00', '2024-01-12'),
(2, 2, 1200000, 'отправлен', '2024-01-11 16:45:00', '2024-01-18');

-- Заполнение таблицы supplier_order_items
INSERT INTO supplier_order_items (id_order, article, quantity, unit_price) VALUES
(1, 'BRAKE987', 3, 450000),
(1, 'SPARK456', 10, 80000),
(2, 'OIL56789', 3, 250000),
(2, 'FILT12345', 5, 120000),
(3, 'TIRE1234', 8, 400000),
(4, 'LAMP4567', 5, 60000),
(4, 'SPARK456', 3, 80000),
(5, 'OIL56789', 4, 250000),
(5, 'FILT9876', 10, 90000);

-- Заполнение таблицы service
INSERT INTO service (name, base_price, lead_time) VALUES
('Замена масла', 50000, 1),
('Замена фильтров', 30000, 1),
('Замена тормозных колодок', 80000, 2),
('Замена свечей зажигания', 25000, 1),
('Замена аккумулятора', 15000, 1),
('Шиномонтаж', 40000, 2),
('Развал-схождение', 60000, 2),
('Диагностика двигателя', 35000, 1),
('Замена ламп', 10000, 1),
('Полное ТО', 120000, 3);

-- Заполнение таблицы service_prices
INSERT INTO service_prices (service_name, price, effective_date) VALUES
('Замена масла', 50000, '2024-01-01'),
('Замена фильтров', 30000, '2024-01-01'),
('Замена тормозных колодок', 80000, '2024-01-01'),
('Замена свечей зажигания', 25000, '2024-01-01'),
('Замена аккумулятора', 15000, '2024-01-01'),
('Шиномонтаж', 40000, '2024-01-01'),
('Развал-схождение', 60000, '2024-01-01'),
('Диагностика двигателя', 35000, '2024-01-01'),
('Замена ламп', 10000, '2024-01-01'),
('Полное ТО', 120000, '2024-01-01');

-- Заполнение таблицы client_order
INSERT INTO client_order (id_client, id_car, id_location, employee_id, total_amount, status, created_date, completion_date, notes, priority) VALUES
(1, 1, 1, 1, 420000, 'выполнен', '2024-01-10 09:30:00', '2024-01-10 14:00:00', 'Клиент просил проверить тормозную систему', 'обычный'),
(2, 2, 1, 1, 300000, 'в работе', '2024-01-12 10:15:00', NULL, 'Срочная замена масла', 'высокий'),
(3, 3, 2, 4, 850000, 'создан', '2024-01-13 11:20:00', NULL, 'Полное ТО + замена фильтров', 'обычный'),
(4, 4, 1, 1, 150000, 'выполнен', '2024-01-08 14:45:00', '2024-01-08 16:30:00', 'Замена лампы ближнего света', 'низкий'),
(5, 5, 2, 4, 600000, 'в работе', '2024-01-14 08:30:00', NULL, 'Шиномонтаж + развал-схождение', 'обычный');

-- Заполнение таблицы client_order_items
INSERT INTO client_order_items (id_order, product_price_id, quantity, unit_price) VALUES
(1, 1, 1, 120000),  -- Масляный фильтр
(1, 2, 1, 250000),  -- Моторное масло
(2, 2, 1, 250000),  -- Моторное масло
(3, 1, 1, 120000),  -- Масляный фильтр
(3, 9, 1, 90000),   -- Воздушный фильтр
(4, 10, 1, 60000),  -- Лампа
(5, 6, 4, 400000);  -- Летние шины

-- Заполнение таблицы client_order_services
INSERT INTO client_order_services (id_order, service_price_id, quantity, unit_price) VALUES
(1, 1, 1, 50000),   -- Замена масла
(2, 1, 1, 50000),   -- Замена масла
(3, 10, 1, 120000), -- Полное ТО
(3, 2, 1, 30000),   -- Замена фильтров
(4, 9, 1, 10000),   -- Замена ламп
(5, 6, 1, 40000),   -- Шиномонтаж
(5, 7, 1, 60000);   -- Развал-схождение




--select_join_queries.md
--1.1
SELECT *
FROM employee;

--2.2
SELECT full_name, phone_number
FROM client;

--4.1
SELECT id, total_amount, total_amount * 1.2 AS "Цена с НДС"
FROM client_order;

--5.2
SELECT 
    id,
    full_name,
    hire_date,
    ROUND((CURRENT_DATE - hire_date) / 365.25, 2) AS "Стаж (лет с точностью до сотых)"
FROM employee;

--7.1
SELECT car_model.brand_name, car_model.model_name, car.color
FROM car JOIN car_model 
ON car.model_id = car_model.id
WHERE car.color = 'Черный';

--8.2
SELECT id, total_amount, priority, status
FROM client_order
WHERE total_amount > 500000 OR priority IN ('высокий', 'срочный');

--10.1
SELECT id, priority, created_date, status
FROM client_order
ORDER BY CASE
WHEN priority = 'срочный' THEN 1
WHEN priority = 'высокий' THEN 2
WHEN priority = 'обычный' THEN 3
WHEN priority = 'низкий' THEN 4
END;

--11.2
SELECT name, base_price
FROM service
WHERE name LIKE 'Замен%';

--13.1
SELECT id, company_name, bank_account
FROM supplier
LIMIT 4 OFFSET 1; 

--14.2
SELECT full_name AS "ФИО сотрудника", 
	shift_date AS "Рабочий день", 
	start_time AS "Начало смены", 
	end_time AS "Окончание смены",
	l.address AS "Место работы"
FROM employee 
INNER JOIN employee_shift_schedule ess ON employee.id = ess.employee_id
INNER JOIN shift_schedule ss ON ess.shift_schedule_id = ss.id
INNER JOIN location l ON ss.location_id = l.id;

--16.1
SELECT card_number, full_name, points_balance
FROM client
RIGHT JOIN loyalty_card 
ON client.id = loyalty_card.id_client;

--17.2
SELECT company_name AS "Поставщик",
    address AS "Место назначения",
    supplier.phone_number AS "Телефон поставщика",
    location.phone_number AS "Телефон автосервиса"
FROM supplier
CROSS JOIN location;




-- aggregate_group_queries.md
-- 1.1
SELECT COUNT(*) as number_of_completed_orders
FROM client_order
WHERE status = 'выполнен';

--2.2
SELECT SUM(total_cost) AS total_supplier_orders_cost
FROM order_to_supplier os
INNER JOIN location l ON os.id_location = l.id
WHERE address = 'ул. Ленина, 25, Москва';

--4.1
SELECT MIN(registration_date) AS earliest_registration
FROM loyalty_card;

--5.2
SELECT MAX(points_balance) AS max_points
FROM loyalty_card;

--7.1
SELECT 
    COUNT(*) AS orders_count,
    SUM(total_amount) AS total_sum,
    ROUND(AVG(total_amount), 2) AS average_amount,
    MIN(total_amount) AS min_amount,
    MAX(total_amount) AS max_amount
FROM client_order;

--8.2
SELECT priority, COUNT(*) AS orders_count
FROM client_order
GROUP BY priority;

--10.1
SELECT position, status, COUNT(*) AS employees_count
FROM employee
GROUP BY
	GROUPING SETS ((position, status), (position), (status), ())
ORDER BY position, status;

--11.2
SELECT brand_name, model_name, COUNT(*) AS cars_count
FROM car c
INNER JOIN car_model cm ON c.model_id = cm.id
GROUP BY ROLLUP (brand_name, model_name)
ORDER BY brand_name, model_name;