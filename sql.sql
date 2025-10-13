-- Database: carservice
-- Добавьте эти типы перед созданием таблиц
CREATE TYPE employee_status AS ENUM ('active', 'inactive', 'vacation');
CREATE TYPE supplier_order_status AS ENUM ('формируется', 'отправлен', 'доставлен', 'отменен');

CREATE TABLE car_model (
  id serial4 NOT NULL,
  model_name varchar NOT NULL,
  brand_name varchar(20) NULL,
  CONSTRAINT car_model_pkey PRIMARY KEY (id)
);

CREATE TABLE car (
  id serial4 NOT NULL,
  vin varchar(17) NOT NULL,
  brand varchar(50) NOT NULL,
  model varchar(50) NOT NULL,
  "year" int4 NULL,
  license_plate varchar(15) NULL,
  color varchar(30) NULL,
  model_id int4 NULL,
  CONSTRAINT check_year CHECK (((year >= 1990) AND ((year)::numeric <= EXTRACT(year FROM CURRENT_DATE)))),
  CONSTRAINT client_car_pkey PRIMARY KEY (id),
  CONSTRAINT client_car_vin_key UNIQUE (vin)
);


-- public.car внешние включи

ALTER TABLE car ADD CONSTRAINT fk_car_model FOREIGN KEY (model_id) REFERENCES car_model(id);

CREATE TABLE client (
  id serial4 NOT NULL,
  full_name varchar(100) NOT NULL,
  phone_number varchar(20) NOT NULL,
  email varchar(100) NULL,
  driver_license varchar(20) NULL,
  CONSTRAINT check_phone_format CHECK (((phone_number)::text ~ '^\+?[0-9]{10,15}$'::text)),
  CONSTRAINT client_driver_license_key UNIQUE (driver_license),
  CONSTRAINT client_pkey PRIMARY KEY (id)
);

CREATE TABLE car_client (
  car_id int4 NOT NULL,
  client_id int4 NOT NULL,
  CONSTRAINT car_client_pkey PRIMARY KEY (car_id, client_id)
);


-- public.car_client внешние включи

ALTER TABLE car_client ADD CONSTRAINT car_client_car_id_fkey FOREIGN KEY (car_id) REFERENCES car(id);
ALTER TABLE car_client ADD CONSTRAINT car_client_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(id);

CREATE TABLE location (
  id serial4 NOT NULL,
  address varchar(200) NOT NULL,
  phone_number varchar(12) NULL,
  working_hours varchar(11) NULL,
  CONSTRAINT location_pkey PRIMARY KEY (id)
);

CREATE TABLE employee (
  id serial4 NOT NULL,
  "position" varchar NOT NULL,
  location_id int4 NOT NULL,
  status employee_status NOT NULL,
  full_name varchar(50) NOT NULL,
  phone_number varchar(12) NOT NULL,
  hire_date date NOT NULL,
  CONSTRAINT employee_pkey PRIMARY KEY (id)
);


-- public.employee внешние включи

ALTER TABLE employee ADD CONSTRAINT employee_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);

CREATE TABLE shift_schelude (
  id serial4 NOT NULL,
  location_id int4 NOT NULL,
  shift_date date NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  CONSTRAINT shift_schelude_pkey PRIMARY KEY (id)
);


-- public.shift_schelude внешние включи

ALTER TABLE shift_schelude ADD CONSTRAINT shift_schelude_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);

CREATE TABLE public.employee_shift_schelude (
  id serial4 NOT NULL,
  shift_schelude_id int4 NULL,
  employee_id int4 NULL,
  CONSTRAINT employee_shift_schelude_pkey PRIMARY KEY (id)
);


-- public.employee_shift_schelude внешние включи

ALTER TABLE employee_shift_schelude ADD CONSTRAINT employee_shift_schelude_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);
ALTER TABLE employee_shift_schelude ADD CONSTRAINT employee_shift_schelude_shift_schelude_id_fkey FOREIGN KEY (shift_schelude_id) REFERENCES shift_schelude(id);

CREATE TABLE loyalty_card (
  card_number int4 NOT NULL,
  id_client int4 NOT NULL,
  registration_date date DEFAULT CURRENT_DATE NULL,
  last_visit_date date NULL,
  points_balance int4 DEFAULT 0 NULL,
  CONSTRAINT client_card_id_client_key UNIQUE (id_client),
  CONSTRAINT client_card_pkey PRIMARY KEY (card_number)
);


