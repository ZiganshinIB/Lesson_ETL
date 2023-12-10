
/* 
1. Создайте таблицу movies с полями movies_type, director, year_of_issue, length_in_minutes, rate.

здесь комментарий */
CREATE TABLE people
(
    Id SERIAL PRIMARY KEY,
    first_name character(20) NOT null,
    last_name character(20) NOT NULL
);

CREATE TABLE movies (
	Id SERIAL PRIMARY KEY,
	movies_type character(25) not NULL, -- Тип фильма
	director INTEGER REFERENCES people (Id), -- директор????
	year_of_issue date not null,   -- год выпуска
	length_in_minutes integer not null CHECK(length_in_minutes > 0),  -- длина_в_минутах
	rate integer not null CHECK(rate > 0 and rate <=11)-- рейтинг
);

insert into people (Id, first_name, last_name) 
values
(1, 'Kio', 'Minigan'),
(2, 'Артур', 'Хаймуран'),
(3, 'Виктор', 'Слонов'),
(4, 'Kio', 'Minigan'),
(5, 'Кира', 'Ярмак'),
(6, 'Алексей', 'Дун'),
(7, 'Vilok', 'Demigan'),
(8, 'Atach', 'Kune'),
(9, 'Lula', 'Maron'),
(10, 'Ислам', 'Хайран'),
(11, 'Олег', 'Снежков'),
(12, 'Сергей', 'Геймеров'),
(13, 'Максим', 'Кравец'),
(14, 'Даша', 'Цикала')


/* 
2. Сделайте таблицы для горизонтального партицирования по году выпуска (до 1990, 1990 -2000, 2000- 2010, 2010-2020, после 2020).
*/
CREATE TABLE movies_year_1990 (
    CHECK (year_of_issue < '1/1/1990')
) INHERITS (movies);

CREATE TABLE movies_year_1990_2000 (
    CHECK (year_of_issue >= '1/1/1990' and year_of_issue < '1/1/2000')
) INHERITS (movies);

CREATE TABLE movies_year_2000_2010 (
    CHECK (year_of_issue >= '1/1/2000' and year_of_issue < '1/1/2010')
) INHERITS (movies);


CREATE TABLE movies_year_2010_2020 (
    CHECK (year_of_issue >= '1/1/2010' and year_of_issue < '1/1/2020')
) INHERITS (movies);

CREATE TABLE movies_year_2020 (
    CHECK (year_of_issue > '1/1/2020')
) INHERITS (movies);

--rule 
create rule movies_year_insert_1990 as on insert to movies
where (year_of_issue < '1/1/1990')
do instead insert into movies_year_1990 values (new.*);

create rule movies_year_insert_1990_2000 as on insert to movies
where (year_of_issue >= '1/1/1990' and year_of_issue < '1/1/2000')
do instead insert into movies_year_1990_2000 values (new.*);

create rule movies_year_insert_2000_2010 as on insert to movies
where (year_of_issue >= '1/1/2000' and year_of_issue < '1/1/2010')
do instead insert into movies_year_2000_2010 values (new.*);

create rule movies_year_insert_2010_2020 as on insert to movies
where (year_of_issue >= '1/1/2010' and year_of_issue < '1/1/2020')
do instead insert into movies_year_2010_2020 values (new.*);

create rule movies_year_insert_2020 as on insert to movies
where (year_of_issue >= '1/1/2020')
do instead insert into movies_year_2020 values (new.*);

--3. Сделайте таблицы для горизонтального партицирования по длине фильма (до 40 минута, от 40 до 90 минут, от 90 до 130 минут, более 130 минут)

CREATE TABLE movies_length_in_minutes_40 (
    CHECK (length_in_minutes > 0 and length_in_minutes <= 40)
) INHERITS (movies);

CREATE TABLE movies_length_in_minutes_40_90 (
    CHECK (length_in_minutes > 40 and length_in_minutes <= 90)
) INHERITS (movies);

