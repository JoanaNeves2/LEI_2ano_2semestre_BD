-- Ficha 3
-- Proposta de solução

-- Para aceder na sessão as tabelas do utilizador candidaturas
alter session set current_schema = candidaturas;

-- 1
-- Quais o nomes e médias do secundário dos vários candidatos 
-- ao ensino superior?
select nome, mediaSec from candidatos;

-- 2
-- Quantos alunos se candidataram a cursos da FCT (ou seja, quantos candidatos há na base de dados)?
select count(*)
from candidatos;

-- 3.
-- Qual a média das médias do secundário de todos os candidatos à FCT?
select avg(mediaSec)/10
from candidatos;

-- 4.
-- De quantas escolas secundárias diferentes houve candidatos à FCT?
select count(distinct escola)
from candidatos;

-- 5.
-- Quantos alunos e quantas alunas se candidataram à FCT?
select sexo, count(*) as nCandidatos
from candidatos
group by sexo;

-- 6
-- Quantos candidatos realizaram algum exame da segunda fase em 2022?
select count(distinct idcandidato) 
from alunosexames
where ano=2022 and fase=2;


-- 7
-- Qual o número de cursos que a FCT oferece e qual o número total de vagas nestes cursos, sabendo que o identificador da FCT NOVA é 0903?
select count(*) nCursos, sum(vagas) nVagas 
from ofertas 
where estab = '0903';

-- 8
-- Quais os candidatos (basta apresentar os ids) candidataram-se a cursos da FCSH e da FCT, sabendo que os identificadores são 0902 e 0903 respetivamente?
(select idcandidato 
from candidaturas 
where estab = '0902')
intersect
(select idcandidato 
from candidaturas 
where estab = '0903');

-- 9
-- Qual é a nota de candidatura mais alta aos cursos da FCT?
select max(notacand) 
from candidaturas 
where estab = '0903';

--10
-- Quais os candidatos (basta apresentar os ids) que não foram colocados?
(select idcandidato from candidatos)
minus
(select idcandidato from colocacoes);

-- 11
-- Para cada candidato qual o nome da escola secundária que 
-- frequentou?
select nome, nomeEscola
from candidatos, escolas
where candidatos.escola = escolas.escola;

-- ou
select nome, nomeEscola
from candidatos inner join escolas using (escola);

-- ou
select nome, nomeescola
from candidatos inner join escolas on (candidatos.escola=escolas.escola);

-- mas não:
select nome, nomeescola
from candidatos natural join escolas;

-- 12
-- Quais os candidatos que frequentaram uma escola secundária no mesmo 
-- concelho em que residiam (e qual o nome da escola e do concelho)?
select nome, nomeEscola, descrConcelho
from candidatos inner join escolas using (escola, distrito, concelho)
                inner join concelhos using (distrito, concelho);
                
--ou
select nome, nomeEscola, descrConcelho
from escolas natural join candidatos natural join concelhos;


-- 13
-- A que cursos (e onde) se candidatou o candidato com identificador 117454, 
-- dizendo para cada curso a ordem em que o colocou e a média de candidatura? 
select ordem, nomeCurso, nomeEstab, notaCand
from candidaturas inner join estabelecimentosSup using (estab)
                  inner join cursos using (curso)
where idCandidato = 117454
order by ordem;

-- 14
-- Relembre a que curso é que você se candidatou?
select ordem, nomeCurso, nomeEstab, notaCand
from candidatos inner join candidaturas using (idCandidato)
                inner join estabelecimentosSup using (estab) 
                inner join cursos using (curso)
where nome = 'META AQUI O SEU NOME ou JOAO M. A. G.'
order by ordem;

-- 15
-- ﻿Que exames fez o candidato com o identificador 117454?
select nomeExame, ano, fase
from alunosExames natural join exames
where idCandidato = 117454;

-- ﻿Já agora, relembre os exames que fez.
select nomeExame, ano, fase
from candidatos inner join alunosExames using (idCandidato)
                inner join exames using (exame)
where nome = 'META AQUI O SEU NOME ou JOAO M. A. G.';

-- 16
-- Onde ficaram colocados os candidatos com `Afonso' no nome?
select nome, nomeCurso, nomeEstab
from colocacoes inner join candidatos using (idCandidato)
                inner join cursos using (curso)
                inner join estabelecimentosSup using (estab)
where nome like '%AFONSO%';


-- 17
-- Qual a média das notas do secundário dos candidatos a cada curso da FCT, sabendo que os nomes dos cursos são todos distintos?
select nomecurso, avg(mediaSec)/10 media
from candidatos inner join candidaturas using (idcandidato)
                inner join cursos using (curso)
where estab = 903
group by nomecurso;

-- 18
-- Para cada curso da FCT, de quantas escolas secundárias diferentes houve candidatos a esse curso?
select nomeCurso, count(distinct escola)
from candidatos inner join candidaturas using (idCandidato)
                inner join cursos using (curso)
where estab = 903
group by nomeCurso;

-- 19
-- Quantos colocados houve por contingente (incluíndo os nomes dos contingentes)?
select conting, descrConting, count(*) 
from colocacoes inner join contingentes using (conting)
group by conting, descrConting;


-- 20
-- Quais as médias das notas do secundário dos candidatos colocados em cada um dos cursos da FCT, indicando o nome do curso?
-- (de notar que na FCT não há dois cursos com o mesmo nome)
select nomeCurso, avg(mediaSec)/10
from colocacoes inner join cursos using (curso)
                inner join candidatos using (idCandidato)
where estab = 903
group by nomeCurso;