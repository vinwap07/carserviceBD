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

CREATE TABLE client_order_status_log (
    id SERIAL PRIMARY KEY, 
    order_id INTEGER NOT NULL, 
    status order_status NOT NULL,
    FOREIGN KEY (order_id) REFERENCES client_order(id)
);