-- public.loyalty_card внешние включи

ALTER TABLE loyalty_card ADD CONSTRAINT client_card_id_client_fkey FOREIGN KEY (id_client) REFERENCES client(id);

CREATE TABLE loyalty_rules (
  min_points int4 NOT NULL,
  discount_percent numeric(5, 2) NOT NULL,
  level_name varchar NOT NULL,
  CONSTRAINT loyalty_rules_pkey PRIMARY KEY (min_points)
);

CREATE TABLE supplier (
  id serial4 NOT NULL,
  company_name varchar(200) NOT NULL,
  phone_number varchar(11) NULL,
  email varchar(100) NULL,
  bank_account varchar(20) NULL,
  CONSTRAINT supplier_pkey PRIMARY KEY (id)
);



CREATE TABLE nomenclature (
  article varchar(30) NOT NULL,
  "name" varchar(200) NOT NULL,
  "cost" numeric(10, 2) NOT NULL,
  id_supplier int4 NOT NULL,
  CONSTRAINT nomenclature_pkey PRIMARY KEY (article)
);


-- public.nomenclature внешние включи

ALTER TABLE nomenclature ADD CONSTRAINT nomenclature_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES supplier(id);

CREATE TABLE product_prices (
  id serial4 NOT NULL,
  article varchar NOT NULL,
  price numeric(10, 2) NOT NULL,
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  CONSTRAINT product_prices_article_effective_date_key UNIQUE (article, effective_date),
  CONSTRAINT product_prices_pkey PRIMARY KEY (id)
);


-- public.product_prices внешние включи

ALTER TABLE product_prices ADD CONSTRAINT fk_service_price FOREIGN KEY (article) REFERENCES nomenclature(article);

CREATE TABLE remains_of_goods (
  id serial4 NOT NULL,
  location_id int4 NOT NULL,
  article varchar(30) NOT NULL,
  count int4 NOT NULL,
  CONSTRAINT remains_of_goods_pkey PRIMARY KEY (id)
);


-- public.remains_of_goods внешние включи

ALTER TABLE remains_of_goods ADD CONSTRAINT remains_of_goods_article_fkey FOREIGN KEY (article) REFERENCES nomenclature(article);
ALTER TABLE remains_of_goods ADD CONSTRAINT remains_of_goods_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);

CREATE TABLE order_to_supplier (
  id serial4 NOT NULL,
  id_supplier int4 NOT NULL,
  id_location int4 NOT NULL,
  total_cost numeric(10, 2) NULL,
  status public.supplier_order_status DEFAULT 'формируется'::supplier_order_status NULL,
  CONSTRAINT order_to_supplier_pkey PRIMARY KEY (id)
);


-- public.order_to_supplier внешние включи

ALTER TABLE order_to_supplier ADD CONSTRAINT order_to_supplier_id_location_fkey FOREIGN KEY (id_location) REFERENCES location(id);
ALTER TABLE order_to_supplier ADD CONSTRAINT order_to_supplier_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES supplier(id);

CREATE TABLE service (
  "name" varchar(100) NOT NULL,
  price numeric(10, 2) NOT NULL,
  lead_time int4 NULL,
  CONSTRAINT check_lead_time CHECK ((lead_time > 0)),
  CONSTRAINT service_pkey PRIMARY KEY (name)
);

CREATE TABLE public.service_prices (
  id serial4 NOT NULL,
  service_name varchar NOT NULL,
  price numeric(10, 2) NOT NULL,
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  CONSTRAINT service_prices_pkey PRIMARY KEY (id),
  CONSTRAINT service_prices_service_name_effective_date_key UNIQUE (service_name, effective_date)
);


-- public.service_prices внешние включи

ALTER TABLE service_prices ADD CONSTRAINT service_prices_service_name_fkey FOREIGN KEY (service_name) REFERENCES service("name");

CREATE TABLE supplier_order_items (
  id serial4 NOT NULL,
  id_order int4 NOT NULL,
  article varchar(30) NOT NULL,
  quantity int4 NOT NULL,
  unit_price numeric(10, 2) NOT NULL,
  total_price numeric(10, 2) GENERATED ALWAYS AS ((quantity::numeric * unit_price)) STORED NULL,
  CONSTRAINT supplier_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT supplier_order_items_quantity_check CHECK ((quantity > 0))
);


-- public.supplier_order_items внешние включи

