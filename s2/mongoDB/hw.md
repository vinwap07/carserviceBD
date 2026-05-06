# 1. Создание коллекции books и вставка документа
``` javascript 
demoDB> 
| db.books.insertOne({
|     title: "Мой дом",
|     genre: "Драма",
|     price: 350,
|     avaliable: false,
|     tags: ["триллер", "тяжело"],
|     author: {
|         name: "Иванов И. И.",
|         country: "Монголия"
|     }
| })
{
  acknowledged: true,
  insertedId: ObjectId('69fad9c9ca499abe1544ba89')
}
dem
```

# 2. Вывести книги в наличии
Добавила книгу в наличии
``` javascript
db.books.insertOne({
    title: "Их здание",
    genre: "Романтика",
    price: 400,
    avaliable: true,
    tags: ["комедия", "легко"],
    author: {
        name: "Джереми",
        country: "Россия"
    }
})
```

``` javascript
demoDB> db.books.find({ avaliable: true }).pretty()
[
  {
    _id: ObjectId('69fadab5ca499abe1544ba8b'),
    title: 'Их здание',
    genre: 'Романтика',
    price: 400,
    avaliable: true,
    tags: [ 'комедия', 'легко' ],
    author: { name: 'Джереми', country: 'Россия' }
  }
]
```

# 3. Добавление нескольких документов

``` javascript
demoDB> db.books.insertMany([
|   {
|     title: "Ветер в степи",
|     genre: "Приключения",
|     price: 420,
|     avaliable: true,
|     tags: ["путешествие", "лошади", "классика"],
|     author: {
|         name: "Бату Хасиков",
|         country: "Калмыкия"
|     }
|   },
|   {
|     title: "Программирование на коленке",
|     genre: "Технологии",
|     price: 1200,
|     avaliable: true,
|     tags: ["код", "юмор", "обучение"],
|     author: {
|         name: "Айтишников А. А.",
|         country: "Сербия"
|     }
|   },
|   {
|     title: "Ночные тени",
|     genre: "Ужасы",
|     price: 280,
|     avaliable: false,
|     tags: ["мистика", "страх"],
|     author: {
|         name: "Стивен Кингов",
|         country: "США"
|     }
|   },
|   {
|     title: "Кулинария будущего",
|     genre: "Нон-фикшн",
|     price: 850,
|     avaliable: true,
|     tags: ["еда", "футуризм"],
|     author: {
|         name: "Джейми Оливеров",
|         country: "Великобритания"
|     }
|   }
| ])
| 
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('69fadb8dca499abe1544ba8c'),
    '1': ObjectId('69fadb8dca499abe1544ba8d'),
    '2': ObjectId('69fadb8dca499abe1544ba8e'),
    '3': ObjectId('69fadb8dca499abe1544ba8f')
  }
}
```

# 4. Запрос 

Вставлю значение, чтобы поиск сработал: 
``` javascript
demoDB> db.books.insertOne({
|     title: "Чистый код: Магия рефакторинга",
|     genre: "Programming",
|     price: 1500,
|     avaliable: true,
|     tags: ["разработка", "best practices", "clean code"],
|     author: {
|         name: "Роберт Мартинов",
|         country: "США"
|     }
| })
| 
{
  acknowledged: true,
  insertedId: ObjectId('69fadc51ca499abe1544ba90')
}
```

``` javascript
demoDB> db.books.find(
|     {
|         genre: "Programming",
|         price: {$gte: 300},
|         avaliable: true
|     },
|     {
|         title: 1,
|         price: 1,
|         _id: 0 
|     }
| )
[ { title: 'Чистый код: Магия рефакторинга', price: 1500 } ]
```