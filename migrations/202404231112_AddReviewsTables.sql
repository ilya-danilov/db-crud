-- migrate:up

create table api_data.reviews
(
    id uuid primary key default uuid_generate_v4(),
    product_id uuid references api_data.products not null,
    content text not null check (length(content) < 400),
    rating int check (rating >= 0 and rating <= 5)
);

insert into api_data.reviews(product_id, content, rating)
values
    ((select id from api_data.products where title = 'Молоко "Минская марка" 3,2% 1л. Тетра-пак'), 'Брала в первый раз. Оказалось очень вкусное. В следующий раз возьму ещё', 5),
    ((select id from api_data.products where title = 'Молоко "Минская марка" 3,2% 1л. Тетра-пак'), 'Хорошее. Чувствуется, что натуральное', 5),
    ((select id from api_data.products where title = 'Сметана "Минская марка" 15% 380г. стакан Минск'), 'Вкусная, но немнога кислая', 4),
    ((select id from api_data.products where title = 'Колбаса варено-копченая "Сервелат Финский" Брест'), 'Вкуссная, но очень дорогая', 3),
    ((select id from api_data.products where title = 'Сосиски "Вкусные с телятиной" 280г. Брест'), 'Хорошие сосиски. Дочери очень нравится', 5),
    ((select id from api_data.products where title = 'Буженина "Боярская" запеченная свиная Белорусские рецепты'), 'Это невозможно есть, как за такое можно столько денег брать?', 2),
    ((select id from api_data.products where title = 'Сыр "Черный принц" с ароматом топленого молока Кобрин'), 'Самый вкусный сыр, который только пробовал', 5),
    ((select id from api_data.products where title = 'Сыр "Черный принц" с ароматом топленого молока Кобрин'), 'Хороший сыр, хорошо плавится', 4),
    ((select id from api_data.products where title = 'Пельмени "Мясные подушечки из говядины" 430г. Брест'), 'Я здесь для того, чтобы поесть пельменей и написать отзыв. К слову, пельмени я уже доел', 4),
    ((select id from api_data.products where title = 'Сок "АВС" Ананасовый 100% 1л.'), 'Единственный действительно хороший ананасовый сок', 5),
    ((select id from api_data.products where title = 'Сок "АВС" Мультифруктовый 100% 1л.'), 'Попробовал этот сок, теперь беру только у вас', 5),
    ((select id from api_data.products where title = 'Сок "АВС" Мультифруктовый 100% 1л.'), 'А где доказательства, что сок действительно стопроцентный?', 3);

-- migrate:down