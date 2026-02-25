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

-- Обновление последовательностей
SELECT setval('product_prices_id_seq', (SELECT MAX(id) FROM product_prices));
SELECT setval('service_prices_id_seq', (SELECT MAX(id) FROM service_prices));
SELECT setval('remains_of_goods_id_seq', (SELECT MAX(id) FROM remains_of_goods));
SELECT setval('order_to_supplier_id_seq', (SELECT MAX(id) FROM order_to_supplier));
SELECT setval('supplier_order_items_id_seq', (SELECT MAX(id) FROM supplier_order_items));