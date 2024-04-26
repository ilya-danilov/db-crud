-- migrate:up

create extension if not exists "uuid-ossp";

create schema if not exists api_data;

create table if not exists api_data.products
(
    id uuid primary key default uuid_generate_v4(),
    title text not null check (length(title) < 100),
    price decimal(7, 2) not null check (price > 0),
    category text not null check (length(category) < 50)
);

create table if not exists api_data.promotions
(
    id uuid primary key default uuid_generate_v4(),
    title text not null check (length(title) < 400),
    discount_amount int not null check (discount_amount >= 0 and discount_amount <= 100),
    start_date date not null,
    end_date date,
    check (start_date <= end_date)
);

create table if not exists api_data.promotion_to_product
(
    product_id uuid references api_data.products,
    promotion_id  uuid references api_data.promotions,
    primary key (product_id, promotion_id)
);

insert into api_data.products(title, price, category)
values
    ('Молоко "Минская марка" 3,2% 1л. Тетра-пак', 118.00, 'Молочные продукты'),
    ('Сметана "Минская марка" 15% 380г. стакан Минск', 116.00, 'Молочные продукты'),
    ('Творог "Славянские традиции" 5% 180г. Минск', 91.00, 'Молочные продукты'),
    ('Кефир "Славянские традиции" 3,2% 900г. бутылка Минск', 111.00, 'Молочные продукты'),

    ('Колбаса варено-копченая "Сервелат Финский" Брест', 1080.00, 'Мясные изделия'),
    ('Колбаса сырокопчёная оригинальная "Мясной дуэт" Гродно', 1719.00, 'Мясные изделия'),
    ('Сосиски "Вкусные с телятиной" 280г. Брест', 163.00, 'Мясные изделия'),
    ('Буженина "Боярская" запеченная свиная Белорусские рецепты', 933.00, 'Мясные изделия'),

    ('Сыр "Черный принц" с ароматом топленого молока Кобрин', 1048.00, 'Сыры'),
    ('Сыр "Князь Владимир" с ароматом топленого молока Бабушкина крынка', 865.00, 'Сыры'),
    ('Сыр плавленый "Минская марка" Классический 100г. Минск', 69.00, 'Сыры'),

    ('Пельмени "Мясные подушечки из говядины" 430г. Брест', 224.00, 'Замороженные продукты'),
    ('Чебуреки с ветчиной и сыром жареные Ремко', 524.00, 'Замороженные продукты'),

    ('Сок "АВС" Ананасовый 100% 1л.', 147.00, 'Соки и морсы'),
    ('Сок "АВС" Мультифруктовый 100% 1л.', 147.00, 'Соки и морсы');


insert into api_data.promotions(title, discount_amount, start_date, end_date)
values
    ('22.04.2024 действует скидка 50% на "Пельмени "Мясные подушечки из говядины" 430г. Брест"', 50, '2024-04-22', '2024-04-22'),
    ('С 01.05.2024 по 08.05.2024 действует скидка 25% на все твёрдые сыры', 25, '2024-05-01', '2024-05-08'),
    ('С 01.05.2024 по 15.05.2024 действует скидка 15% на "Сосиски "Вкусные с телятиной" 280г. Брест" и "Сыр плавленый "Минская марка" Классический 100г. Минск"', 15, '2024-05-01', '2024-05-15'),
    ('С 22.04.2024 по 29.04.2024 действует скидка 20% на продукты из категории "Молочные продукты"', 20, '2024-04-22', '2024-04-29'),
    ('С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"', 10, '2024-04-30', '2024-05-30');

insert into api_data.promotion_to_product(product_id, promotion_id)
values
    ((select id from api_data.products where title = 'Пельмени "Мясные подушечки из говядины" 430г. Брест'),
     (select id from api_data.promotions where title = '22.04.2024 действует скидка 50% на "Пельмени "Мясные подушечки из говядины" 430г. Брест"')),

    ((select id from api_data.products where title = 'Сыр "Черный принц" с ароматом топленого молока Кобрин'),
     (select id from api_data.promotions where title = 'С 01.05.2024 по 08.05.2024 действует скидка 25% на все твёрдые сыры')),
    ((select id from api_data.products where title = 'Сыр "Князь Владимир" с ароматом топленого молока Бабушкина крынка'),
     (select id from api_data.promotions where title = 'С 01.05.2024 по 08.05.2024 действует скидка 25% на все твёрдые сыры')),

    ((select id from api_data.products where title = 'Сосиски "Вкусные с телятиной" 280г. Брест'),
     (select id from api_data.promotions where title = 'С 01.05.2024 по 15.05.2024 действует скидка 15% на "Сосиски "Вкусные с телятиной" 280г. Брест" и "Сыр плавленый "Минская марка" Классический 100г. Минск"')),
    ((select id from api_data.products where title = 'Сыр плавленый "Минская марка" Классический 100г. Минск'),
     (select id from api_data.promotions where title = 'С 01.05.2024 по 15.05.2024 действует скидка 15% на "Сосиски "Вкусные с телятиной" 280г. Брест" и "Сыр плавленый "Минская марка" Классический 100г. Минск"')),

    ((select id from api_data.products where title = 'Молоко "Минская марка" 3,2% 1л. Тетра-пак'),
     (select id from api_data.promotions where title = 'С 22.04.2024 по 29.04.2024 действует скидка 20% на продукты из категории "Молочные продукты"')),
    ((select id from api_data.products where title = 'Сметана "Минская марка" 15% 380г. стакан Минск'),
     (select id from api_data.promotions where title = 'С 22.04.2024 по 29.04.2024 действует скидка 20% на продукты из категории "Молочные продукты"')),
    ((select id from api_data.products where title = 'Творог "Славянские традиции" 5% 180г. Минск'),
     (select id from api_data.promotions where title = 'С 22.04.2024 по 29.04.2024 действует скидка 20% на продукты из категории "Молочные продукты"')),
    ((select id from api_data.products where title = 'Кефир "Славянские традиции" 3,2% 900г. бутылка Минск'),
     (select id from api_data.promotions where title = 'С 22.04.2024 по 29.04.2024 действует скидка 20% на продукты из категории "Молочные продукты"')),

    ((select id from api_data.products where title = 'Колбаса варено-копченая "Сервелат Финский" Брест'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Колбаса сырокопчёная оригинальная "Мясной дуэт" Гродно'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Сосиски "Вкусные с телятиной" 280г. Брест'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Буженина "Боярская" запеченная свиная Белорусские рецепты'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Сыр "Черный принц" с ароматом топленого молока Кобрин'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Сыр "Князь Владимир" с ароматом топленого молока Бабушкина крынка'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"')),
    ((select id from api_data.products where title = 'Сыр плавленый "Минская марка" Классический 100г. Минск'),
     (select id from api_data.promotions where title = 'С 30.04.2024 по 30.05.2024 действует скидка 10% на продукты из категорий "Мясные изделия" и "Сыры"'));

-- migrate:down