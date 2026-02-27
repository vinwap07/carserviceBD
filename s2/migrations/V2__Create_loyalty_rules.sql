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

-- Заполнение таблицы location
INSERT INTO location (address, phone_number, working_hours) VALUES
('ул. Ленина, 25, Москва', '+74951234567', '09:00-21:00'),
('пр. Мира, 15, Санкт-Петербург', '+78122456789', '08:00-20:00'),
('ул. Гагарина, 8, Казань', '+78432567890', '09:00-19:00'),
('ул. Кирова, 33, Екатеринбург', '+73436789012', '08:00-20:00'),
('пр. Победы, 12, Новосибирск', '+73834567890', '09:00-21:00');

-- Заполнение таблицы supplier
INSERT INTO supplier (company_name, phone_number, email, bank_account) VALUES
('АвтоДеталь Трейд', '+79167778899', 'info@avtodetal.ru', '40702810500000001234'),
('Масла и Фильтры ООО', '+79168889900', 'sales@masla-filtry.ru', '40702810600000005678'),
('Шиномонтаж Сервис', '+79169990011', 'office@shinamontag.ru', '40702810700000009012'),
('Автоэлектрика Лтд', '+79161001122', 'order@avtoelectro.ru', '40702810800000003456'),
('Кузовные детали ИП', '+79161112233', 'kp@kuzovdetali.ru', '40702810900000007890');

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

-- Заполнение таблицы loyalty_rules
INSERT INTO loyalty_rules (min_points, discount_percent, level_name) VALUES
(0, 0.00, 'Новичок'),
(500, 5.00, 'Бронза'),
(1000, 7.50, 'Серебро'),
(2000, 10.00, 'Золото'),
(5000, 15.00, 'Платина');

-- Обновление последовательностей
SELECT setval('car_model_id_seq', (SELECT MAX(id) FROM car_model));
SELECT setval('client_id_seq', (SELECT MAX(id) FROM client));
SELECT setval('location_id_seq', (SELECT MAX(id) FROM location));
SELECT setval('supplier_id_seq', (SELECT MAX(id) FROM supplier));