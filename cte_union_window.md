### 1. CTE 
1.1 Заказы, сделанные клиентом с золотым уровнем карты
```sql 
WITH client_with_gold_card AS 
	(SELECT lc.id_client 
	FROM loyalty_card lc
	WHERE lc.points_balance >= (SELECT min_points FROM loyalty_rules lr 
		WHERE lr.level_name = 'Золото')
		AND lc.points_balance < (SELECT min_points FROM loyalty_rules lr 
		WHERE lr.level_name = 'Платина'))

SELECT co.id
FROM client_with_gold_card cg JOIN client_order co ON cg.id_client = co.id_client;
```
![Скриншот](screenshots3.1.1.png)

1.2 
```sql 

```
![Скриншот](screenshots3.1.2.png)

1.3 
```sql 

```
![Скриншот](screenshots3.1.3.png)

1.4 Точки, у которых средний чек больше 500к
```sql 
WITH location_orders AS 
	(SELECT id_location, avg(total_amount) AS avg_amount
	FROM client_order co 
	GROUP BY id_location)

SELECT id_location, avg_amount FROM location_orders lo
WHERE lo.avg_amount > 500000;
```
![Скриншот](screenshots3.1.4.png)

1.5 
```sql 

```
![Скриншот](screenshots3.1.5.png)

### 2. UNION 

2.1 
```sql 

```
![Скриншот](screenshots3.2.1.png)

2.2 Товары/услуги и их цена
```sql 
SELECT DISTINCT sp.service_name AS name, sp.price FROM service_prices sp 
UNION 
SELECT DISTINCT n."name", pp.price 
	FROM product_prices pp JOIN nomenclature n ON pp.article = n.article;
```
![Скриншот](screenshots3.2.2.png)

2.3 
```sql 

```
![Скриншот](screenshots3.2.3.png)

### 3. INTERSECT 

3.1 
```sql 

```
![Скриншот](screenshots3.3.1.png)

3.2 Сотрудники, которые вместе с этим являются и клиентами автосервиса
```sql 
SELECT e.full_name, e.phone_number FROM employee e
INTERSECT
SELECT c.full_name, c.phone_number FROM client c;
```
![Скриншот](screenshots3.3.2.png)

3.3 
```sql 

```
![Скриншот](screenshots3.3.3.png)

### 4. EXCEPT 

4.1 
```sql 

```
![Скриншот](screenshots3.4.1.png)

4.2 Сотрудники, которые не являются клиентами автосервиса
```sql 
SELECT e.full_name, e.phone_number FROM employee e
EXCEPT  
SELECT c.full_name, c.phone_number FROM client c;
```
![Скриншот](screenshots3.4.2.png)

4.3 
```sql 

```
![Скриншот](screenshots3.4.3.png)

### 5. PARTITION BY 

5.1 
```sql 

```
![Скриншот](screenshots3.5.1.png)

5.2 Заказы со средним ценником по локациям
```sql 
SELECT co.id, co.id_location, 
	avg(co.total_amount) OVER (PARTITION BY co.id_location) AS avg_amount_on_location
FROM client_order co;
```
![Скриншот](screenshots3.5.2.png)

### 6. PARTITION BY + ORDER BY 

6.1 
```sql 

```
![Скриншот](screenshots3.6.1.png)

6.2 
```sql 

```
![Скриншот](screenshots3.6.2.png)

### 7. ROWS 

7.1 Количество сотрудников, принятых на работу после того, как приняли конкретно этого сотрудника 
```sql 
SELECT full_name, hire_date,
    count(*) OVER (ORDER BY hire_date ASC 
                   ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING) AS count_after
FROM employee;
```
![Скриншот](screenshots3.7.1.png)

7.2 
```sql 

```
![Скриншот](screenshots3.7.2.png)

### 8. RANGE

8.1 
```sql 

```
![Скриншот](screenshots3.8.1.png)

8.2 Клиенты, у которых на карте +- 100 баллов
```sql 
SELECT id_client, points_balance,
    COUNT(*) OVER (ORDER BY points_balance 
                   RANGE BETWEEN 100 PRECEDING AND 100 FOLLOWING) - 1
                   AS clients_with_similar_points
FROM loyalty_card;
```
![Скриншот](screenshots3.8.2.png)

### 9. Ранжирующие оконные функции

#### 9.1 ROW_NUMBER 
```sql 

```
![Скриншот](screenshots3.9.1.png)

#### 9.2 RANK 
```sql 

```
![Скриншот](screenshots3.9.2.png)

#### 9.3 DENSE_RANK Ранг по количеству баллов на карте
```sql 
SELECT id_client, points_balance, 
    DENSE_RANK() OVER (ORDER BY points_balance DESC) AS client_rank
FROM loyalty_card;
```
![Скриншот](screenshots3.9.3.png)

### 10. Функции смещения

#### 10.1 LAG 
```sql 

```
![Скриншот](screenshots3.10.1.png)

#### 10.2 LEAD 
```sql 

```
![Скриншот](screenshots3.10.2.png)

#### 10.3 FIRST_VALUE Стоимость самого дорогого товара в заказе
```sql 
SELECT coi.id, coi.id_order, coi.unit_price,
	FIRST_VALUE(coi.unit_price) OVER (PARTITION BY coi.id_order ORDER BY coi.unit_price) AS most_expensive_item
FROM client_order_items coi;
```
![Скриншот](screenshots3.10.3.png)

#### 10.4 LAST_VALUE 
```sql 

```
![Скриншот](screenshots3.10.3.png)