ALTER TABLE supplier_order_items ADD CONSTRAINT supplier_order_items_article_fkey FOREIGN KEY (article) REFERENCES nomenclature(article);
ALTER TABLE supplier_order_items ADD CONSTRAINT supplier_order_items_id_order_fkey FOREIGN KEY (id_order) REFERENCES order_to_supplier(id);

CREATE TABLE client_order (
  id serial4 NOT NULL,
  id_client int4 NOT NULL,
  id_car int4 NOT NULL,
  id_location int4 NOT NULL,
  created_date timestamp DEFAULT CURRENT_TIMESTAMP NULL,
  total_amount numeric(10, 2) NULL,
  status varchar(50) DEFAULT 'создан'::character varying NULL,
  completion_date timestamp NULL,
  notes text NULL,
  priority varchar(10) DEFAULT 'обычный'::character varying NULL,
  CONSTRAINT check_order_dates CHECK (((completion_date IS NULL) OR (completion_date >= created_date))),
  CONSTRAINT client_order_pkey PRIMARY KEY (id)
);


-- public.client_order внешние включи


ALTER TABLE client_order ADD CONSTRAINT client_order_id_car_fkey FOREIGN KEY (id_car) REFERENCES car(id);
ALTER TABLE client_order ADD CONSTRAINT client_order_id_client_fkey FOREIGN KEY (id_client) REFERENCES client(id);
ALTER TABLE client_order ADD CONSTRAINT client_order_id_location_fkey FOREIGN KEY (id_location) REFERENCES location(id);

CREATE TABLE client_order_items (
  id serial4 NOT NULL,
  id_order int4 NOT NULL,
  quantity int4 NOT NULL,
  product_price_id int4 NULL,
  CONSTRAINT client_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT client_order_items_quantity_check CHECK ((quantity > 0))
);


-- public.client_order_items внешние включи

ALTER TABLE client_order_items ADD CONSTRAINT client_order_items_id_order_fkey FOREIGN KEY (id_order) REFERENCES client_order(id);
ALTER TABLE client_order_items ADD CONSTRAINT fk_product_price FOREIGN KEY (product_price_id) REFERENCES product_prices(id);

CREATE TABLE client_order_services (
  id serial4 NOT NULL,
  id_order int4 NOT NULL,
  quantity int4 DEFAULT 1 NOT NULL,
  price numeric(10, 2) NOT NULL,
  total_price numeric(10, 2) GENERATED ALWAYS AS ((quantity::numeric * price)) STORED NULL,
  service_price_id int4 NULL,
  CONSTRAINT client_order_services_pkey PRIMARY KEY (id)
);


-- public.client_order_services внешние включи

ALTER TABLE client_order_services ADD CONSTRAINT client_order_services_id_order_fkey FOREIGN KEY (id_order) REFERENCES client_order(id);
ALTER TABLE client_order_services ADD CONSTRAINT fk_service_price FOREIGN KEY (service_price_id) REFERENCES service_prices(id);



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

select * from client;

-- Заполнение таблицы car
INSERT INTO car (vin, brand, model, year, license_plate, color, model_id) VALUES
('JTDKN3DU8A1234567', 'Toyota', 'Camry', 2020, 'А123ВС77', 'Черный', 11),
('2HGFA16507H123456', 'Honda', 'Civic', 2019, 'В234ОР77', 'Белый', 13),
('WBAFR7C58BC123456', 'BMW', 'X5', 2021, 'С345ТТ77', 'Синий', 15),
('VF1LSD0F0A1234567', 'Renault', 'Logan', 2018, 'Е567КХ77', 'Серый', 19),
('1FADP3F2XXL123456', 'Ford', 'Focus', 2022, 'М789АВ77', 'Красный', 17),
('JTDKB20U187654321', 'Toyota', 'Corolla', 2021, 'Н321СА77', 'Серебристый', 12);

-- Заполнение таблицы client
INSERT INTO client (full_name, phone_number, email, driver_license) VALUES
('Иванов Иван Иванович', '+79161234567', 'ivanov@mail.ru', '77АВ123456'),
('Петров Петр Петрович', '+79262345678', 'petrov@gmail.com', '77ВС654321'),
('Сидорова Анна Сергеевна', '+79033456789', 'sidorova@yandex.ru', '77ОР789012'),
('Козлов Дмитрий Викторович', '+79564567890', 'kozlov@mail.ru', '77ТТ345678'),
('Николаева Елена Александровна', '+79975678901', 'nikolaeva@gmail.com', '77КХ901234');

