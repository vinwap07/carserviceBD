# 2. Посмотреть на изменение LSN и WAL после изменения данных
## a. Сравнение LSN до и после INSERT
### LSN до INSERT
``` sql 
SELECT pg_current_wal_lsn();
```
![](2_a_1.png)

### LSN после INSERT
``` sql 
INSERT INTO service ("name", base_price, lead_time)
VALUES
('Замена кресел', 200000, 3);

SELECT pg_current_wal_lsn();
```
![](2_a_2.png)

## b. Сравнение WAL до и после commit
### WAL до commit
``` sql 
CREATE EXTENSION pg_walinspect;

SELECT * FROM pg_ls_waldir();
```
![](2_b_1.png)

### WAL после commit
``` sql 
BEGIN; 
INSERT INTO service ("name", base_price, lead_time)
VALUES
('Замена колодок', 320000, 5);
COMMIT;

SELECT * FROM pg_ls_waldir();
```

![](2_b_2.png)

## c.
### Размер WAL до массовой операции
``` sql 
SELECT sum(size) FROM pg_ls_waldir();
```
![](2_c_1.png)
### Размер WAL после массовой операции

``` sql 
CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    action_type TEXT,
    created_at TIMESTAMP DEFAULT now()
);

INSERT INTO user_logs (user_id, action_type, created_at)
SELECT 
    floor(random() * 1000 + 1)::int,
    md5(random()::text) || md5(random()::text), 
    now()
FROM generate_series(1, 1000000);

SELECT sum(size) FROM pg_ls_waldir();
```
![](2_c_2.png)

# 3. Сделать дамп БД и накрутить его на новую чистую БД 
## a. Dump только структуры базы
``` bash
"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -U postgres -d CarService2 --schema-only -f schema.sql
```
Создался файл schema.sql

Создала тестовую БД через psql: 
``` sql 
CREATE DATABASE testdatabase
```

В консоли запустила скрипт на эту БД: 
``` bash
psql -U postgres -d testdatabase -f "C:\Users\adeli\OneDrive\Рабочий стол\practice\carserviceBD\s2\WAL\schema.sql"
```

![](3_a.png)

## b. Dump одной таблицы
``` bash 
"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -U postgres -d CarService2 -t service -f table_dump.sql
```
Создался файл table_dump.sql 

Создала тестовую БД через psql: 
``` sql 
CREATE DATABASE testdb;
```

В консоли запустила скрипт на эту БД: 
``` bash 
psql -U postgres -d testdb -f "C:\Users\adeli\OneDrive\Рабочий стол\practice\carserviceBD\s2\WAL\table_dump.sql"
```

![](3_b.png)