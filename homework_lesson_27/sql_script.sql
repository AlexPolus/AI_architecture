--Задача а. Напишите SQL запрос который возвращает имена студентов и их аккаунт в Telegram у которых родной город “Казань” или “Москва”. Результат отсортируйте по имени студента в убывающем порядке
select s.name, s.telegram_contact 
from postgres.public.student s 
where s.city in ('Казань', 'Москва')
order by s.name desc;

--Задача b. Напишите SQL запрос который возвращает данные по университетам в следующем виде (один столбец со всеми данными внутри) с сортировкой по полю “полная информация”
select concat('университет: ', c.name, '; ', 'количество студентов: ', c.size) "полная информация"
from postgres.public.college c 
order by "полная информация";

--Задача c. Напишите SQL запрос который возвращает список университетов и количество студентов, если идентификатор университета должен быть выбран из списка 10, 30, 50. Пожалуйста примените конструкцию IN. Результат запроса отсортируйте по количеству студентов И затем по наименованию университета.
select c.name, c.size
from postgres.public.college c 
where c.id in (10, 30, 50)
order by c.size, c.name;

--Задача d. Напишите SQL запрос который возвращает список университетов и количество студентов, если идентификатор университета НЕ должен соответствовать значениям из списка 10, 30, 50. Пожалуйста в основе примените конструкцию IN. Результат запроса отсортируйте по количеству студентов И затем по наименованию университета.
select c.name, c.size
from postgres.public.college c 
where c.id not in (10, 30, 50)
order by c.size, c.name;

--Задача e. Напишите SQL запрос который возвращает название online курсов университетов и количество заявленных слушателей. Количество заявленных слушателей на курсе должно быть в диапазоне от 27 до 310 студентов. Результат отсортируйте по названию курса и по количеству заявленных слушателей в убывающем порядке для двух полей.
select c."name" , c.amount_of_students 
from postgres.public.course c 
where c.amount_of_students between 27 and 310 and c.is_online = true
order by c.name desc, c.amount_of_students desc;

--Задача f. Напишите SQL запрос который возвращает имена студентов и название курсов университетов в одном списке. Результат отсортируйте в убывающем порядке.
select s.name
from postgres.public.student s 
union
select c.name
from postgres.public.course c 
order by name desc;

--Задача g. Напишите SQL запрос который возвращает имена университетов и название курсов в одном списке, но с типом что запись является или “университет” или “курс”. Результат отсортируйте в убывающем порядке по типу записи и потом по имени.
select c.name, 'университет' as object_type
from postgres.public.college c
union
select c2.name, 'курс' as object_type
from postgres.public.course c2
order by object_type desc, name; 

--Задача h. Напишите SQL запрос который возвращает название курса и количество заявленных студентов в отсортированном списке по количеству слушателей в возрастающем порядке, НО запись с количеством слушателей равным 300 должна быть на первом месте. Ограничьте вывод данных до 3 строк.
select c.name, c.amount_of_students 
from postgres.public.course c 
order by (CASE WHEN c.amount_of_students = 300 THEN c.amount_of_students = 0 end), c.amount_of_students
limit 3;

--Задача i. Напишите DML запрос который создает новый offline курс со следующими характеристиками: - id = 60 - название курса = Machine Learning - количество студентов = 17 - курс проводится в том же университете что и курс Data Mining Предоставьте INSERT выражение которое заполняет необходимую таблицу данными Приложите скрин результата запроса к данным курсов после выполнения команды INSERT к таблице которая была изменена.
select *
from postgres.public.course c;

insert into course(id, name, is_online, amount_of_students, college_id)
values (60,'Machine Learning', false, 17 , (select c.college_id 
                                            from postgres.public.course c 
                                            where c.name = 'Data Mining')); 
                                           
select *
from postgres.public.course c;

--Задача j. Напишите SQL скрипт который подсчитывает симметрическую разницу множеств A и B.
(select id
from postgres.public.course c) 
except
(select id
from postgres.public.student_on_course soc)
union
(select id
from postgres.public.student_on_course socc) 
except
(select id
from postgres.public.course c)
order by id;

--Задача k. Напишите SQL запрос который вернет имена студентов, курс на котором они учатся, названия их родных университетов (в которых они официально учатся) и соответствующий рейтинг по курсу. С условием что рассматриваемый рейтинг студента должен быть строго больше (>) 50 баллов и размер соответствующего ВУЗа должен быть строго больше (>) 5000 студентов. Результат необходимо отсортировать по первым двум столбцам.
select s.name as student_name, c2."name" as course_name, c."name" as student_college, soc.student_rating as student_rating
from postgres.public.student s 
join postgres.public.college c 
on s.college_id = c.id 
join postgres.public.student_on_course soc 
on s.id = soc.student_id
join postgres.public.course c2 
on soc.course_id = c2.id 
where soc.student_rating > 50 and c."size" > 5000
order by student_name, course_name;

--Задача l. Выведите уникальные семантические пары студентов, родной город которых один и тот же. Результат необходимо отсортировать по первому столбцу. Семантически эквивалентная пара является пара студентов например (Иванов, Петров) = (Петров, Иванов), в этом случае должна быть выведена одна из пар.
select s1."name" as student_1, s2."name" as student_2, s1.city 
from postgres.public.student s1
join postgres.public.student s2 
on s1.city = s2.city and s1.id > s2.id
order by student_1;

--Задача m. Напишите SQL запрос который возвращает количество студентов, сгруппированных по их оценке. Результат отсортируйте по названиюоценки студента.
select (case when soc.student_rating < 30 then 'неудовлетворительно'
	         when soc.student_rating between 30 and 59 then 'удовлетворительно'
	         when soc.student_rating between 60 and 84 then 'хорошо'
	         else 'отлично'
	    end) as "оценка", count(soc.student_id) as "количество студентов"
from postgres.public.student_on_course soc 
group by "оценка"
order by "оценка";

--Задача n. Дополните SQL запрос из задания a), с указанием вывода имени курса и количество оценок внутри курса. Результат отсортируйте по названию курса и оценки студента.
select c."name" as "курс", (case when soc.student_rating < 30 then 'неудовлетворительно'
	                             when soc.student_rating between 30 and 59 then 'удовлетворительно'
	                             when soc.student_rating between 60 and 84 then 'хорошо'
	                             else 'отлично'
	                        end) as "оценка", count(soc.student_id) as "количество студентов"
from postgres.public.student_on_course soc 
left join postgres.public.course c 
on soc.course_id = c.id 
group by "курс", "оценка"
order by "курс", "оценка";
