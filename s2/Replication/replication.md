# Physical streaming replication
## Настройка потоковой репликации
1. Изменила postgresql.conf
2. Изменила pg_hba.conf
3. Добавила роль

``` sql 
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicatorpass';
```



# Logical replication
