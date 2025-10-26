### 1. Агрегатная функция COUNT()

1.1. Количество выполненных заказов клиентов
```sql
SELECT COUNT(*) AS number_of_completed_orders
FROM client_order
WHERE status = 'выполнен';
```
![Скриншот](screenshots1/1.1.png)

1.2. 
```sql

```
![Скриншот](screenshots1/1.2.png)

### 2. Агрегатная функция SUM()

2.1.
```sql

```

![Скриншот](screenshots1/2.1.png)

2.2. Общая сумма затрат на заказы поставщикам, оформленных для точки, расположенной по адресу "ул. Ленина, 25, Москва"
```sql
SELECT SUM(total_cost) AS total_supplier_orders_cost
FROM order_to_supplier os
INNER JOIN location l ON os.id_location = l.id
WHERE address = 'ул. Ленина, 25, Москва';
```

![Скриншот](screenshots1/2.2.png)

### 3. Агрегатная функция AVG()

3.1. 
```sql

```

![Скриншот](screenshots1/3.1.png)

3.2. 
```sql

```

![Скриншот](screenshots1/3.2.png)

### 4. Агрегатная функция MIN() 

4.1. Самая ранняя дата регистрации бонусной карты клиента
```sql
SELECT MIN(registration_date) AS earliest_registration
FROM loyalty_card;
```

![Скриншот](screenshots1/4.1.png)

4.2. 
```sql

```

![Скриншот](screenshots1/4.2.png)

### 5. Агрегатная функция MAX() 

5.1. 
```sql

```

![Скриншот](screenshots1/5.1.png)

5.2. Максимальное количество баллов на бонусной карте
```sql
SELECT MAX(points_balance) AS max_points
FROM loyalty_card;
```

![Скриншот](screenshots1/5.2.png)

### 6. Агрегатная функция STRING_AGG()
6.1. 
```sql

```

![Скриншот](screenshots1/6.1.png)

6.2. 
```sql

```

![Скриншот](screenshots1/6.2.png)

### 7. Комбинирование функций

7.1. Статистика по заказам клиентов: количество, общая сумма, средняя сумма, минимальная и максимальная стоимость
```sql
SELECT 
    COUNT(*) AS orders_count,
    SUM(total_amount) AS total_sum,
    ROUND(AVG(total_amount), 2) AS average_amount,
    MIN(total_amount) AS min_amount,
    MAX(total_amount) AS max_amount
FROM client_order;
```

![Скриншот](screenshots1/7.1.png)

7.2.
```sql

```

![Скриншот](screenshots1/7.2.png)

### 8. GROUP BY 

8.1. 
```sql

```

![Скриншот](screenshots1/8.1.png)

8.2. Количество заказов клиентов по каждому приоритету
```sql
SELECT priority, COUNT(*) AS orders_count
FROM client_order
GROUP BY priority;
```

![Скриншот](screenshots1/8.2.png)

### 9. Фильтрация групп (HAVING)

9.1. 
```sql

```

![Скриншот](screenshots1/9.1.png)

9.2. 
```sql

```

![Скриншот](screenshots1/9.2.png)

### 10. Расширенная группировка - GROUPING SETS

10.1. Количество сотрудников, сгруппированных по должностям и статусам, только по должностям и только по статусам.
```sql
SELECT position, status, COUNT(*) AS employees_count
FROM employee
GROUP BY
	GROUPING SETS ((position, status), (position), (status), ())
ORDER BY position, status;
```

![Скриншот](screenshots1/10.1.png)

10.2. 
```sql

```

![Скриншот](screenshots1/10.2.png)

### 11. Расширенная группировка - ROLLUP

11.1. 
```sql

```

![Скриншот](screenshots1/11.1.png)

11.2. Количество автомобилей, сгруппированных по брендам и моделям, только по брендам. 
```sql
SELECT brand_name, model_name, COUNT(*) AS cars_count
FROM car c
INNER JOIN car_model cm ON c.model_id = cm.id
GROUP BY ROLLUP (brand_name, model_name)
ORDER BY brand_name, model_name;
```

![Скриншот](screenshots1/11.2.png)

### 12. Расширенная группировка - CUBE

12.1. 
```sql

```

![Скриншот](screenshots1/12.1.png)

12.2. 
```sql

```

![Скриншот](screenshots1/12.2.png)
