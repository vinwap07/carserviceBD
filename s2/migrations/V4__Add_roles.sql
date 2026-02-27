REATE ROLE client_dev LOGIN PASSWORD 'client_dev_pass';

CREATE ROLE watcher LOGIN PASSWORD 'watcher_pass';

CREATE ROLE killer LOGIN PASSWORD 'killer_pass';

GRANT CONNECT ON DATABASE autoservice TO client_dev, watcher, killer;
GRANT SELECT, INSERT, UPDATE, DELETE ON client, loyalty_card TO client_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO watcher;
GRANT DELETE ON ALL TABLES IN SCHEMA public TO killer;