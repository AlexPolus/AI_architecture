--Создаем новую схему
create schema university_scores;

--Создаем таблицу students
create table if not exists university_scores.students (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200),
	total_score INTEGER
);

--Создаем таблицу activity_scores
create table if not exists university_scores.activity_scores (
	id SERIAL PRIMARY KEY,
	student_id INTEGER,
	activity_type VARCHAR(150),
	score INTEGER,	
	FOREIGN KEY (student_id) REFERENCES university_scores.students(id));
	
--Заполняем таблицу university_scores.students
INSERT INTO university_scores.students (name, total_score)
VALUES ('Estelle Cintron', 90);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Conception Chilton', 56);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Maurine Haas', 88);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Murray Vaughan', 26);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Lynell Jaime', 39);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Deane Groves', 34);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Lavera Rector', 73);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Shavonne Eddy', 4);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Rosetta Gifford', 68);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Vance Brantley', 47);

--Заполняем таблицу university_scores.activity_scores
INSERT INTO university_scores.activity_scores (student_id, activity_type, score) values
(1, 'course work', 76),
(1, 'exam', 35),
(2, 'course work', 56),
(2, 'exam', 44),
(3, 'course work', 77),
(3, 'exam', 88),
(4, 'course work', 55),
(4, 'exam', 66),
(5, 'course work', 24),
(5, 'exam', 3),
(6, 'course work', 90),
(6, 'exam', 95),
(7, 'course work', 99),
(7, 'exam', 99),
(8, 'course work', 33),
(8, 'exam', 44),
(9, 'course work', 76),
(9, 'exam', 35),
(10, 'course work', 56),
(10, 'exam', 44);

-- Создаем функцию update_total_score
CREATE OR REPLACE FUNCTION update_total_score()
RETURNS TRIGGER AS $$
  BEGIN
    UPDATE university_scores.students
    SET total_score = (
      SELECT COALESCE(SUM(score), 0)
      FROM university_scores.activity_scores
      WHERE student_id = NEW.student_id
    )
    WHERE id = NEW.student_id;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

--Создаем триггер update_total_score_trigger
CREATE TRIGGER update_total_score_trigger
AFTER INSERT ON activity_scores
FOR EACH ROW
EXECUTE FUNCTION update_total_score();

--Проверяем записи в таблице university_scores.students до изменений
SELECT * FROM university_scores.students;

--Вносим новые данные в таблицу university_scores.students
INSERT INTO university_scores.students (name, total_score)
VALUES ('Florentina Bock', 80);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Dillon Coles', 73);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Mistie Warfield', 82);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Laticia Tilton-Newkirk', 48);
INSERT INTO university_scores.students (name, total_score)
VALUES ('Vickie Bowers', 61);

--Вносим новые данные в таблицу university_scores.activity_scores
INSERT INTO university_scores.activity_scores (student_id, activity_type, score) values
(11, 'course work', 76),
(11, 'exam', 35),
(12, 'course work', 56),
(12, 'exam', 44),
(13, 'course work', 77),
(13, 'exam', 88),
(14, 'course work', 55),
(14, 'exam', 66),
(15, 'course work', 24)
(15, 'exam', 66);

--Проверяем, соответствует ли общий балл каждого добавленного студента в таблице university_scores.students баллам в таблице university_scores.activity_scores.
select s.*, a.student_id, a.activity_type , a.score 
from university_scores.students s
join university_scores.activity_scores a
on s.id = a.student_id
where s.id between 11 and 15;

--Добавим новый столбец в таблицу university_scores.students
ALTER TABLE university_scores.students
ADD scholarship INTEGER NULL;

--Создаем функцию calculate_scholarship
CREATE OR REPLACE FUNCTION calculate_scholarship(student_id INTEGER)
RETURNS INTEGER AS $$
  DECLARE
    student_total_score INTEGER;
    scholarship_amount INTEGER;
  BEGIN
      SELECT total_score INTO student_total_score FROM students WHERE id = student_id;
      IF student_total_score >= 90 THEN
      scholarship_amount := 1000;
      ELSIF student_total_score >= 80 THEN
      scholarship_amount := 500;
      ELSE
      scholarship_amount := 0;
      END IF;

      RETURN scholarship_amount;
  END;
$$ LANGUAGE plpgsql;

--Создаем функцию-обвязку для триггера update_scholarship
CREATE OR REPLACE FUNCTION update_scholarship()
RETURNS TRIGGER AS $$
BEGIN
    SELECT calculate_scholarship(NEW.student_id) INTO NEW.score;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер update_scholarship_trigger
CREATE TRIGGER update_scholarship_trigger
AFTER UPDATE ON activity_scores
FOR EACH ROW
EXECUTE FUNCTION update_scholarship();

--Рассмотрим данные о баллах и стипендии студента
SELECT
    s.id AS student_id,
    s.name AS student_name,
    s.total_score,
    CASE
        WHEN s.total_score >= 90 THEN 1000
        WHEN s.total_score >= 80 THEN 500
        ELSE 0
    END AS scholarship
FROM
    students s
ORDER by 
scholarship DESC, s.id;

--Добавим данные о студентах и их баллах, чтобы проследить как автоматически обновляется стипендия после обновления баллов на примере id 2 и id 7
UPDATE students SET total_score = total_score + 30 WHERE id IN (2, 7);

--Рассмотрим обновленные данные о баллах и стипендии студента
SELECT
    s.id AS student_id,
    s.name AS student_name,
    s.total_score,
    CASE
        WHEN s.total_score >= 90 THEN 1000
        WHEN s.total_score >= 80 THEN 500
        ELSE 0
    END AS scholarship
FROM
    students s
ORDER by 
scholarship DESC, s.id;

--Сохраним данные о стипендиях в новом поле scholarship в таблице students
UPDATE students s SET scholarship = 
    CASE
        WHEN s.total_score >= 90 THEN 1000
        WHEN s.total_score >= 80 THEN 500
        ELSE 0
    END;
   
--Проверяем записи в таблице university_scores.students успешно и корректно обновлены
SELECT * FROM university_scores.students
order by total_score desc;


