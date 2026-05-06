# 1. Поднять через докер
- написала докер компоуз
- создала и запустила контейнер

# 2-3. Создание индекса и заполнение тестовых данных 

```
PUT /_bulk
{ "index" : { "_index" : "products", "_id" : "1" } }
{ "name": "iPhone 13", "price": 75000, "category": "Электроника", "stock": 15 }
{ "index" : { "_index" : "products", "_id" : "2" } }
{ "name": "Samsung Galaxy S22", "price": 68000, "category": "Электроника", "stock": 10 }
{ "index" : { "_index" : "products", "_id" : "3" } }
{ "name": "MacBook Air M1", "price": 95000, "category": "Электроника", "stock": 5 }
{ "index" : { "_index" : "products", "_id" : "4" } }
{ "name": "Чайник электрический", "price": 2500, "category": "Техника для кухни", "stock": 40 }
{ "index" : { "_index" : "products", "_id" : "5" } }
{ "name": "Кофемашина DeLonghi", "price": 35000, "category": "Техника для кухни", "stock": 8 }
{ "index" : { "_index" : "products", "_id" : "6" } }
{ "name": "Микроволновка LG", "price": 8500, "category": "Техника для кухни", "stock": 20 }
{ "index" : { "_index" : "products", "_id" : "7" } }
{ "name": "Пылесос Dyson", "price": 42000, "category": "Бытовая техника", "stock": 12 }
{ "index" : { "_index" : "products", "_id" : "8" } }
{ "name": "Утюг Tefal", "price": 4500, "category": "Бытовая техника", "stock": 30 }
{ "index" : { "_index" : "products", "_id" : "9" } }
{ "name": "Игровая приставка PS5", "price": 60000, "category": "Гаджеты", "stock": 3 }
{ "index" : { "_index" : "products", "_id" : "10" } }
{ "name": "Монитор Dell 27", "price": 22000, "category": "Электроника", "stock": 18 }
{ "index" : { "_index" : "products", "_id" : "11" } }
{ "name": "Клавиатура Logitech", "price": 9000, "category": "Аксессуары", "stock": 25 }
{ "index" : { "_index" : "products", "_id" : "12" } }
{ "name": "Мышь беспроводная", "price": 3500, "category": "Аксессуары", "stock": 50 }
{ "index" : { "_index" : "products", "_id" : "13" } }
{ "name": "Смарт-часы Apple Watch", "price": 32000, "category": "Гаджеты", "stock": 14 }
{ "index" : { "_index" : "products", "_id" : "14" } }
{ "name": "Наушники AirPods Pro", "price": 19000, "category": "Гаджеты", "stock": 22 }
{ "index" : { "_index" : "products", "_id" : "15" } }
{ "name": "Тостер Philips", "price": 3200, "category": "Техника для кухни", "stock": 15 }
{ "index" : { "_index" : "products", "_id" : "16" } }
{ "name": "Блендер Braun", "price": 5500, "category": "Техника для кухни", "stock": 11 }
{ "index" : { "_index" : "products", "_id" : "17" } }
{ "name": "Телевизор Sony 55", "price": 80000, "category": "Электроника", "stock": 7 }
{ "index" : { "_index" : "products", "_id" : "18" } }
{ "name": "Холодильник Haier", "price": 55000, "category": "Бытовая техника", "stock": 4 }
{ "index" : { "_index" : "products", "_id" : "19" } }
{ "name": "Стиральная машина LG", "price": 48000, "category": "Бытовая техника", "stock": 6 }
{ "index" : { "_index" : "products", "_id" : "20" } }
{ "name": "Электрогриль", "price": 11000, "category": "Техника для кухни", "stock": 9 }
{ "index" : { "_index" : "products", "_id" : "21" } }
{ "name": "Внешний диск 1ТБ", "price": 6000, "category": "Аксессуары", "stock": 33 }
{ "index" : { "_index" : "products", "_id" : "22" } }
{ "name": "Роутер Keenetic", "price": 8000, "category": "Электроника", "stock": 19 }
{ "index" : { "_index" : "products", "_id" : "23" } }
{ "name": "Умная колонка Алиса", "price": 5000, "category": "Гаджеты", "stock": 45 }
{ "index" : { "_index" : "products", "_id" : "24" } }
{ "name": "Электросамокат", "price": 38000, "category": "Транспорт", "stock": 5 }
{ "index" : { "_index" : "products", "_id" : "25" } }
{ "name": "Велосипед горный", "price": 28000, "category": "Спорт", "stock": 10 }
{ "index" : { "_index" : "products", "_id" : "26" } }
{ "name": "Коврик для йоги", "price": 1500, "category": "Спорт", "stock": 100 }
{ "index" : { "_index" : "products", "_id" : "27" } }
{ "name": "Гантели 5кг", "price": 2000, "category": "Спорт", "stock": 40 }
{ "index" : { "_index" : "products", "_id" : "28" } }
{ "name": "Набор инструментов", "price": 12000, "category": "Дом", "stock": 12 }
{ "index" : { "_index" : "products", "_id" : "29" } }
{ "name": "Шуруповерт", "price": 7000, "category": "Дом", "stock": 21 }
{ "index" : { "_index" : "products", "_id" : "30" } }
{ "name": "Лампа настольная", "price": 2500, "category": "Дом", "stock": 35 }
```

