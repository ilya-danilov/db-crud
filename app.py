from flask import Flask
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import request
from psycopg2.sql import SQL, Literal
from dotenv import load_dotenv
import os

load_dotenv()


app = Flask(__name__)
app.json.ensure_ascii = False

connection = psycopg2.connect(
    host=os.getenv('POSTGRES_HOST') if os.getenv('DEBUG_MODE') == 'false' else 'localhost',
    port=os.getenv('POSTGRES_PORT'),
    database=os.getenv('POSTGRES_DB'),
    user=os.getenv('POSTGRES_USER'),
    password=os.getenv('POSTGRES_PASSWORD'),
    cursor_factory=RealDictCursor
)
connection.autocommit = True


@app.get("/")
def main_page():
    return "<p>Сайт с продуктами</p>"


@app.get("/products")
def get_products():
    query = """
with products_with_promotions as (
	select
		prod.id,
		prod.title,
		prod.price,
		prod.category,
	  	coalesce(jsonb_agg(jsonb_build_object(
	    	'id', promo.id,
	    	'title', promo.title,
	    	'discount_amount', promo.discount_amount,
	    	'start_date', promo.start_date,
	    	'end_date', promo.end_date
	    )) filter (where promo.id is not null), '[]') as promotions
	from api_data.products prod
	left join api_data.promotion_to_product pp on prod.id = pp.product_id
	left join api_data.promotions promo on promo.id = pp.promotion_id
	group by prod.id
),
products_with_reviews as (
	select
	  	prod.id,
		prod.title,
		prod.price,
		prod.category,
	  	coalesce(json_agg(json_build_object(
	    	'id', r.id,
	    	'content', r.content,
	    	'rating', r.rating
	    )) filter (where r.id is not null), '[]') as reviews
	from api_data.products prod
	left join api_data.reviews r on prod.id = r.product_id
	group by prod.id
)
select pwp.id, pwp.title, pwp.price, pwp.category, pwp.promotions, pwr.reviews
from products_with_promotions pwp
join products_with_reviews pwr on pwp.id = pwr.id
"""

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.post('/products/create')
def create_product():
    body = request.json

    title = body['title']
    price = body['price']
    category = body['category']

    query = SQL("""
insert into api_data.products(title, price, category) values
({title}, {price}, {category})
returning id
""").format(title=Literal(title),
            price=Literal(price),
            category=Literal(category))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone()

    return result


@app.post('/products/update')
def update_product():
    body = request.json

    id = body['id']
    title = body['title']
    price = body['price']
    category = body['category']

    query = SQL("""
update api_data.products
set 
  title = {title}, 
  price = {price},
  category = {category}
where id = {id}
returning id
""").format(title=Literal(title),
            price=Literal(price),
            category=Literal(category),
            id=Literal(id))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204


@app.delete('/products/delete')
def delete_product():
    body = request.json

    id = body['id']

    deleteProductLinks = SQL(
        "delete from api_data.promotion_to_product where product_id = {id}").format(
            id=Literal(id))
    deleteProduct = SQL("delete from api_data.products where id = {id} returning id").format(
        id=Literal(id))

    with connection.cursor() as cursor:
        cursor.execute(deleteProductLinks)
        cursor.execute(deleteProduct)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204

if __name__ == '__main__':
    app.run(port=os.getenv('FLASK_PORT'))