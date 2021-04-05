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
```
