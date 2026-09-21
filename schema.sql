-- =====================================================================
--  Сайт репетитора по математике — Елизавета
--  База данных: SQLite (работает «из коробки»).
--  Для MySQL/MariaDB замените:  INTEGER PRIMARY KEY AUTOINCREMENT -> INT AUTO_INCREMENT PRIMARY KEY
--  Для PostgreSQL замените:     INTEGER PRIMARY KEY AUTOINCREMENT -> SERIAL PRIMARY KEY
--  Данные ниже совпадают с тем, что показано на сайте (index.html).
-- =====================================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------
-- 1. Настройки и контакты (ключ -> значение)
-- ---------------------------------------------------------------------
CREATE TABLE site_settings (
    key    TEXT PRIMARY KEY,
    value  TEXT NOT NULL
);

INSERT INTO site_settings (key, value) VALUES
    ('tutor_name',        'Елизавета Николаевна Кожевникова'),
    ('tutor_short',       'Е. Н. Кожевникова'),
    ('subject',           'Математика'),
    ('experience_years',  '4+'),   -- опыт преподавания: больше 4 лет
    ('format',            'Онлайн: Zoom или MAX'),
    ('trial_lesson_minutes', '30'),   -- бесплатное пробное занятие
    ('phone',             '+79259263450'),
    ('phone_view',        '+7 925 926-34-50'),
    ('telegram_username', ''),   -- впишите свой ник без @
    ('max_phone',         '+79259263450'),
    ('email',             'elizaveta.kozhevnikova1405@mail.ru');

-- ---------------------------------------------------------------------
-- 2. Направления занятий и цены
-- ---------------------------------------------------------------------
CREATE TABLE price_plans (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT    NOT NULL,
    description TEXT,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE price_options (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id          INTEGER NOT NULL REFERENCES price_plans(id) ON DELETE CASCADE,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    price_rub        INTEGER NOT NULL CHECK (price_rub >= 0),
    UNIQUE (plan_id, duration_minutes)
);

INSERT INTO price_plans (id, title, description, sort_order) VALUES
    (1, 'Математика 5–9 класс',
        'ВПР, МЦКО, повышение успеваемости, помощь с домашними заданиями, контрольные, самостоятельные.', 1),
    (2, 'Математика: ОГЭ и ЕГЭ (база)',
        'Разбираем весь банк ФИПИ: все прототипы и решения, чтобы сдать на уверенную 5.', 2);

INSERT INTO price_options (plan_id, duration_minutes, price_rub) VALUES
    (1, 45, 1200),
    (1, 60, 1500),
    (1, 90, 2000),
    (2, 60, 1700),
    (2, 90, 2200);

-- Готовый прайс-лист одним запросом:  SELECT * FROM v_price_list;
CREATE VIEW v_price_list AS
SELECT p.title            AS direction,
       o.duration_minutes AS minutes,
       o.price_rub        AS price_rub
FROM   price_plans p
JOIN   price_options o ON o.plan_id = p.id
ORDER  BY p.sort_order, o.duration_minutes;

-- ---------------------------------------------------------------------
-- 3. Отзывы и результаты (одна таблица, тип задаётся полем kind)
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    kind         TEXT    NOT NULL CHECK (kind IN ('review', 'result')),
    image_file   TEXT    NOT NULL,          -- имя файла скриншота
    title        TEXT    NOT NULL,
    body         TEXT    NOT NULL,
    sort_order   INTEGER NOT NULL DEFAULT 0,
    is_published INTEGER NOT NULL DEFAULT 1 CHECK (is_published IN (0, 1)),
    created_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_reviews_kind ON reviews (kind, is_published, sort_order);

INSERT INTO reviews (kind, image_file, title, body, sort_order) VALUES
    ('result', 'result-29.jpg',        'ОГЭ по математике, 02.06.2026',
        '29 первичных баллов, 93% выполнения, оценка «5».', 1),
    ('result', 'result-27.jpg',        'ОГЭ по математике, 02.06.2026',
        '27 первичных баллов, 87% выполнения, оценка «5».', 2),
    ('result', 'result-oge-29b.jpg',   'ОГЭ по математике, 02.06.2026',
        '29 баллов, оценка «5».', 3),
    ('result', 'result-24.jpg',        'ГИА-9-2026, математика',
        '24 первичных балла: 18 из 19 в кратких ответах, 6 из 12 во второй части. По геометрии — 7 баллов. Оценка «5».', 4),
    ('result', 'result-tasks-30.jpg',  'Разбор ОГЭ по заданиям',
        '30 первичных баллов: 18 из 19 в первой части и по 2 балла за каждое из шести заданий второй части.', 5),
    ('result', 'result-ege-21.jpg',    'ЕГЭ, математика (базовый уровень), 08.06.2026',
        '21 первичный балл, оценка «5».', 6),
    ('result', 'result-ege-20.jpg',    'ЕГЭ, математика (базовый уровень), 08.06.2026',
        '20 первичных баллов, оценка «5».', 7),
    ('result', 'result-diag.jpg',      'Независимая диагностика, 10 класс',
        'Геометрия и теория вероятностей — по 100%, оценка «5» (24.04.2026).', 8),
    ('result', 'result-diag8.jpg',     'Диагностика в 8 классе, углублённый уровень',
        '13 баллов из 15 (87%), высокий уровень. 25.04.2024.', 9),
    ('result', 'result-gram6.jpg',     'Математическая грамотность, 6 класс',
        '10 баллов из 15 (67%), высокий уровень. 02.03.2022.', 10),
    ('review', 'review-1.jpg',         'С «тройки» до «четвёрки» за 4 месяца',
        'По геометрии — первая «пятёрка». Объясняете чётко, без воды, но терпеливо отвечаете на все вопросы.', 1),
    ('review', 'review-2.jpg',         'Ребёнок ждёт каждого урока',
        'Полгода занятий: раньше не любил математику, теперь огромный прогресс в оценках и в понимании предмета.', 2),
    ('review', 'review-3.jpg',         'Задачи, которые казались нерешаемыми',
        'Занятия проходят продуктивно и по существу — разобрались с тем, что раньше не получалось.', 3),
    ('review', 'review-4.jpg',         'Пробный ОГЭ — 17 баллов',
        'Полгода подготовки по алгебре и геометрии: были «тройки», стали «четвёрки». Помогли разбор типовых заданий и регулярные пробники.', 4),
    ('review', 'review-5.jpg',         'Успеваемость подтянули за короткий срок',
        'Закрыли пробелы в знаниях. Всегда пунктуальна, вежлива, находит индивидуальный подход.', 5);

-- Что показывать на сайте:
--   Отзывы:      SELECT * FROM reviews WHERE kind = 'review' AND is_published = 1 ORDER BY sort_order;
--   Результаты:  SELECT * FROM reviews WHERE kind = 'result' AND is_published = 1 ORDER BY sort_order;

-- ---------------------------------------------------------------------
-- 4. Заявки на пробное занятие (для формы записи, если подключите сервер)
-- ---------------------------------------------------------------------
CREATE TABLE leads (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL,
    contact    TEXT    NOT NULL,             -- телефон, Telegram или почта
    grade      INTEGER CHECK (grade BETWEEN 1 AND 11),
    goal       TEXT    CHECK (goal IN ('grades', 'oge', 'ege_base', 'other')),
    message    TEXT,
    status     TEXT    NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'trial_done', 'client', 'declined')),
    created_at TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_leads_status ON leads (status, created_at);
