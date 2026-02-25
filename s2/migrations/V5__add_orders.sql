-- Заполнение таблицы client_order (основные заказы)
INSERT INTO client_order (id_client, id_car, id_location, employee_id, total_amount, status, created_date, completion_date, notes, priority) VALUES
(1, 1, 1, 1, 420000, 'выполнен', '2024-01-10 09:30:00', '2024-01-10 14:00:00', 'Клиент просил проверить тормозную систему', 'обычный'),
(2, 2, 1, 1, 300000, 'в работе', '2024-01-12 10:15:00', NULL, 'Срочная замена масла', 'высокий'),
(3, 3, 2, 4, 850000, 'создан', '2024-01-13 11:20:00', NULL, 'Полное ТО + замена фильтров', 'обычный'),
(4, 4, 1, 1, 150000, 'выполнен', '2024-01-08 14:45:00', '2024-01-08 16:30:00', 'Замена лампы ближнего света', 'низкий'),
(5, 5, 2, 4, 600000, 'в работе', '2024-01-14 08:30:00', NULL, 'Шиномонтаж + развал-схождение', 'обычный');

-- Дополнительные заказы
INSERT INTO client_order (id_client, id_car, id_location, employee_id, total_amount, status, created_date, completion_date, priority) VALUES
(1, 1, 1, 1, 300000, 'выполнен', '2024-01-05 10:00:00', '2024-01-05 16:00:00', 'обычный'),
(1, 1, 1, 1, 150000, 'в работе', '2024-01-15 09:30:00', NULL, 'обычный'),
(1, 1, 1, 1, 200000, 'отменен', '2024-01-10 14:20:00', NULL, 'обычный'),
(2, 2, 1, 1, 250000, 'выполнен', '2024-01-06 11:00:00', '2024-01-06 17:00:00', 'высокий'),
(2, 2, 1, 1, 180000, 'в работе', '2024-01-16 10:15:00', NULL, 'обычный'),
(2, 2, 1, 1, 120000, 'отменен', '2024-01-12 15:45:00', NULL, 'низкий'),
(3, 3, 2, 4, 400000, 'выполнен', '2024-01-07 12:30:00', '2024-01-07 18:00:00', 'обычный'),
(3, 3, 2, 4, 220000, 'в работе', '2024-01-17 11:20:00', NULL, 'обычный'),
(4, 4, 1, 1, 150000, 'выполнен', '2024-01-08 13:15:00', '2024-01-08 15:30:00', 'низкий'),
(5, 5, 2, 4, 350000, 'выполнен', '2024-01-09 08:45:00', '2024-01-09 14:20:00', 'срочный'),
(5, 5, 2, 4, 280000, 'в работе', '2024-01-18 13:10:00', NULL, 'обычный'),
(5, 5, 2, 4, 190000, 'отменен', '2024-01-14 16:30:00', NULL, 'высокий');

-- Заказы с заметками
INSERT INTO client_order (id_client, id_car, id_location, employee_id, total_amount, status, created_date, completion_date, notes, priority) VALUES
(1, 1, 1, 1, 320000, 'выполнен', '2024-02-15 10:00:00', '2024-02-15 13:00:00', 'Замена масла и фильтра', 'обычный'),
(1, 1, 1, 1, 180000, 'выполнен', '2024-03-10 09:15:00', '2024-03-10 11:00:00', 'Диагностика + лампы', 'низкий'),
(5, 5, 2, 4, 450000, 'выполнен', '2024-02-20 14:00:00', '2024-02-20 16:30:00', 'Замена тормозных колодок', 'обычный');

-- Заполнение таблицы client_order_items
INSERT INTO client_order_items (id_order, product_price_id, quantity, unit_price) VALUES
(1, 1, 1, 120000),
(1, 2, 1, 250000),
(2, 2, 1, 250000),
(3, 1, 1, 120000),
(3, 9, 1, 90000),
(4, 10, 1, 60000),
(5, 6, 4, 400000);

-- Заполнение таблицы client_order_services
INSERT INTO client_order_services (id_order, service_price_id, quantity, unit_price) VALUES
(1, 1, 1, 50000),
(2, 1, 1, 50000),
(3, 10, 1, 120000),
(3, 2, 1, 30000),
(4, 9, 1, 10000),
(5, 6, 1, 40000),
(5, 7, 1, 60000);

-- Заполнение таблицы client_order_status_log
INSERT INTO client_order_status_log (order_id, status) 
SELECT id, status FROM client_order;

-- Обновление последовательностей
SELECT setval('client_order_id_seq', (SELECT MAX(id) FROM client_order));
SELECT setval('client_order_items_id_seq', (SELECT MAX(id) FROM client_order_items));
SELECT setval('client_order_services_id_seq', (SELECT MAX(id) FROM client_order_services));
SELECT setval('client_order_status_log_id_seq', (SELECT MAX(id) FROM client_order_status_log));