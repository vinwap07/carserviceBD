### 1. CTE 
1.1 
```sql 

```
![Скриншот](screenshots3/1.1.png)

1.2 CTE для анализа заказов по брендам автомобилей
```sql 
WITH BrandOrders AS (
    SELECT 
        cm.brand_name,
        COUNT(co.id) as order_count,
        AVG(co.total_amount) as avg_order_amount
    FROM client_order co
    JOIN car c ON co.id_car = c.id
    JOIN car_model cm ON c.model_id = cm.id
    GROUP BY cm.brand_name
)
SELECT 
    brand_name,
    order_count,
    ROUND(avg_order_amount) as avg_order_amount
FROM BrandOrders
ORDER BY order_count DESC;
```
![Скриншот](screenshots3/1.2.png)

1.3 
```sql 

```
![Скриншот](screenshots3/1.3.png)

1.4 
```sql 

```
![Скриншот](screenshots3/1.4.png)

1.5 CTE для анализа поставщиков и их товаров
```sql 
WITH SupplierAnalysis AS (
    SELECT 
        s.company_name,
        COUNT(n.article) as product_count,
        COUNT(rog.article) as products_in_stock,
        AVG(pp.price) as avg_product_price
    FROM supplier s
    LEFT JOIN nomenclature n ON s.id = n.id_supplier
    LEFT JOIN product_prices pp ON n.article = pp.article
    LEFT JOIN remains_of_goods rog ON n.article = rog.article
    GROUP BY s.company_name
)
SELECT 
    company_name,
    product_count,
    products_in_stock,
    ROUND(avg_product_price) as avg_price
FROM SupplierAnalysis
ORDER BY product_count DESC;
```
![Скриншот](screenshots3/1.5.png)

### 2. UNION 

2.1 
```sql 

```
![Скриншот](screenshots3/2.1.png)

2.2 
```sql 

```
![Скриншот](screenshots3/2.2.png)

2.3 Объединение клиентов и сотрудников
```sql 
SELECT full_name, phone_number, 'client' as type
FROM client
UNION
SELECT full_name, phone_number, 'employee' as type  
FROM employee;
```
![Скриншот](screenshots3/2.3.png)

### 3. INTERSECT 

3.1 
```sql 

```
![Скриншот](screenshots3/3.1.png)

3.2 
```sql 

```
![Скриншот](screenshots3/3.2.png)

3.3 Товары, которые есть и в заказах клиентов и в заказах поставщикам
```sql 
SELECT n.article 
FROM client_order_items coi
JOIN product_prices pp ON coi.product_price_id = pp.id
JOIN nomenclature n ON pp.article = n.article
JOIN client_order co ON coi.id_order = co.id
WHERE co.status = 'выполнен'
INTERSECT
SELECT article 
FROM supplier_order_items soi
JOIN order_to_supplier os ON soi.id_order = os.id
WHERE os.status = 'доставлен';
```
![Скриншот](screenshots3/3.3.png)

### 4. EXCEPT 

4.1 
```sql 

```
![Скриншот](screenshots3/4.1.png)

4.2 
```sql 

```
![Скриншот](screenshots3/4.2.png)

4.3 Товары без остатков на складе
```sql 
SELECT article FROM nomenclature
EXCEPT
SELECT article FROM remains_of_goods;
```
![Скриншот](screenshots3/4.3.png)

### 5. PARTITION BY 

5.1 
```sql 

```
![Скриншот](screenshots3/5.1.png)

5.2 
```sql 

```
![Скриншот](screenshots3/5.2.png)

### 6. PARTITION BY + ORDER BY 

6.1 Накопительная сумма по клиентам
```sql 
SELECT 
    id_client,
    total_amount,
    created_date,
    SUM(total_amount) OVER (
        PARTITION BY id_client 
        ORDER BY created_date
    ) as cumulative_sum
FROM client_order;
```
![Скриншот](screenshots3/6.1.png)

6.2 
```sql 

```
![Скриншот](screenshots3/6.2.png)

### 7. ROWS 

7.1 
```sql 

```
![Скриншот](screenshots3/7.1.png)

7.2 Скользящее среднее за 2 последних заказа
```sql 
SELECT 
    id,
    total_amount,
    AVG(total_amount) OVER (
        ORDER BY created_date
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) as moving_avg
FROM client_order;
```
![Скриншот](screenshots3/7.2.png)

### 8. RANGE

8.1 
```sql 

```
![Скриншот](screenshots3/8.1.png)

8.2 
```sql 

```
![Скриншот](screenshots3/8.2.png)

### 9. Ранжирующие оконные функции

#### 9.1 ROW_NUMBER Нумерация заказов клиента
```sql 
SELECT 
    id_client,
    id,
    total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY id_client 
        ORDER BY created_date
    ) as order_num
FROM client_order;
```
![Скриншот](screenshots3/9.1.png)

#### 9.2 RANK 
```sql 

```
![Скриншот](screenshots3/9.2.png)

#### 9.3 DENSE_RANK 
```sql 

```
![Скриншот](screenshots3/9.3.png)

### 10. Функции смещения

#### 10.1 LAG Сравнение с предыдущим заказом
```sql 
SELECT 
    id,
    total_amount,
    LAG(total_amount) OVER (ORDER BY created_date) as prev_amount
FROM client_order;
```
![Скриншот](screenshots3/10.1.png)

#### 10.2 LEAD 
```sql 

```
![Скриншот](screenshots3/10.2.png)

#### 10.3 FIRST_VALUE 
```sql 

```
![Скриншот](screenshots3/10.3.png)

#### 10.3 LAST_VALUE Последний заказ клиента
```sql 
SELECT DISTINCT
    id_client,
    LAST_VALUE(total_amount) OVER (
        PARTITION BY id_client
        ORDER BY created_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as last_order_amount
FROM client_order;
```
![Скриншот](screenshots3/10.3.png)
