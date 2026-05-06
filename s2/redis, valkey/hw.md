# 1. Запуск через докер
- скопировала докер компоуз
- запустила контейнер
- запустила redis-cli

# 2. Счетчик просмотров

## Создать счетчик для статьи
``` bash
127.0.0.1:6379> HSET articles:10 views 0
(integer) 1
```
## Увеличить счетчик несколько раз
``` bash
127.0.0.1:6379> HINCRBY articles:10 views 1
(integer) 1
127.0.0.1:6379> HINCRBY articles:10 views 1
(integer) 2
127.0.0.1:6379> HINCRBY articles:10 views 1
(integer) 3
```

## Просмотр значения
``` bash 
127.0.0.1:6379> HGETALL articles:10
1) "views"
2) "3"
```

# 3. Рейтинг статей

## Создание лидерборда
``` bash 
127.0.0.1:6379> ZADD article_leaderboard 100 "article:1"
(integer) 1
127.0.0.1:6379> ZADD article_leaderboard 500 "article:2"
(integer) 1
127.0.0.1:6379> ZADD article_leaderboard 250 "article:3"
(integer) 1
127.0.0.1:6379> ZADD article_leaderboard 50 "article:4"
(integer) 1
```

## Топ 3 статьи

### Без количества просмотров
``` bash 
127.0.0.1:6379> ZREVRANGE article_leaderboard 0 2
1) "article:2"
2) "article:3"
3) "article:1"
```

### С количеством просмотров
``` bash 
127.0.0.1:6379> ZREVRANGE article_leaderboard 0 2 WITHSCORES
1) "article:2"
2) "500"
3) "article:3"
4) "250"
5) "article:1"
6) "100"
```

### Добавление просмотров и топ после добавления
``` bash 
127.0.0.1:6379> ZINCRBY article_leaderboard 1000 "article:4"
"1050"
127.0.0.1:6379> ZREVRANGE article_leaderboard 0 2 WITHSCORES
1) "article:4"
2) "1050"
3) "article:2"
4) "500"
5) "article:3"
6) "250"
```