CREATE TABLE movies_length_in_minutes_90_130 (
    CHECK (length_in_minutes > 90 and length_in_minutes <= 130)
) INHERITS (movies);

CREATE TABLE movies_length_in_minutes_130 (
    CHECK (length_in_minutes > 130)
) INHERITS (movies);
--rule
create rule movies_length_in_minutes_insert_40 as on insert to movies
where (length_in_minutes <= 40)
do instead insert into movies_length_in_minutes_40 values (new.*);

create rule movies_length_in_minutes_insert_40_90 as on insert to movies
where (length_in_minutes > 40 and length_in_minutes <= 90)
do instead insert into movies_length_in_minutes_40_90 values (new.*);

create rule movies_length_in_minutes_insert_90_130 as on insert to movies
where (length_in_minutes > 90 and length_in_minutes <= 130)
do instead insert into movies_length_in_minutes_90_130 values (new.*);

create rule movies_length_in_minutes_insert_130 as on insert to movies
where (length_in_minutes > 130)
do instead insert into movies_length_in_minutes_130 values (new.*);


--4. Сделайте таблицы для горизонтального партицирования по рейтингу фильма (ниже 5, от 5 до 8, от 8до 10).
CREATE TABLE movies_rate_5 (
    CHECK (rate > 0 and rate < 5)
) INHERITS (movies);

CREATE TABLE movies_rate_5_8 (
    CHECK (rate >= 5 and rate < 8)
) INHERITS (movies);

CREATE TABLE movies_rate_8_10 (
    CHECK (rate >= 8 and rate <= 10)
) INHERITS (movies);
--rule 
create rule movies_rate_insert_5 as on insert to movies
where (rate > 0 and rate < 5)
do instead insert into movies_rate_5 values (new.*);

create rule movies_rate_insert_5_8 as on insert to movies
where (rate >= 5 and rate < 8)
do instead insert into movies_rate_5_8 values (new.*);

create rule movies_rate_insert_8_10 as on insert to movies
where (rate >= 8 and rate <= 10)
do instead insert into movies_rate_8_10 values (new.*);

