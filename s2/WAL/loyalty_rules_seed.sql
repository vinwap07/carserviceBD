INSERT INTO loyalty_rules (min_points, discount_percent, level_name) VALUES
    (0, 0.00, 'Новичок'),
    (100, 3.00, 'Базовый'),
    (250, 5.00, 'Бронзовый'),
    (500, 7.50, 'Серебряный'),
    (1000, 10.00, 'Золотой'),
    (2500, 12.50, 'Платиновый'),
    (5000, 15.00, 'Премиум'),
    (10000, 17.50, 'VIP'),
    (25000, 20.00, 'VIP Золото'),
    (50000, 22.50, 'VIP Платина'),
    (100000, 25.00, 'Элитный'),
    (250000, 27.50, 'Элитный Плюс'),
    (500000, 30.00, 'Бизнес-класс'),
    (1000000, 32.50, 'Executive'),
    (2500000, 35.00, 'Executive Gold'),
    (5000000, 37.50, 'Executive Platinum'),
    (10000000, 40.00, 'Black Edition'),
    (25000000, 42.50, 'Black Diamond'),
    (50000000, 45.00, 'Presidential'),
    (100000000, 50.00, 'Легенда')
ON CONFLICT (min_points) DO UPDATE SET
    discount_percent = EXCLUDED.discount_percent,
    level_name = EXCLUDED.level_name
WHERE loyalty_rules.discount_percent IS DISTINCT FROM EXCLUDED.discount_percent
   OR loyalty_rules.level_name IS DISTINCT FROM EXCLUDED.level_name;