-- Заполнение таблицы car_client (связь клиентов с автомобилями)
INSERT INTO car_client (car_id, client_id) VALUES
(25, 6),
(26, 7),
(27, 8),
(28, 9),
(29, 10),
(30, 6); -- У одного клиента может быть несколько авто

-- Заполнение таблицы location
INSERT INTO location (address, phone_number, working_hours) VALUES
('ул. Ленина, д. 10, Москва', '+74951234567', '09:00-21:00'),
('пр. Мира, д. 25, Москва', '+74952345678', '08:00-20:00'),
('ул. Пушкина, д. 5, Московская обл.', '+74953456789', '09:00-19:00');

-- Заполнение таблицы employee
INSERT INTO employee (position, location_id, status, full_name, phone_number, hire_date) VALUES
('Менеджер', 4, 'active', 'Смирнов Алексей Владимирович', '+79161112233', '2020-01-15'),
('Механик', 4, 'active', 'Васильев Сергей Петрович', '+79162223344', '2019-03-20'),
('Автослесарь', 4, 'active', 'Попов Игорь Николаевич', '+79163334455', '2021-06-10'),
('Менеджер', 5, 'active', 'Федорова Марина Олеговна', '+79164445566', '2020-11-05'),
('Механик', 6, 'vacation', 'Андреев Денис Сергеевич', '+79165556677', '2018-09-12');

-- Заполнение таблицы shift_schelude
INSERT INTO shift_schelude (location_id, shift_date, start_time, end_time) VALUES
(4, '2024-01-15', '09:00', '18:00'),
(4, '2024-01-15', '12:00', '21:00'),
(5, '2024-01-15', '08:00', '17:00'),
(6, '2024-01-16', '09:00', '18:00');

-- Заполнение таблицы employee_shift_schelude
INSERT INTO employee_shift_schelude (shift_schelude_id, employee_id) VALUES
(9, 11),
(9, 12),
(10, 13),
(11, 14),
(12, 11);

-- Заполнение таблицы loyalty_card
INSERT INTO loyalty_card (card_number, id_client, registration_date, last_visit_date, points_balance) VALUES
(1001, 6, '2022-03-15', '2024-01-10', 1500),
(1002, 7, '2021-11-20', '2024-01-12', 800),
(1003, 8, '2023-05-10', '2024-01-08', 250),
(1004, 9, '2020-07-03', '2023-12-20', 3200);

-- Заполнение таблицы loyalty_rules
INSERT INTO loyalty_rules (min_points, discount_percent, level_name) VALUES
(0, 0.00, 'Новичок'),
(500, 5.00, 'Бронзовый'),
(1000, 7.50, 'Серебряный'),
(2000, 10.00, 'Золотой'),
(5000, 15.00, 'Платиновый');

-- Заполнение таблицы supplier
INSERT INTO supplier (company_name, phone_number, email, bank_account) VALUES
('ООО "АвтоДеталь"', '84951230001', 'info@avtodetal.ru', '40702810100010000001'),
('ЗАО "АвтоКомплект"', '84951230002', 'sales@avtokomplekt.ru', '40702810200020000002'),
('ООО "Масла и фильтры"', '84951230003', 'order@oil-filter.ru', '40702810300030000003'),
('ИП Сергеев А.В.', '84951230004', 'sergeev@parts.ru', '40802810400040000004');

-- Заполнение таблицы nomenclature
INSERT INTO nomenclature (article, name, cost, id_supplier) VALUES
('FILT001', 'Масляный фильтр Toyota', 850.00, 1),
('FILT002', 'Воздушный фильтр Honda', 650.00, 1),
('OIL001', 'Моторное масло 5W-30 4л', 2500.00, 3),
('OIL002', 'Моторное масло 0W-20 4л', 3200.00, 3),
('BRAKE001', 'Тормозные колодки передние', 2800.00, 2),
('BRAKE002', 'Тормозные диски передние', 4500.00, 2),
('SPARK001', 'Свечи зажигания NGK', 350.00, 4),
('BATT001', 'Аккумулятор 60Ач', 5500.00, 2);

