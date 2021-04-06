# Índices

- Mecanismo principal para obter ganhos de performance num BD
- Estrutura de dados persistida no BD

## Funcionalidade

### Tabela T
|    | A   | B   | C   |
| -- | --- | --- | --- |
| 1  | cat | 2   | ... |
| 2  | dog | 5   | ... |
| 3  | cow | 1   | ... |
| 4  | dog | 9   | ... |
| 5  | cat | 2   | ... |
| 6  | cat | 8   | ... |

Em uma consulta em que T.A = 'cow'. Caso exista um índice em T.A, o índice é capaz de retornar os registros que tem T.A = 'cow' sem percorrer a tabela inteira.

A decisão de usar ou não um índice para fazer a consulta é do query planner e não do desenvolvedor.

Um índice pode ser usado para consultas ainda mais complexas. Por exemplo, um índice em T.B pode retornar registros que satisfazem as condições abaixo sem percorrer a tabela sequencialmente:
T.B = 2
T.B < 6
T.B > 4 and T.B <= 8

Caso existam condições em cima de 2 campos, pode-se criar um índice em cima de 2 campos T.(A,B). Exemplos de consultas que usuariam o índice:
T.A = 'cat' and T.B > 5
T.A < 'b' and T.B = 1

Utilidades:
- Diferença entre percorrer uma tabela inteira (full table scan) e localizar os registros quase imediatamente. Pode trazer ganhos de performance com ordens de grandeza de diferença.
- Estruturas de dados subjacentes:
  - Balanced trees (B trees, B+ trees) -> O(log n)
    - `< <= = >= >`
    - Permite índices compostos
    - Pode ser usado para ordenação
    - Permite constraints unique nos índices
  - Hash tables -> O(1)
    - `=`
    - Não permite índices compostos
    - Não pode ser usado para ordenação
    - Não permite criação de índices unique

Mais informaçṍes: https://www.postgresql.org/docs/13/indexes.html

Índices unique são criados para primary keys automaticamente
Índices não são criados para foreign keys

Índice composto:
- A ordem das colunas em um índice composto importa
- Um índice com 3 colunas pode ser usado para buscar pela primeira coluna, pela primeira e segunda coluna juntas, e quando buscando pelas 3 colunas juntas
- O banco considera a ordem das colunas na hora de criar as árvores ordenadas, considerando a ordenação sempre da esquerda para direita nas colunas. Então o ideal é usar primeira as colunas com mais seletividade, ou seja, que eliminam uma quantidade maior de valores.

Mais informações: https://use-the-index-luke.com/sql/where-clause/the-equals-operator/concatenated-keys


Um índices

```sql
select student_id
from students
where student_name = 'Mary' and grade > 3.9
```

Podemos ter um índices em `student_name`
Ou um índice em `grade`
Ou nos dois campos

```sql
select student_name, college_name
from students s
join applications a on s.student_id = a.student_id
```

Se existe um índice em um dos student_id ele pode ser usado varrendo a outra tabela e achando registros relacionados. Ou ainda, se existirem índices nos 2 campos, ele pode ser usado com uma operação de merge de índices caso eles sejam ordenados.

Isso é responsabilidade da área de planning e otimização de queries no banco de dados.

```sql
select *
from applications a
join colleges c on a.college_name = c.college_name
where a.course = 'CS' and c .price < 5000
```
Qual índice não seria útil pra otimizar essa query?
1) Tree-based index on applications.college_name
2) Hash-based index on applications.course
3) Hash-based index on colleges.price
4) Hash-based index on colleges.college_name

Resposta = 3

```sql
select *
from applications a
join colleges c on a.college_name = c.college_name
join students s on a.student_id = s.student_id
where s.grade > 1.5 And c.college_name < 'Cornell'
```
Supondo que podemos criar 2 índices e que todos os índices são B-trees. Quais 2 índices seriam a melhor escolha aqui?
1) students.student_id, colleges.college_name
2) students.student_id, students.grade
3) applications.college_name, colleges.college_name
4) applications.student_id, students.grade

Resposta = 1)

Desvantagens dos índices:
1) Ocupa espaço extra - marginal
2) Criação do índice é custosa - mediana
3) Manutenção do índice - grande. Mudanças em campos indexados requerem uma atualização do índice.

Benefícios dos índices dependem de:
1) Tamanho da tabela
2) Distribuição dos dados
3) Quantidade de consultas vs updates

Query optimizer recebe como input:
- Estatísticas do banco
- Consulta ou update
- Índices
E retorna o melhor plano de execução para uma query com seu custo estimado

