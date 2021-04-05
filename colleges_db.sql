-- Versão noob
create table colleges(college_name text, state text, price int);
create table students(student_id int, student_name text, grade numeric, high_school_size int);
create table applications(student_id int, college_name text, course text, accepted boolean);

drop table if exists colleges;
drop table if exists students;
drop table if exists applications;

-- Versão noob
create table colleges(college_name text, state text, price int);

create table students(student_id int, student_name text, grade numeric, high_school_size int);

create table applications(student_id int, college_name text, course text, accepted boolean, applied_at timestamptz default now());

delete from students;
delete from colleges;
delete from applications;

insert into students values (123, 'Amy', 3.9, 1000);
insert into students values (234, 'Bob', 3.6, 1500);
insert into students values (345, 'Craig', 3.5, 500);
insert into students values (456, 'Doris', 3.9, 1000);
insert into students values (567, 'Edward', 2.9, 2000);
insert into students values (678, 'Fay', 3.8, 200);
insert into students values (789, 'Gary', 3.4, 800);
insert into students values (987, 'Helen', 3.7, 800);
insert into students values (876, 'Irene', 3.9, 400);
insert into students values (765, 'Jay', 2.9, 1500);
insert into students values (654, 'Amy', 3.9, 1000);
insert into students values (543, 'Craig', 3.4, 2000);

insert into colleges values ('Stanford', 'CA', 15000);
insert into colleges values ('Berkeley', 'CA', 36000);
insert into colleges values ('MIT', 'MA', 10000);
insert into colleges values ('Cornell', 'NY', 21000);

insert into applications values (123, 'Stanford', 'CS', true);
insert into applications values (123, 'Stanford', 'EE', false);
insert into applications values (123, 'Berkeley', 'CS', true);
insert into applications values (123, 'Cornell', 'EE', true);
insert into applications values (234, 'Berkeley', 'biology', false);
insert into applications values (345, 'MIT', 'bioengineering', true);
insert into applications values (345, 'Cornell', 'bioengineering', false);
insert into applications values (345, 'Cornell', 'CS', true);
insert into applications values (345, 'Cornell', 'EE', false);
insert into applications values (678, 'Stanford', 'history', true);
insert into applications values (987, 'Stanford', 'CS', true);
insert into applications values (987, 'Berkeley', 'CS', true);
insert into applications values (876, 'Stanford', 'CS', false);
insert into applications values (876, 'MIT', 'biology', true);
insert into applications values (876, 'MIT', 'marine biology', false);
insert into applications values (765, 'Stanford', 'history', true);
insert into applications values (765, 'Cornell', 'history', false);
insert into applications values (765, 'Cornell', 'psychology', true);
insert into applications values (543, 'MIT', 'CS', false);
