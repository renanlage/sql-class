# SQL Class

### SGBD
- Armazenamento e acesso eficiente, confiável, prático, seguro e multi-usuário à quantidades massivas de dados persistidos:
  - Massivo -> desenvolvido para lidar com dados que não residem em memória
  - Persistente -> Dados vivem fora do programa que os gerou
  - Seguro -> Garantias de que os dados vão se manter consistentes, não vão ser perdidos ou sobrescritos em caso de falhas.
  - Multi-usuário -> Controle de concorrência. Muitos usuários podem operar no banco de dados ao mesmo tempo
  - Praticidade -> Independência dos dados físicos. As operações em cima dos dados não dependem de como os dados são guardados fisicamente. Linguagem declarativa para consultas. Você diz o que quer e o sistema decide qual a melhor forma ou algoritmo pra buscar.
  - Eficiente -> Milhares de leituras e escritas por segundo
  - Confiabilidade -> 99.99999% uptime guarantees

### Conceitos chave:
- Modelo de dados -> Como os dados são estruturados
  - Conjunto de registros
  - documentos XML/JSON
  - Grafos
- Schema vs dados
  - Tipos vs variáveis
- Data definition language (DDL)
  - Define o schema
- Data manipulation or query language (DML)
  - Consulta e modifica os dados

### Pessoas chave:
- Database designer -> Define os schemas
- Database application developer -> Programas que operam no BD
- Database administrator -> Sobe o SGBD e mantém ele rodando suavemente

### Modelo relacional
- Tem mais de 35 anos e é a fundação sobre a qual os SGBDs são construídos sobre.
- Usado por todos os grandes sistemas de banco de dados
- Simples
- Consultas com linguagens de alto nível
- Implementações eficientes

*Excel*
- Planilha
- Colunas
- Linhas

*Banco de dados*
- Conjunto de relações nomeadas (tabelas)
- Cada relação tem um conjunto de atributos nomeados (campos)
- Cada tupla da tabela tem um valor para cada um dos atributos (registro)
- Cada atributo tem um tipo

Schema: descrição estrutural das relações em um banco de dados, tabelas, colunas e seus tipos
Instância: o conteúdo de fato em um dado momento (linhas)

NULL: valor especial para indicar que o valor é não definido ou não sabido. Comparações com NULL sempre retornam falso

### Chave
Coluna cujo valor é único e identifica um registro. Usos:
- Buscar um registro específico
- Quando uma tabela quer referenciar registros de outra tabela, isso é feito através da chave

### Criando relações em SQL:

CREATE TABLE students(student_id, name, grade);

Passos para criar e usar um banco de dados relacional:
1) Desing do Schema; Criado com uma DDL
2) Insere dados
3) Executa consultas e modifica os dados

Queries (consultas) são escritas sobre demanda e numa linguagem declarativa de alto nível
- Sobre demanda: Você não precisa escrever grandes programas para montar uma query ou cadastrar elas previamente no banco de dados
- Declarativa de alto nível: você não descreve como o banco de dados deve buscar os dados ou qual algoritmo deve ser usado. Você apenas diz o que quer.

Algumas queries são fáceis de escrever.
Algumas queries são fáceis do SGBD executar.
As 2 afirmações não estão correlacionadas.

Query language também é usada para modificar dados.

Linguagens de queries:

- Álgebra relacional (formal)
- SQL (implementação)

"S.Q.L" or "sequel"
- Suportado por todos os maiores BDs comerciais e opensource
- Interativo via GUI ou CLI
- Padronizado -> novas features com o tempo
- Declarativo, baseado em álgebra linear

Query optimizer
- Pega a query e decide a melhor forma de executar ela no banco de dados

DDL
CREATE TABLE
DROP TABLE
...

DML
SELECT
INSERT
DELETE
UPDATE

Outros commands
índices, constraints, views, triggers, transactions, authorization, ...

Consultas básicas seguem o formato:
```sql
SELECT c1,c2,...
FROM t1,t2,...
WHERE condition
```

