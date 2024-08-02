/* 
Запрос 1
Вывести полные данные всех клиентов, использующих почту не на protonmail
*/

create index client_reversed_email_index on client (reversed_email);

select *
from client
where reversed_email not like reverse('protonmail.com') || '%';

/* 
Запрос 2
Вывести список листингов акций: название бумаги, название типа бумаги, наименование эмитента, название биржи
*/

create index listing_index on listing (stock_ticker, stock_exchange_ticker);
create index stock_index on stock (stock_type_id, issuer_id);

select s.stock_name Название_бумаги, t.type Название_типа_бумаги, 
i.issuer_name Название_эмитента, e.stock_exchange_name Название_биржи
from listing l
inner join stock s
on s.ticker = l.stock_ticker
inner join stock_type t
on t.id = s.stock_type_id
inner join issuer i
on i.id = s.issuer_id
inner join stock_exchange e
on e.ticker = l.stock_exchange_ticker;

/* 
Запрос 3
Вывести список топ-10 клиентов (имя, фамилия, емейл) с суммой оплаченной ими комиссии (с 2 знаками после десятичной точки), в разбивке по валютам, за ордера, выполненные в ноябре 2023, по убыванию суммы комиссии.
*/

create index stock_order_index on stock_order (approved, datetime, client_id, currency_ticker);

with data as (select client_id, currency_ticker, round(sum(commission), 2) total
from stock_order
where (datetime between '2023-11-01' and '2023-12-01') and approved = true
group by 1, 2)
select cl.name Имя, cl.surname Фамилия, cl.email Email, c.name Валюта, aggregated.total Комиссия 
from ((select *
from data
where data.currency_ticker = 'RUB'
order by data.total desc
limit 10)
union
(select *
from data
where data.currency_ticker = 'USD'
order by data.total desc
limit 10)
union
(select *
from data
where data.currency_ticker = 'GBP'
order by data.total desc
limit 10)) aggregated
inner join client cl
on cl.id = aggregated.client_id
inner join currency c
on c.ticker = aggregated.currency_ticker
order by 4, 5 desc;