/*1) »спользу€ SQL €зык и произвольные две таблицы из модели данных
необходимо объединить их различными способами (UNION , JOIN)*/
select ticket_no, flight_id
from boarding_passes b 
union
select ticket_no, flight_id
from ticket_flights t;

select *
from seats s 
join aircrafts_data ad 
on s.aircraft_code = ad.aircraft_code;

/*2) »спользу€ SQL €зык напишите запрос с любым фильтром WHERE к
произвольной таблице и результат отсортируйте (ORDER BY) с ограничением
вывода по количеству строк (LIMIT)
*/
select *
from bookings b
join tickets t 
on b.book_ref = t.book_ref
where total_amount < 10000
order by book_date desc
limit 7;

/*3) »спользу€ SQL €зык напишите OLAP запрос к произвольной св€зке таблиц (в
рамках JOIN оператора), использу€ оператор GROUP BY и любые агрегатные
функции count, min, max, sum.*/
select count(*) as "количество мест", ad.model as "модель самолета"
from seats s 
join aircrafts_data ad 
on s.aircraft_code = ad.aircraft_code
group by ad.aircraft_code
order by "количество мест";

/*4) »спользу€ SQL €зык примените JOIN операторы (INNER, LEFT, RIGHT) дл€
более чем двух таблиц из модели данных.
*/
select f.flight_no as "номер рейса", 
tf.flight_id, tf.ticket_no, 
t.passenger_name as "пассажир", 
b.book_ref, b.total_amount as "стоимость перелета"
from flights f 
inner join ticket_flights tf 
on f.flight_id = tf.flight_id
left join tickets t 
on tf.ticket_no = t.ticket_no
right join bookings b 
on t.book_ref = b.book_ref;

/*5) —оздайте виртуальную таблицу VIEW с произвольным именем дл€ SQL запроса
из задани€ 2)*/
CREATE VIEW The_last_7_tickets_are_cheaper_than_10000 AS
select b.book_ref as "номер бронировани€", b.book_date as "дата бронировани€",
b.total_amount as "стоимость билета", t.ticket_no as "номер билета",
t.passenger_name as "им€ пассажира", t.contact_data as "контактные данные"
from bookings b
join tickets t 
on b.book_ref = t.book_ref
where total_amount < 10000
order by book_date desc
limit 7;

select * from The_last_7_tickets_are_cheaper_than_10000;