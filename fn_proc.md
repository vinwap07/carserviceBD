## 1. Процедуры 3 шт + запрос просмотра всех процедур
### Процедуры:
1.1
``` sql

```
![Скриншот](screenshots5/1.1.png)

1.2.
``` sql

```
![Скриншот](screenshots5/1.2.png)

1.3. Процедура для добавления нового клиента с картой лояльности
``` sql
CREATE OR REPLACE PROCEDURE add_client_with_loyalty(
	new_full_name VARCHAR(100),
	new_phone_number VARCHAR(12),
	new_email VARCHAR(100),
	new_driver_license VARCHAR(20)
)
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

CALL add_client_with_loyalty('Петрова Мария Ивановна', '+79167654321', 'petrova@mail.ru', 'CD987654321');

SELECT c.id, c.full_name, c.phone_number, c.driver_license, lc.card_number, lc.points_balance
FROM client c
INNER JOIN loyalty_card lc ON c.id = lc.id_client;
```
![Скриншот](screenshots5/1.3.png)

### Запрос просмотра всех процедур:
1.4.
``` sql

```
![Скриншот](screenshots5/1.4.png)

## 2. Функции 3 шт  + функции с переменными 3 шт + запрос просмотра всех функций
### Функции:
2.1.
``` sql

```
![Скриншот](screenshots5/2.1.png)

2.2.
``` sql

```
![Скриншот](screenshots5/2.2.png)

2.3. Функция для получения текущего баланса баллов лояльности клиента по ФИО и номеру
``` sql
CREATE OR REPLACE FUNCTION get_client_points(f_full_name VARCHAR(100), f_phone_number VARCHAR(12))
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN (SELECT points_balance
			FROM loyalty_card 
			INNER JOIN client ON loyalty_card.id_client = client.id
			WHERE full_name = f_full_name AND phone_number = f_phone_number);
END;
$$;

SELECT get_client_points('Федорова Елена Александровна', '+79166789012') AS loyalty_points;
```
![Скриншот](screenshots5/2.3.png)

### Функции с переменными:
2.4.
``` sql

```
![Скриншот](screenshots5/2.4.png)

2.5.
``` sql

```
![Скриншот](screenshots5/2.5.png)

2.6. Итоговая сумма заказа клиента с учетом скидки по баллам лояльности
``` sql
CREATE OR REPLACE FUNCTION calculate_order_total_with_discount(f_order_id INT)
RETURNS INT
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

SELECT calculate_order_total_with_discount(1) AS final_amount;
```
![Скриншот](screenshots5/2.6.png)

### Запрос просмотра всех функций:
2.7.
``` sql

```
![Скриншот](screenshots5/2.7.png)

## 3. Блок DO 3 шт
3.1.
``` sql

```
![Скриншот](screenshots5/3.1.png)

3.2.
``` sql

```
![Скриншот](screenshots5/3.2.png)

3.3. Обновленные суммы в выполненных заказах, рассчитанные с учетом скидки по баллам лояльности клиентов.
``` sql
DO $$
BEGIN
    UPDATE client_order 
    SET total_amount = calculate_order_total_with_discount(id)
    WHERE status = 'выполнен';
END $$;
```
Было: ![Скриншот](screenshots5/3.3.1.png)
Стало: ![Скриншот](screenshots5/3.3.2.png)

## 4. IF 1 шт
4.1.
``` sql

```
![Скриншот](screenshots5/4.1.png)

## 5. CASE 1 шт
5.1.
``` sql

```
![Скриншот](screenshots5/5.1.png)

## 6. WHILE 2 шт
6.1. Процедура для добавления 100 баллов первым 3 клиентам с наибольшим количеством заказов
``` sql
CREATE OR REPLACE PROCEDURE add_points_to_top_clients()
LANGUAGE plpgsql
AS $$
DECLARE
    client_id INTEGER;
    i INTEGER := 1;
BEGIN
    WHILE i <= 3 LOOP
        SELECT co.id_client INTO client_id
        FROM client_order co
        GROUP BY co.id_client
        ORDER BY COUNT(*) DESC
        LIMIT 1
        OFFSET i - 1;
        
        UPDATE loyalty_card 
        SET points_balance = points_balance + 100
        WHERE id_client = client_id;
        
        i := i + 1;
    END LOOP;
END;
$$;

CALL add_points_to_top_clients();
```
Было: ![Скриншот](screenshots5/6.1.1.png)
Стало: ![Скриншот](screenshots5/6.1.2.png)

6.2.
``` sql

```
![Скриншот](screenshots5/6.2.png)

## 7. EXCEPTION 2 шт
7.1.
``` sql

```
![Скриншот](screenshots5/7.1.png)

7.2. Функция для расчета средней суммы заказа клиента с обработкой деления на ноль
``` sql
CREATE OR REPLACE FUNCTION calculate_avg_order_amount(f_client_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    f_total_orders INTEGER;
    f_total_amount INTEGER;
    f_avg_amount NUMERIC;
BEGIN
    SELECT COUNT(*), COALESCE(SUM(total_amount), 0)
    INTO f_total_orders, f_total_amount
    FROM client_order
    WHERE id_client = f_client_id;
    
    f_avg_amount := f_total_amount / f_total_orders;
    
    RETURN f_avg_amount;
    
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'У клиента ID % нет заказов', f_client_id;
        RETURN 0;
	WHEN OTHERS THEN
		RAISE NOTICE 'Ошибка расчета';
	    RETURN -1;
END;
$$;

SELECT calculate_avg_order_amount(1); 
SELECT calculate_avg_order_amount(999); 
```
Для клиента с id = 1: ![Скриншот](screenshots5/7.2.1.png)
Для клиента с id = 999: ![Скриншот](screenshots5/7.2.2.png)
![Скриншот](screenshots5/7.2.3.png)

## 8. RAISE 2 шт
8.1.
``` sql

```
![Скриншот](screenshots5/8.1.png)

8.2.
``` sql

```
![Скриншот](screenshots5/8.2.png)