```sql
-- Selecionando todos os registros de uma tabela
select students.student_id, students.student_name, students.grade, students.high_shool_size
from students;
-- Alternativa pra trazer todas as colunas com *
select *
from students;

-- Selecionando estudantes e seus cursos
select student_name, course
from students, applications
where students.student_id = applications.student_id;

-- Tem itens duplicados, removendo com distinct
select distinct student_name, course
from students, applications
where students.student_id = applications.student_id;

-- SELECT com FILTROS
-- aplicações de estudantes para curso CS, de Stanford e de escolas pequenas
select distinct student_name, grade, accepted
from students, applications
where students.student_id = applications.student_id
  and high_school_size < 1000 and course = 'CS' and college_name = 'Stanford';

-- Filtrando por escolas caras
select college_name
from colleges, applications
where colleges.college_name = applications.college_name
  and price >= 2000 and course='CS';

-- Dá erro porque a coluna é ambigua
-- Precisamos adicionar nome da tabela quando um campo existe em 2 tabelas da query
select colleges.college_name
from colleges, applications
where colleges.college_name = applications.college_name
  and price > 2000 and course='CS';

-- order by
-- SQL não tem uma ordem pré definida. Precisa ser explícito
-- Ordenando aplicações por nota
select students.student_id, students.student_name, students.grade, applications.college_name, price
from students, applications, colleges
where
  students.student_id = applications.student_id
  and colleges.college_name = applications.college_name
order by grade;

-- por nota e preço
select students.student_id, students.student_name, students.grade, applications.college_name, price
from students, applications, colleges
where
  students.student_id = applications.student_id
  and colleges.college_name = applications.college_name
order by grade desc, price asc;

-- like

select student_id, course
from applications
where course like '%bio%';

-- aritmética
-- modificando a nota pra ser multiplicada por um fator do tamanho da escola no ensino médio
select student_id, student_name, grade, high_school_size, grade * (high_school_size / 1000.0)
from students;

-- alias

select student_id, student_name, grade, high_school_size, grade * (high_school_size / 1000.0) as scaled_grade
from students;

-- variáveis de tabela

select students.student_id, students.student_name, students.grade, applications.college_name, price
from students, applications, colleges
where
  students.student_id = applications.student_id
  and colleges.college_name = applications.college_name;

select s.student_id, s.student_name, s.grade, a.college_name, price
from students s, applications a, colleges c
where
  s.student_id = a.student_id
  and c.college_name = a.college_name;

-- Estudantes com a mesma nota

select s1.student_id, s1.student_name, s1.grade, s2.student_id, s2.student_name, s2.grade
from students s1, students s2
where
  s1.grade = s2.grade;

-- excluindo os próprios estudantes
select s1.student_id, s1.student_name, s1.grade, s2.student_id, s2.student_name, s2.grade
from students s1, students s2
where
  s1.grade = s2.grade and s1.student_id <> s2.student_id;

-- removendo comparações duplicadas
select s1.student_id, s1.student_name, s1.grade, s2.student_id, s2.student_name, s2.grade
from students s1, students s2
where
  s1.grade = s2.grade and s1.student_id < s2.student_id;

-- Operadores de conjunto
-- Operadores de conjuntos: união, interseção e diferença

-- UNION
-- Por padrão elimina duplicados. Dependendo do banco usado, o resultado do UNION pode vir ordenado. O SQLite por exemplo elimina duplicados ordenando o resultado
select college_name from colleges
union
select college_name from students;

-- O conjunto tem elementos únicos
-- se não queremos elementos únicos:
select college_name as name from colleges
union all
select college_name as name from students;

-- ordenando
select college_name as name from colleges
union all
select college_name as name from students
order by name;

-- INTERSECT
-- Só são retornados registros retornados pelas 2 relações
select student_id from applications where course='CS'
intersect
select student_id from applications where course='EE';

-- Outros modos de fazer essa query:
select distinct a1.student_id
from applications a1, applications a2
where a1.student_id = a2.student_id and a1.course = 'CS' and a2.course='EE';

-- Ignorar por enquanto
-- Mas pode ser feito com group by
select student_id
from applications
where course in ('CS', 'EE')
group by student_id
having count(distinct course) = 2;

-- EXCEPT (diferença)
select student_id from applications where course = 'CS'
except
select student_id from applications where course = 'EE';

-- Subquery como alternativa de join
-- where id in (subquery)

-- Estudantes que aplicaram para CS
select student_id, student_name
from students
where student_id in (select student_id from applications where course='CS');

-- Com join alguns vem duplicados porque é uma relação 1 -> N
select distinct student_id, student_name
from students, applications
where
  students.student_id = applications.student_id
  and course = 'CS';

-- Pegando os nomes
select student_name
from students
where student_id in (select student_id from applications where course='CS');

-- São retornados 2 estudantes diferentes que tem o mesmo nome
-- Na versão com join + distinct a duplicada é removida
select distinct student_name
from students, applications
where
  students.student_id = applications.student_id
  and course = 'CS';

-- Exemplos onde duplicar ou não faz diferença:
-- Nota de estudantes de CS
select grade
from students
where student_id in (select student_id from applications where course='CS');

-- As duas versões com join não conseguem reproduzir o comportamento desejado da subquery
select distinct grade
from students, applications
where
  students.student_id = applications.student_id
  and course = 'CS';

select grade
from students, applications
where
  students.student_id = applications.student_id
  and course = 'CS';

-- EXCEPT com subqueries
select student_id, student_name
from students
where
  student_id in (select student_id from applications where course='CS')
  and student_id not in (select student_id from applications where course='EE');

-- EXISTS

-- Estados em que existem mais de um college
select college_name, state
from college c1
where exists (select * from college c2 where c2.state = c1.state and c1.college_name <> c2.college_name)

-- Simulando o max() com exists
select college_name
from college c1
where not exists (select * from college c1 where c2.price > c1.price);

-- SUBQUERY no FROM

-- Trazer notas em que a diferença da escala pra nota é maior que 1
select student_id, student_name, grade, grade * (high_school_size / 1000.0) as scaled_grade
from students
where abs(grade * (high_school_size / 1000.0) - grade) > 1.0;

-- Usando subquery pra não repetir a expressão
select *
from (select student_id, student_name, grade, grade * (high_school_size / 1000.0) as scaled_grade from students) S
where abs(S.scaled_grade - S.grade) > 1.0;

-- Subquery no select
-- Estudantes e suas maiores notas
select s1.student_name, (select grade from students s2 where s2.student_id = s1.student_id order by grade desc limit 1)
from students s1;

-- Os diferentes tipos de JOIN
-- Até então foi usado cross join implícito ao separar as tabelas por "," no from

-- Exemplo de cross join explícito
select distinct student_name, course
from students cross join applications
where students.student_id = applications.student_id;

-- Trocando para um inner join
select distinct student_name, course
from students inner join applications
on students.student_id = applications.student_id;

-- Outro exemplo
-- Trocando:
select distinct student_name, grade, accepted
from students, applications
where students.student_id = applications.student_id
  and high_school_size < 1000 and course = 'CS' and college_name = 'Stanford';
-- Para:
select distinct student_name, grade, accepted
from students join applications on students.student_id = applications.student_id
where high_school_size < 1000 and course = 'CS' and college_name = 'Stanford';
-- Ou:
select distinct student_name, grade, accepted
from students join applications on students.student_id = applications.student_id and high_school_size < 1000 and course = 'CS' and college_name = 'Stanford';
-- A diferença é que o primeiro dá a indicação para o SGDB assumir a condição ao fazer o join
-- enquanto o segundo dá a dica para o SGDB filtrar sobre o resultado final

-- Fazendo join com mais de 2 tabelas
-- Trocando:
select students.student_id, students.student_name, students.grade, applications.college_name, price
from students, applications, colleges
where
  students.student_id = applications.student_id
  and colleges.college_name = applications.college_name;
-- Para:
select students.student_id, students.student_name, students.grade, applications.college_name, price
from students
join applications on students.student_id = applications.student_id
join colleges on colleges.college_name = applications.college_name;
-- Trocar a ordem dos joins pode alterar a performance da query
-- teoricamente não deveria acontecer mas acontece

-- Outer join
select student_name, student_id, college_name, course
from students left outer join applications using(student_id);

-- Como fazer o outer join sem usar join:
select student_name, student_id, college_name, course
from students left outer join applications using(student_id);
-- Para:
select student_name, student_id, college_name, course
from students, applications
where students.student_id = applications.student_id
union
select student_name, student_id, null, null
from students
where student_id not in (select student_id from applications);

-- Agregações
-- Computações em cima de conjuntos de valores em múltiplos registros
-- agregações básicas: min, max, sum, avg, count
-- 2 cláusulas novas: group by e having
-- group by: particiona tabelas em grupos e então computa funções de agregação em cada grupo individualmente
-- having: permite o uso de filtros nos resultados de valores agregados

-- Média de notas
select avg(grade) from students;

-- Nota mínima de estudantes de CS
select min(grade)
from students join applications (student_id)
where major = 'CS';

select avg(grade)
from students join applications (student_id)
where major = 'CS';
-- O problema dessa média é que a gente só quer contar a nota uma vez independentemente de para quantas universidade o estudante aplicou:
select avg(grade)
from students
where student_id in (select student_id from applications where course='CS');

-- Conta número de faculdades caras
select count(*)
from applications
where price > 15000;

-- Conta número de estudantes que aplicaram para Cornell
select count(*)
from applications
where college_name = 'Cornell';
-- Acima o resultado do count(*) conta um estudante que aplicou 3 vezes pra Cornell
select count(*)
from applications
where college_name = 'Cornell';
-- Pra distinguir por estudante:
select count(distinct student_id)
from applications
where college_name = 'Cornell';

-- Diferença entre notas de estudantes de CS e outros
select cs.avg_grade - non_cs.avg_grade as grade_diff
from (
  select avg(grade) as avg_grade
  from students where student_id in (
    select student_id from applications where course = 'CS'
  )
) as cs,
(
  select avg(grade) as avg_grade
  from students where student_id in (
    select student_id from applications where course != 'CS'
  )
) as non_cs;

-- Fazendo a diferença no select
select (
  select avg(grade) as avg_grade
  from students where student_id in (
    select student_id from applications where course = 'CS'
  )
) - (
  select avg(grade) as avg_grade
  from students where student_id in (
    select student_id from applications where course != 'CS'
  )
) as grade_diff;

-- Agregações em cima de grupos
-- Primeiro pode-se ordenar por nome do college pra ver os grupos
select college_name, count(*)
from applications
group by college_name;

select state, sum(enrollment)
from colleges
group by state;

-- Group by com 2 atributos
-- Nota mínima e máxima pra
select college_name, course, min(grade), max(grade)
from students join applications using (student_id)
group by college_name, course;

-- Número de colleges aplicados por cada estudante
select students.student_id, count(distinct college_name)
from students join applications using (student_id)
group by students.student_id;

-- having
select college_name
from applications
group by college_name
having count(distinct student_id) < 5;

-- Cursos em que a nota máxima é menor do que a média geral de notas
select course
from students join applications using (student_id)
group by course
having max(grade) < (select avg(grade) from applications);


-- Valores NULL

insert into students values (432, 'Pedro', null, 1500);
insert into students values (321, 'Paulo', null, 2500);

select student_id, student_name, grade
from students
where grade > 3.5;

-- Colunas null não são retornadas com comparações
select student_id, student_name, grade
from students
where grade > 3.5 or grade <= 3.5;
-- Pra retornar nulos:
select student_id, student_name, grade
from students
where grade > 3.5 or grade <= 3.5 or grade is null;

-- Se a coluna do registro que é null não estiver numa condição a linha é retornada
select student_id, student_name, grade, high_school_size
from students
where grade > 3.5 or high_school_size < 1600;

-- null com group by
select count(distinct grade)
from students
where grade is not null;
-- Vendo se o null é contado na agregação
-- não é
select count(distinct grade)
from students;
-- mas ao selecionar os valores sem agregação ele é retornado
select distinct(grade)
from students;
```

