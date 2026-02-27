-- Добавление новых колонок в таблицу supplier
ALTER TABLE supplier 
    -- Добавляем новые поля для соответствия требованиям
    ADD COLUMN rating NUMERIC(3,2),                    -- рейтинг (0-5)
    ADD COLUMN registration_date TIMESTAMP,            -- дата регистрации
    ADD COLUMN category VARCHAR(20),                    -- категория поставщика (низкая селективность)
    ADD COLUMN region VARCHAR(50),                      -- регион (с перекосом)
    ADD COLUMN contract_number VARCHAR(30),             -- номер контракта (высокая селективность)
    ADD COLUMN metadata JSONB,                          -- метаданные в JSONB
    ADD COLUMN delivery_area int4range,                 -- range тип (зона доставки в днях)
    ADD COLUMN location point,                           -- геометрический тип
    ADD COLUMN description TEXT,                         -- полнотекстовые данные
    ADD COLUMN tags TEXT[];                              -- массив тегов

-- Создание индексов для новых полей
CREATE INDEX idx_supplier_category ON supplier(category);
CREATE INDEX idx_supplier_region ON supplier(region);
CREATE INDEX idx_supplier_rating ON supplier(rating);
CREATE INDEX idx_supplier_registration_date ON supplier(registration_date);
CREATE INDEX idx_supplier_metadata ON supplier USING GIN (metadata);
CREATE INDEX idx_supplier_tags ON supplier USING GIN (tags);
CREATE INDEX idx_supplier_delivery_area ON supplier USING GIST (delivery_area);
CREATE INDEX idx_supplier_location ON supplier USING GIST (location);

-- Индекс для полнотекстового поиска
CREATE INDEX idx_supplier_description ON supplier USING GIN (to_tsvector('russian', description));