Para escolher um índice a gente deve olhar o plano de execução que é usado na query e compará-los com outros planos de execução com índices diferentes ou usar uma ferramenta que já sugere índices. Para ver o plano de execução de uma consulta pode ser usado a consulta `EXPLAIN ANALYZE :query`.

Sintaxe SQL
```sql
-- Em uma única coluna
create index index_name on t (a);
-- Em múltiplas colunas
create index index_name on t (a, b, c);
-- Índice único
create unique index index_name on t(a);
-- Especificando a estrutura de dados
create index index_name on t using btree (a);
-- Drop
drop index index_name;
```

Estudando planos de execução:
```sql
-- Inserindo uma quantidade muito grande de registros pro índice valer a pena
insert into students (student_id, student_name, grade, high_school_size)
select id, 'Student ' || id::text, random() * 4.0, ceil(random() * 10000)
from generate_series(1000, 500000) as s(id);

-- Rodando o explain analyze pras seguintes queries
explain analyze select student_name from students where student_id = 300000;
explain analyze select student_name from students where student_id < 300000;
explain analayze select student_name from students order by student_id;

-- Criando um índice na coluna student_id
create index students_student_id_idx on students using btree (student_id);

-- Rodando novamente
explain analyze select student_name from students where student_id = 300000;
explain analyze select student_name from students where student_id < 300000;
explain analayze select student_name from students order by student_id;

-- Testando com um índice por hash
explain analyze select student_name from students where student_id = 300000;
create index students_student_id_hash_idx on students using hash (student_id);
explain analyze select student_name from students where student_id = 300000;
```

# Transações

Motivadas por 2 requisitos independentes:
- Acesso concorrente aos dados
- Resiliência à falhas no sistema

## Acesso concorrente

Inconsistências a nível de coluna:
```sql
-- Por baixo dos panos acontece um get, modify e put:
update colleges
set price = price + 1000
where college = 'Stanford';
-- concorrendo com
update colleges
set price = price + 1500
where college = 'Stanford';
```
Quando um dos 3 cenários pode acontecer:
15000 + 2500 (se um acontece depois do outro)
      + 1000 (se um sobrescreve o outro)
      + 1500

Inconsistência a nível de registro:
```sql
update applications set course='CS' where student_id=123;
-- concorrendo com
update applications set accepted=true where student_id=123;
```

Podemos ver as 2 modificações acontecendo ou apenas uma das modificações dependendo da ordem do get, modify e put.

Inconsitências a nível de tabela:
```sql
update applications
set accepted = true
where student_id in (select student_id from students where grade > 3.9);
-- concorrendo com
update students set grade = grade * 1.1 where high_school_size > 2500;
```
Se não houver controle de concorrência, as notas podem estar sendo modificadas enquanto o update nas applications está acontecendo. Quando o desejado é que ele aconteça ou antes ou depois da modificação das notas.

Inconsistência entre statements
```sql
insert into archives
select * from applications where accepted is false;
delete from applications where accepted is false;
-- concorrendo com
select count(*) from applications;
select count(*) from archives;
```
Não queremos que o count(*) conte os itens duplicados nas 2 tabelas. A consistência nesse caso se daria se o count(*) só acontecesse antes ou depois das modificações do primeiro usuário.

### Objetivo na concorrência
Executar um sequência de queries SQL de forma que elas aparentem estar rodando de foram isolada.

Solução simples: executa elas de forma isolada.
Mas queremos usar concorrência sempre que possível.

## Resiliência à falhas
O que acontece se houver uma falha no meio de um processo demorado como bulk load ou no meio de um processo como o visto:
```sql
insert into archives
select * from applications where accepted is false;
delete from applications where accepted is false;
```
Se o processo é interrompido no meio deixamos o sistema num estado inconsistente.

### Objetivo na falha
Garantir uma execução de tudo ou nada, independentemente de uma falha.

Existe uma solução que consegue lidar com esses 2 objetivos: as transações.

## Transações
Uma sequência de uma ou mais operações SQL tratadas como uma unidade.
- Transações aparentam executar em isolamento.
- Se o sistema falha, ou acontecem todas as mudanças de uma transação ou nenhuma.

SQL:
No Postgres começa com BEGIN e termina com um COMMIT ou ROLLBACK.

### Propriedades

ACID
- Atomicidade
- Consistência
- Isolamento
- Durabilidade

Isolamento
Serializabilidade
As operações podem ser intercaladas, mas a execução tem que ser equivalente à alguma execução sequencial de todas as transações.

Durabilidade
Se o sistema falha depois que uma transação comitou, todos os efeitos dessa transação devem permanecer no banco.

Atomicidade
Toda transação é um tudo ou nada, nunca feita pela metade.