Modificadando dados (escrita):
```sql
-- Inserindo dados
insert into some_table (c1,c2,c3) values (v1,v2,v3);

insert into some_table (c1,c2,c3)
select statement

-- Deletando dados
delete from table where condition

-- Update
update table
set
  c1 = expression1,
  c2 = expression2
where condition

-- Exemplo de insert com select
-- Aplicando quem não tem inscrição na Carnegie mellon
insert into applications
select student_id, 'Carnegie Mellon', 'CS', null
from students
where student_id not in (select student_id from applications)
-- alternativa com join:
insert into applications
select s.student_id, 'Carnegie Mellon', 'CS', null
from students s left join applications a on s.student_id = a.student_id
where a.student_is is null;

-- Deletando estudantes que se inscreveram para mais de 2 faculdades
-- primeiro selecionando:
select student_id, count(*)
from applications
group by student_id
having count(distinct course) > 2;
-- deletando:
delete from students
where student_id in (
  select student_id
  from applications
  group by student_id
  having count(distinct course) > 2
);
-- deletando do applications
delete from applications
where student_id in (
  select student_id
  from applications
  group by student_id
  having count(distinct course) > 2
);

-- atualiza nota para máxima e tamanho da escola para o minimo
update students
set
  grade = (select max(grade) from students),
  high_school_size = (select min(high_school_size) from students);

-- aprova todo mundo
update students
set accepted = true;
```
