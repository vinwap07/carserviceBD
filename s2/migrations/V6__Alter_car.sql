ALTER TABLE car 
    -- Добавляем новые поля для соответствия требованиям
    ADD COLUMN price NUMERIC(10,2),                    -- цена (диапазонные значения)
    ADD COLUMN mileage INTEGER,                         -- пробег
    ADD COLUMN engine_volume NUMERIC(3,1),              -- объем двигателя
    ADD COLUMN transmission VARCHAR(20),                 -- коробка передач (низкая селективность)
    ADD COLUMN fuel_type VARCHAR(20),                    -- тип топлива (низкая селективность)
    ADD COLUMN features JSONB,                           -- особенности/комплектация в JSONB
    ADD COLUMN maintenance_history TEXT[],                -- массив записей о ТО
    ADD COLUMN last_maintenance DATE,                     -- дата последнего ТО
    ADD COLUMN condition_score INTEGER,                   -- оценка состояния (1-10)
    ADD COLUMN owners_count INTEGER,                      -- количество владельцев
    ADD COLUMN location point,                            -- геометрический тип (координаты)
    ADD COLUMN sale_radius int4range,                     -- range тип (радиус продажи в км)
    ADD COLUMN description TEXT,                          -- полнотекстовые данные
    ADD COLUMN status VARCHAR(20),                        -- статус автомобиля
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;  

ALTER TABLE car 
    DROP COLUMN IF EXISTS price,
    DROP COLUMN IF EXISTS sale_radius,
    DROP COLUMN IF EXISTS location,
    DROP COLUMN IF EXISTS last_visit_date,
    DROP COLUMN IF EXISTS next_maintenance_date,
    DROP COLUMN IF EXISTS total_visits,
    DROP COLUMN IF EXISTS total_spent,
    DROP COLUMN IF EXISTS vin_code,  -- не дублируем, т.к. vin уже есть
    DROP COLUMN IF EXISTS insurance_company,
    DROP COLUMN IF EXISTS insurance_expiry,
    DROP COLUMN IF EXISTS last_service_type,
    DROP COLUMN IF EXISTS service_history,
    DROP COLUMN IF EXISTS complaints,
    DROP COLUMN IF EXISTS technical_condition,
    DROP COLUMN IF EXISTS notes;

-- Добавляем только нужные поля (минимальный набор)
ALTER TABLE car 
    ADD COLUMN IF NOT EXISTS engine_volume NUMERIC(3,1),       -- объем двигателя
    ADD COLUMN IF NOT EXISTS transmission VARCHAR(20),          -- коробка передач (низкая селективность)
    ADD COLUMN IF NOT EXISTS fuel_type VARCHAR(20),             -- тип топлива (низкая селективность)
    ADD COLUMN IF NOT EXISTS mileage INTEGER,                   -- пробег (диапазонные значения)
    ADD COLUMN IF NOT EXISTS features JSONB,                    -- особенности/комплектация
    ADD COLUMN IF NOT EXISTS condition_score INTEGER,           -- оценка состояния (1-10)
    ADD COLUMN IF NOT EXISTS owners_count INTEGER,              -- количество владельцев
    ADD COLUMN IF NOT EXISTS description TEXT,                  -- описание (полнотекстовые данные)
    ADD COLUMN IF NOT EXISTS status VARCHAR(20),                -- статус автомобиля
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS last_update TIMESTAMP;             -- дата последнего обновления
