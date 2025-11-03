### 1. SELECT

1.1. Дата самого первого заказа
```sql
SELECT (SELECT MIN(created_date) FROM client_order) AS first_order_date;
```
![Скриншот](screenshots2/1.1.png)

1.2. 
```sql

```
![Скриншот](screenshots2/1.2.png)

1.3.
```sql

```
![Скриншот](screenshots2/1.3.png)

### 2. FROM 

2.1. Клиенты, у которых хотя бы 1 заказ
```sql
SELECT full_name, order_count
FROM (
    SELECT c.full_name, COUNT(co.id) AS order_count
    FROM client c
    LEFT JOIN client_order co ON c.id = co.id_client
    GROUP BY c.full_name
) 
WHERE order_count > 0;
```

![Скриншот](screenshots2/2.1.png)

2.2. 
```sql

```

![Скриншот](screenshots2/2.2.png)

2.3.
```sql

```
![Скриншот](screenshots2/2.3.png)

### 3. WHERE

3.1. Крупные заказы, стоимость которых выше средней стоимости выполненных заказов
```sql
SELECT *
FROM client_order
WHERE total_amount > (
    SELECT AVG(total_amount) 
    FROM client_order 
    WHERE status = 'выполнен'
);
```

![Скриншот](screenshots2/3.1.png)

3.2. 
```sql

```

![Скриншот](screenshots2/3.2.png)

3.3.
```sql

```
![Скриншот](screenshots2/3.3.png)

### 4. HAVING

4.1. Наиболее популярные товары с объемом продаж выше среднего
```sql
SELECT n.article, n.name as product_name, SUM(coi.quantity) as total_sold
FROM client_order_items coi
INNER JOIN product_prices pp ON coi.product_price_id = pp.id
INNER JOIN nomenclature n ON pp.article = n.article 
GROUP BY n.article
HAVING SUM(coi.quantity) > (SELECT AVG(quantity) FROM client_order_items);
```

![Скриншот](screenshots2/4.1.png)

4.2. 
```sql

```

![Скриншот](screenshots2/4.2.png)

4.3.
```sql

```
![Скриншот](screenshots2/4.3.png)

### 5. ALL

5.1. Товары, которые не продавались
```sql
SELECT DISTINCT name 
FROM nomenclature
WHERE article <> ALL (
    SELECT DISTINCT article 
    FROM client_order_items coi 
    INNER JOIN product_prices pp ON coi.product_price_id = pp.id
);
```

![Скриншот](screenshots2/5.1.png)

5.2. 
```sql

```

![Скриншот](screenshots2/5.2.png)

5.3.
```sql

```
![Скриншот](screenshots2/5.3.png)

### 6. IN

6.1. Товары, которые есть в наличии в московском филиале в количестве более 10 штук
```sql
SELECT *
FROM nomenclature
WHERE article IN (
    SELECT article 
    FROM remains_of_goods 
    WHERE quantity > 10
    AND location_id IN (
        SELECT id 
        FROM location 
        WHERE address LIKE '%Москва%'
    )
);
```

![Скриншот](screenshots2/6.1.png)

6.2.  
```sql

```

![Скриншот](screenshots2/6.2.png)

6.3.
```sql

```
![Скриншот](screenshots2/6.3.png)

### 7. ANY

7.1. Услуги, которые заказывались хотя бы раз
```sql
SELECT name, base_price
FROM service
WHERE name = ANY (
    SELECT service_name 
    FROM client_order_services cos 
    INNER JOIN service_prices sp ON cos.service_price_id = sp.id
);
```

![Скриншот](screenshots2/7.1.png)

7.2. 
```sql

```

![Скриншот](screenshots2/7.2.png)

7.3.
```sql

```
![Скриншот](screenshots2/7.3.png)

### 8. EXIST

8.1. Клиенты, у которых есть карта лояльности с более чем 1000 баллов
```sql
SELECT *
FROM client c
WHERE EXISTS (
    SELECT 1 
    FROM loyalty_card lc 
    WHERE lc.id_client = c.id 
    AND lc.points_balance > 1000
);
```

![Скриншот](screenshots2/8.1.png)

8.2.
```sql

```

![Скриншот](screenshots2/8.2.png)

8.3.
```sql

```
![Скриншот](screenshots2/8.3.png)

### 9. Сравнение по нескольким столбцам

9.1. Клиенты с такой же датой регистрации и балансом баллов, как у VIP-клиентов (level_name = 'Золото')
```sql
SELECT full_name, registration_date, points_balance
FROM client 
INNER JOIN loyalty_card ON client.id = loyalty_card.id_client
WHERE (registration_date, points_balance) IN (
    SELECT registration_date, points_balance
    FROM loyalty_card lc
    INNER JOIN loyalty_rules lr ON lc.points_balance >= lr.min_points
    WHERE level_name = 'Золото'
);
```

![Скриншот](screenshots2/9.1.png)

9.2. 
```sql

```

![Скриншот](screenshots2/9.2.png)

9.3.
```sql

```
![Скриншот](screenshots2/9.3.png)

### 10. Коррелированные подзапросы

10.1. Количество работающих сотрудников в каждом филиале
```sql
SELECT 
    address,
    (SELECT COUNT(*) 
     FROM employee e 
     WHERE e.location_id = l.id AND e.status = 'работает') 
	 AS active_employees
FROM location l;
```

![Скриншот](screenshots2/10.1.png)

10.2. 
```sql

```

![Скриншот](screenshots2/10.2.png)

10.3. 
```sql

```

![Скриншот](screenshots2/10.3.png)

10.4. Товары с текущей ценой
```sql
SELECT 
    n.article,
    n.name,
    (SELECT price 
     FROM product_prices pp 
     WHERE pp.article = n.article 
     ORDER BY effective_date DESC 
     LIMIT 1) 
	 AS current_price
FROM nomenclature n;
```

![Скриншот](screenshots2/10.4.png)

10.5. 
```sql

```

![Скриншот](screenshots2/10.5.png)