Supondo uma tabela T(a) contendo os registros: [(5), (6) e duas transações:
```sql
update t set a = a + 1;
update t set a = a * 2;
```
Qual estado final para os registros não é possível de acontecer?
1) [(10), (12)]
2) [(11), (13)]
3) [(11), (12)]
4) [(12), (14)]

3)

Rollback (= abortar a transação)
- Desfaz efeitos parciais de uma transação
- Pode ser iniciado pelo sistema (BD) ou pelo cliente

Exemplo:
```sql
begin
<pega input do usuário>
comandos SQL baseados no input
<confirma resultado com o usuário>
se confirmado então commit; se não rollback;

-- Exemplo usando
begin;
select * from students;
update students set grade = 2 where student_id=1000;
select * from students where student_id=1000;
rollback;

select * from students where student_id=1000;
```

Apesar de válido como exemplo, esse comportamento é zero recomendado. Devemos segurar as conexões com o banco de dados o menor tempo possível.

Consistência
Em toda transaction é garantido que:
- Todas as constraints são garantidas quando a transação inicia
- Todas as constraints são garantidas quando a transaction termina

Ou seja, as constraints sempre são válidas por conta da serializabilidade.

A serializabilidade e um alto isolamento tem um overhead por conta de todos os locks e reduz a concorrência.

Então os SGBDs fornecem níveis diferentes de isolamento por ordem do mais fraco para o mais forte:
1) read uncommited
2) read commited
3) repeatable read
4) serializable

Nível de isolamento:
- Definido por transação

*Leitura suja*
Dado lido de uma transação que não foi comitada.

```sql
update students set grade = 1.1 * grade where high_school_size > 2500;

select grade from students where student_id = 123;

update students set high_school_size = 2600 where student_id = 234;
```

### Read Uncommitted
Uma transação pode fazer leituras sujas
```sql
-- T1
update students set grade = 1.1 * grade where high_school_size > 2500;
-- concorrente com T2
set transaction isolation level read uncommitted;
select avg(grade) from students;
```
A média pode ler registros modificados antes da transação comitar.

### Read Committed
Uma transação não pode fazer leituras sujas
obs: ainda não garante serializabilidade global
```sql
-- T1
update students set grade = 1.1 * grade where high_school_size > 2500;
-- concorrente com T2
set transaction isolation level read committed;
select avg(grade) from students;
select max(grade) from students;
```
O avg pode ser tomado antes do commit da primeira transação, e o max depois.

### Repeatable Read
Uma transação não pode fazer leituras sujas.
Um item lido múltiplas vezes não pode mudar de valor.
```sql
-- T1
update students set grade = 1.1 * grade;
update students set high_school_size = 1500 where student_id = 123;
-- concorrente com T2
set transaction isolation level repeatable read;
select avg(grade) from students;
select avg(high_school_size) from students;
```
A avg da nota pode acontecer antes do commit da T1, e a avg do high_school_size depois sem ser serializable e sem quebrar o repeatable read.

Phantom tuples
Apesar de um item não poder mudar de valor, itens novos inseridos na tabela podem ser lidos entre 2 statements de uma transação repeatable read.
```sql
-- T1
insert into students [100 new tuples]
-- concorrente com T2
set transaction isolation level repeatable read;
select avg(grade) from students;
select avg(grade) from students;
```

Aqui a avg pode mudar entre as 2 leituras porque registros novos não são protegidos (phantom tuples). Aparentemente isso é um detalhe de implementação que escapa porque não há como fazer lock em cima de registros novos, apenas em existentes.

Ou seja, inserções podem acontecer e vão ser refletidas em 2 leituras subsequentes de uma transação repeatable read.

Trocando o insert por delete teria um comportamento diferente porque os valores trazidos na primeira avg estão lockados e o delete só vai poder acontecer ou antes ou depois de T2.

### Resumo dos níveis de isolamento

|                 | dirty reads | nonrepeatable reads | phantoms |
| --------------- | ----------- | ------------------- | -------- |
| Read Uncommited |      S      |          S          |    S     |
| Read Commited   |      N      |          S          |    S     |
| Repeatable Read |      N      |          N          |    S     |
| Serializable    |      N      |          N          |    N     |

Default padrão do SQL: Serializable
Default do Postgresql: Read commited

Níveis mais fracos de isolamento:
- maior concorrência e menor overhead = maior performance
- garantias de consistência mais fracas

Nível de isolamento é sempre por transação e tem que ser respeitado

Garantias das transações:
- Permitem um nível de concorrência muito grande sem ter a preocupação de que as ações em cima dos dados vão afetar umas as outras de forma imprevisível.
- Permite que o BD se recupere para um estado consistente em caso de falhas.
