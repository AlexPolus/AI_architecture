/*1) ��������� SQL ���� � ������������ ��� ������� �� ������ ������
���������� ���������� �� ���������� ��������� (UNION , JOIN)*/
select ticket_no, flight_id
from boarding_passes b 
union
select ticket_no, flight_id
from ticket_flights t;

select *
from seats s 
join aircrafts_data ad 
on s.aircraft_code = ad.aircraft_code;

/*2) ��������� SQL ���� �������� ������ � ����� �������� WHERE �
������������ ������� � ��������� ������������ (ORDER BY) � ������������
������ �� ���������� ����� (LIMIT)
*/
select *
from bookings b
join tickets t 
on b.book_ref = t.book_ref
where total_amount < 10000
order by book_date desc
limit 7;

/*3) ��������� SQL ���� �������� OLAP ������ � ������������ ������ ������ (�
������ JOIN ���������), ��������� �������� GROUP BY � ����� ����������
������� count, min, max, sum.*/
select count(*) as "���������� ����", ad.model as "������ ��������"
from seats s 
join aircrafts_data ad 
on s.aircraft_code = ad.aircraft_code
group by ad.aircraft_code
order by "���������� ����";

/*4) ��������� SQL ���� ��������� JOIN ��������� (INNER, LEFT, RIGHT) ���
����� ��� ���� ������ �� ������ ������.
*/
select f.flight_no as "����� �����", 
tf.flight_id, tf.ticket_no, 
t.passenger_name as "��������", 
b.book_ref, b.total_amount as "��������� ��������"
from flights f 
inner join ticket_flights tf 
on f.flight_id = tf.flight_id
left join tickets t 
on tf.ticket_no = t.ticket_no
right join bookings b 
on t.book_ref = b.book_ref;

/*5) �������� ����������� ������� VIEW � ������������ ������ ��� SQL �������
�� ������� 2)*/
CREATE VIEW The_last_7_tickets_are_cheaper_than_10000 AS
select b.book_ref as "����� ������������", b.book_date as "���� ������������",
b.total_amount as "��������� ������", t.ticket_no as "����� ������",
t.passenger_name as "��� ���������", t.contact_data as "���������� ������"
from bookings b
join tickets t 
on b.book_ref = t.book_ref
where total_amount < 10000
order by book_date desc
limit 7;

select * from The_last_7_tickets_are_cheaper_than_10000;