-- 6. Добавьте фильмы так, чтобы в каждой таблице было не менее 3 фильмов.
-- 7. Добавьте пару фильмов с рейтингом выше 10.
insert into movies(movies_type, director, year_of_issue, length_in_minutes, rate) 
values 
('Драма', 1, '8/8/2014', 133, 4),
('Комедия', 2, '9/15/1988', 94, 9),
('Комедия', 2, '8/25/2001', 105, 7),
('Комедия', 2, '2/12/1905', 116, 6),
('Мелодрама', 11, '6/16/2015', 88, 6),
('Мелодрама', 9, '7/22/2012', 101, 8),
('Мелодрама', 7, '7/10/2014', 99, 9),
('Выживание', 6, '10/15/2006', 144, 6),
('Трейлер', 3, '10/15/2022', 25, 6),
('Документ.', 6, '8/13/2023', 89, 7),
('Драма', 7, '8/8/2014', 122, 7),
('Комедия', 6, '9/15/2007', 94, 9),
('Комедия', 5, '8/25/2001', 40, 7),
('Комедия', 4, '2/12/1905', 116, 6),
('Мелодрама', 9, '6/16/2005', 88, 6),
('Мелодрама', 3, '7/22/2012', 122, 8),
('Мелодрама', 10, '7/10/2014', 99, 9),
('Выживание', 14, '10/15/2006', 137, 6),
('Трейлер', 13, '10/15/2022', 75, 6),
('Документ.', 8, '8/13/2023', 144, 4),
('Драма', 12, '8/8/2014', 55, 7),
('Комедия', 12, '9/15/1988', 94, 5),
('Комедия', 8, '8/25/2001', 105, 4),
('Комедия', 12, '2/12/1905', 116, 6),
('Мелодрама', 3, '6/16/2015', 88, 7),
('Мелодрама', 3, '7/22/2012', 122, 9),
('Мелодрама', 13, '7/10/2014', 99, 1),
('Выживание', 4, '10/15/2006', 144, 4),
('Трейлер', 13, '10/15/2022', 25, 6),
('Документ.', 3, '8/13/2023', 22, 7),
('Драма', 11, '8/8/2014', 125, 7),
('Комедия', 2, '9/15/2007', 94, 9),
('Комедия', 12, '8/25/2001', 40, 8),
('Комедия', 2, '2/12/1905', 99, 4),
('Мелодрама', 3, '6/16/2005', 88, 3),
('Мелодрама', 13, '7/22/2012', 122, 5),
('Мелодрама', 3, '7/10/2014', 99, 5),
('Выживание', 14, '10/15/2006', 144, 6),
('Трейлер', 3, '10/15/2022', 200, 6),
('Документ.', 7, '8/13/2023', 39, 9),
('Драма', 5, '8/8/2014', 133, 5),
('Комедия', 2, '9/15/1988', 94, 8),
('Комедия', 6, '8/25/2001', 105, 4),
('Комедия', 2, '2/12/1905', 116, 8),
('Мелодрама', 11, '6/16/2015', 88, 4),
('Мелодрама', 7, '7/22/2012', 101, 9),
('Мелодрама', 3, '7/10/2014', 99, 3),
('Выживание', 9, '10/15/2006', 144, 6),
('Трейлер', 13, '10/15/2022', 25, 8),
('Документ.', 12, '8/13/2023', 144, 10),
('Драма', 11, '8/8/2014', 122, 7),
('Комедия', 5, '9/15/2007', 94, 9),
('Комедия', 2, '8/25/2001', 40, 6),
('Комедия', 6, '2/12/1905', 78, 6),
('Мелодрама', 3, '6/16/2005', 88, 4),
('Мелодрама', 9, '7/22/2012', 122, 8),
('Мелодрама', 3, '7/10/2014', 99, 9),
('Выживание', 14, '10/15/2006', 127, 6),
('Трейлер', 3, '10/15/2022', 75, 6),
('Документ.', 8, '8/13/2023', 144, 7),
('Драма', 1, '8/8/2014', 55, 7),
('Комедия', 2, '9/15/1988', 94, 9),
('Комедия', 12, '8/25/2001', 105, 3),
('Комедия', 2, '2/12/1905', 116, 9),
('Мелодрама', 4, '6/16/2015', 88, 6),
('Мелодрама', 5, '7/22/2012', 122, 4),
('Мелодрама', 3, '7/10/2014', 99, 8),
('Выживание', 6, '10/15/2006', 44, 7),
('Трейлер', 7, '10/15/2022', 25, 6),
('Документ.', 3, '8/13/2023', 22, 7),
('Драма', 8, '8/8/2014', 125, 7),
('Комедия', 2, '9/15/2007', 94, 9),
('Комедия', 2, '8/25/2001', 40, 7),
('Комедия', 9, '2/12/1905', 99, 6),
('Мелодрама', 10, '6/16/2005', 88, 6),
('Мелодрама', 3, '7/22/2012', 122, 8),
('Мелодрама', 10, '7/10/2014', 99, 9),
('Выживание', 4, '10/15/2006', 144, 6),
('Трейлер', 3, '10/15/2022', 188, 11),
('Документ.', 10, '8/13/2023', 39, 11),
('Драма', 11, '11/15/2001', 57, 11)


-- 8. Сделайте выбор из всех таблиц, в том числе из основной.
-- 9. Сделайте выбор только из основной таблицы.

select * 
from movies;

select * 
from movies_year_1990;

select *
from movies_year_1990_2000;

select *
from movies_year_2000_2010;

select *
from movies_year_2010_2020;

select * 
from movies_year_2020;


select *
from movies_length_in_minutes_40;

select *
from movies_length_in_minutes_40_90;

select *
from movies_length_in_minutes_90_130;

select *
from movies_length_in_minutes_130;


select *
from movies_rate_5;

select *
from movies_rate_5_8;

select *
from movies_rate_8_10;
