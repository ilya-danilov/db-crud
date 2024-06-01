-- migrate:up

create index promotions_start_date_idx on api_data.promotions using btree(start_date);

create extension pg_trgm;
create index products_title_trgm_idx on api_data.products using gist(title gist_trgm_ops);

-- migrate:down