# 4. Выполнить операции с документами

## Создание документа
```
POST /products/_doc
{"title": "новый док"}
```

Результат: 
```
{
  "_index" : "products",
  "_type" : "_doc",
  "_id" : "n0hG-p0BMfGfC2bvnmS8",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 36,
  "_primary_term" : 1
}
```

## Добавление документа с указанным id
```
PUT /products/_doc/40/_create
{"title": "новый док", "id": 40}
```

Результат:
```
{
  "_index" : "products",
  "_type" : "_doc",
  "_id" : "40",
  "_version" : 4,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 35,
  "_primary_term" : 1
}
```

## Обновление документа
```
PUT /products/_doc/40
{"title": "обновленный док", "id": 40}
```

Результат: 
```
{
  "_index" : "products",
  "_type" : "_doc",
  "_id" : "40",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 33,
  "_primary_term" : 1
}
```

## Удаление документа 
```
DELETE /products/_doc/40
```

Результат:
```
{
  "_index" : "products",
  "_type" : "_doc",
  "_id" : "40",
  "_version" : 3,
  "result" : "deleted",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 34,
  "_primary_term" : 1
}
```

## Поиск по названию товара
```
GET /products/_search
{
  "query": {
    "match": {
      "name": "блендер braun"
    }
  }
}
```

Результат: 
```
{
  "took" : 126,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 6.3984637,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "16",
        "_score" : 6.3984637,
        "_source" : {
          "name" : "Блендер Braun",
          "price" : 5500,
          "category" : "Техника для кухни",
          "stock" : 11
        }
      }
    ]
  }
}
```

## Запрос с использованием match
```
GET products/_search
{
  "query": {
    "match": {
      "category": "кухня"
    }
  }
}
```

Результат: 
```
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 6,
      "relation" : "eq"
    },
    "max_score" : 1.2969081,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Чайник электрический",
          "price" : 2500,
          "category" : "Техника для кухни",
          "stock" : 40
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "5",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Кофемашина DeLonghi",
          "price" : 35000,
          "category" : "Техника для кухни",
          "stock" : 8
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "6",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Микроволновка LG",
          "price" : 8500,
          "category" : "Техника для кухни",
          "stock" : 20
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "15",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Тостер Philips",
          "price" : 3200,
          "category" : "Техника для кухни",
          "stock" : 15
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "16",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Блендер Braun",
          "price" : 5500,
          "category" : "Техника для кухни",
          "stock" : 11
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "20",
        "_score" : 1.2969081,
        "_source" : {
          "name" : "Электрогриль",
          "price" : 11000,
          "category" : "Техника для кухни",
          "stock" : 9
        }
      }
    ]
  }
}
```

## Запрос с использованием term
```
GET products/_search
{
  "query": {
    "term": {
      "name": "коврик"
    }
  }
}
```

Результат: 
```
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 3.18165,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "26",
        "_score" : 3.18165,
        "_source" : {
          "name" : "Коврик для йоги",
          "price" : 1500,
          "category" : "Спорт",
          "stock" : 100
        }
      }
    ]
  }
}
```

## Запрос с использованием range
```
GET products/_search
{
  "query": {
    "range": {
      "price": {
        "gte": 73000,
        "lte": 76000
      }
    }
  }
}
```

Результат: 
```
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "iPhone 13",
          "price" : 75000,
          "category" : "Электроника",
          "stock" : 15
        }
      }
    ]
  }
}
```

## Запрос с использованием bool с комбинацией условий
```
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "category": "электроника" } }
      ],
      "filter": [
        { "range": { "price": { "lte": 50000 } } }
      ]
    }
  }
}
```

Результат: 
```
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 1.7401555,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "10",
        "_score" : 1.7401555,
        "_source" : {
          "name" : "Монитор Dell 27",
          "price" : 22000,
          "category" : "Электроника",
          "stock" : 18
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "22",
        "_score" : 1.7401555,
        "_source" : {
          "name" : "Роутер Keenetic",
          "price" : 8000,
          "category" : "Электроника",
          "stock" : 19
        }
      }
    ]
  }
}
```