-- Заполнение таблицы product_prices
INSERT INTO product_prices (article, price, effective_date) VALUES
('FILT001', 1200.00, '2024-01-01'),
('FILT002', 950.00, '2024-01-01'),
('OIL001', 3200.00, '2024-01-01'),
('OIL002', 4100.00, '2024-01-01'),
('BRAKE001', 3800.00, '2024-01-01'),
('BRAKE002', 5800.00, '2024-01-01'),
('SPARK001', 500.00, '2024-01-01'),
('BATT001', 7200.00, '2024-01-01');

-- Заполнение таблицы remains_of_goods
INSERT INTO remains_of_goods (location_id, article, count) VALUES
(4, 'FILT001', 15),
(4, 'OIL001', 8),
(4, 'BRAKE001', 5),
(5, 'FILT002', 10),
(5, 'OIL002', 6),
(5, 'SPARK001', 20),
(6, 'BATT001', 3),
(6, 'BRAKE002', 4);

-- Заполнение таблицы order_to_supplier
INSERT INTO order_to_supplier (id_supplier, id_location, total_cost, status) VALUES
(1, 4, 25000.00, 'доставлен'),
(3, 4, 18000.00, 'отправлен'),
(2, 5, 32000.00, 'формируется');

-- Заполнение таблицы supplier_order_items
INSERT INTO supplier_order_items (id_order, article, quantity, unit_price) VALUES
(1, 'FILT001', 20, 850.00),
(1, 'FILT002', 15, 650.00),
(2, 'OIL001', 5, 2500.00),
(2, 'OIL002', 4, 3200.00),
(3, 'BRAKE001', 8, 2800.00),
(3, 'BRAKE002', 6, 4500.00);

-- Заполнение таблицы service
INSERT INTO service (name, price, lead_time) VALUES
('Замена масла и фильтра', 1500.00, 60),
('Замена тормозных колодок', 2500.00, 120),
('Замена свечей зажигания', 800.00, 45),
('Диагностика ходовой части', 2000.00, 90),
('Компьютерная диагностика', 1500.00, 30),
('Замена аккумулятора', 500.00, 20),
('Шиномонтаж (4 колеса)', 2000.00, 60);

-- Заполнение таблицы service_prices
INSERT INTO service_prices (service_name, price, effective_date) VALUES
('Замена масла и фильтра', 1500.00, '2024-01-01'),
('Замена тормозных колодок', 2500.00, '2024-01-01'),
('Замена свечей зажигания', 800.00, '2024-01-01'),
('Диагностика ходовой части', 2000.00, '2024-01-01'),
('Компьютерная диагностика', 1500.00, '2024-01-01'),
('Замена аккумулятора', 500.00, '2024-01-01'),
('Шиномонтаж (4 колеса)', 2000.00, '2024-01-01');

-- Заполнение таблицы client_order
INSERT INTO client_order (id_client, id_car, id_location, created_date, total_amount, status, completion_date, notes, priority) VALUES
(6, 25, 4, '2024-01-10 09:30:00', 5900.00, 'выполнен', '2024-01-10 12:45:00', 'Клиент просил проверить кондиционер', 'обычный'),
(7, 26, 4, '2024-01-12 10:15:00', 8200.00, 'в работе', NULL, 'Срочная замена тормозов', 'высокий'),
(8, 27, 5, '2024-01-13 11:00:00', 1500.00, 'создан', NULL, NULL, 'обычный'),
(6, 28, 4, '2024-01-14 14:20:00', 4700.00, 'выполнен', '2024-01-14 16:30:00', 'Второй автомобиль клиента', 'обычный');

-- Заполнение таблицы client_order_items
INSERT INTO client_order_items (id_order, quantity, product_price_id) VALUES
(13, 1, 1),  -- Масляный фильтр Toyota
(13, 1, 3),  -- Моторное масло 5W-30
(14, 1, 5),  -- Тормозные колодки
(14, 1, 6),  -- Тормозные диски
(15, 1, 2),  -- Воздушный фильтр Honda
(16, 1, 7),  -- Свечи зажигания
(16, 1, 3);  -- Моторное масло

select * from client_order;

-- Заполнение таблицы client_order_services
INSERT INTO client_order_services (id_order, quantity, price, service_price_id) VALUES
(13, 1, 1500.00, 1),  -- Замена масла и фильтра
(14, 1, 2500.00, 2),  -- Замена тормозных колодок
(15, 1, 1500.00, 5),  -- Компьютерная диагностика
(16, 1, 800.00, 3);   -- Замена свечей зажигания