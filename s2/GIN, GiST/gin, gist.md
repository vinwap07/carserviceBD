# Gin

## 1 запрос

### Создание
``` sql 
CREATE INDEX idx_fearues_gin ON car USING GIN (features);
```

### Сравнение 
``` sql
EXPLAIN ANALYSE
SELECT vin 
FROM car 
WHERE features @> '{"climate": "dual" }';
```
Без индексов: 

![](1_1_1.png)

С индексом: 

![](1_1_2.png)

## 2 запрос

### Создание
``` sql 
CREATE INDEX idx_description_gin ON supplier USING GIN (to_tsvector('russian', description));
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
SELECT *
FROM supplier
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'золото & Москва');
```
Без индексов: 

![](1_2_1.png)

С индексом: 

![](1_2_2.png)


## 3 запрос

### Создание
``` sql 
CREATE INDEX idx_tags_gin ON supplier USING GIN (tags);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
SELECT *
FROM supplier
WHERE tags @> ARRAY['BRONZE', 'long_term']::text[];
```
Без индексов: 

![](1_3_1.png)

С индексом: 

![](1_3_2.png)

## 4 запрос

### Создание
``` sql 
CREATE INDEX idx_tags_gin ON supplier USING GIN (tags);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
SELECT *
FROM supplier
WHERE tags @> ARRAY['BRONZE', 'long_term', 'verified_high']::text[];
```
Без индексов: 

![](1_4_1.png)

С индексом: 

![](1_4_2.png)

## 5 запрос

### Создание
``` sql 
CREATE INDEX idx_tags_gin ON supplier USING GIN (tags);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
UPDATE supplier
SET tags = array_append(tags, 'cool')
WHERE tags @> ARRAY['BRONZE', 'long_term', 'verified_high']::text[];
```
Без индексов: 

![](1_5_1.png)

С индексом: 

![](1_5_2.png)

# GiST

## 1 запрос

### Создание
``` sql 
CREATE INDEX idx_description_gist ON supplier USING GIST (to_tsvector('russian', description));
```

### Сравнение 
``` sql
EXPLAIN ANALYSE
SELECT *
FROM supplier
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'золото & Москва');
```
Без индексов: 

![](2_1_1.png)

С индексом: 

![](2_1_2.png)

## 2 запрос

### Создание
``` sql 
CREATE INDEX idx_location_gist ON client USING GIST (location);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
SELECT * 
FROM client
WHERE circle(point(0,0), 100) @> location;
```
Без индексов: 

![](2_2_1.png)

С индексом: 

![](2_2_2.png)


## 3 запрос

### Создание
``` sql 
CREATE INDEX idx_description_gist ON supplier USING GIST (to_tsvector('russian', description));
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
UPDATE supplier
SET metadata = metadata || '{"rating": 4.8}'::jsonb
WHERE rating = 4.8;
```
Без индексов: 

![](2_3_1.png)

С индексом: 

![](2_3_2.png)

## 4 запрос

### Создание
``` sql 
CREATE INDEX idx_location_gist ON supplier USING GIST (location);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
UPDATE supplier
SET location = point(location[0] + 1, location[1] + 1)
WHERE rating > 4.89;
```
Без индексов: 

![](2_4_1.png)

С индексом: 

![](2_4_2.png)

## 5 запрос

### Создание
``` sql 
CREATE INDEX idx_location_gist ON supplier USING GIST (location);
```

### Сравнение 
``` sql 
EXPLAIN ANALYSE
DELETE FROM supplier
WHERE rating > 4.80;
```
Без индексов: 

![](2_5_1.png)

С индексом: 

![](2_5_2.png)
