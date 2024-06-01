-- migrate:up

insert into api_data.products (title, price, category)
select
    title[1 + floor((random() * array_length(title, 1)))::int] || ' ' || substr(md5(random()::text), 1, 5),
    round((50 + random() * 1000)::numeric, 2),
    category[1 + floor((random() * array_length(category, 1)))::int] || ' ' || substr(md5(random()::text), 1, 5)
from generate_series(1, 500000) as id
cross join
    (select
        '{Молоко,Колбаса варено-копченая,Колбаса сырокопчёная,Колбаса,Колбаса обычная,Колбаса вкусная,Пельмени,Чебуреки,Сок}'
        ::text[] as title,
        '{Молочные продукты,Мясные изделия,Сыры,Замороженные продукты,Соки и морсы,Соки,Морсы,Вареники,Пельмени,Чебуреки,Пирожки,Колбасы}'
        ::text[] as category) as title_category;

insert into api_data.promotions (title, discount_amount, start_date, end_date)
select
    title[1 + floor((random() * array_length(title, 1)))::int] || ' ' || substr(md5(random()::text), 1, 5),
    (random() * 100)::int,
    (current_date + random() * interval '12 months')::date,
    (current_date + (2 + random()) * interval '12 months')::date
from generate_series(1, 500000) as id
cross join
    (select
        '{А,Б,В,Г,Д,Е,Ё,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Э,Ю,Я}'
        ::text[] as title) as title;

-- migrate:down