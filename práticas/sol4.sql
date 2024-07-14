-- Ficha 4
-- Proposta de solução

-- Para aceder na sessão as tabelas do utilizador candidaturas
alter session set current_schema = candidaturas;


-- 1.
-- De quantas escolas do país não houve candidatos à FCT?
with Houve as
  (select count(distinct escola) as N from candidatos),
  Todas as
  (select count(*) as T from escolas)
select T-N
from Houve, Todas;

-- ou
with todasEscolas as
  (select distinct escola from candidatos)
select count(*)
from escolas left join todasEscolas on (escolas.escola = todasEscolas.escola)
where todasEscolas.escola is null;

-- ou - mais simples, já que para filtrar pelos nulls não precisamos escolas distintas
select count(*)
from escolas left join candidatos on (escolas.escola = candidatos.escola)
where candidatos.escola is null;

-- ou ainda
select count(*)
from escolas
where escola not in (select escola from candidatos);

-- ou ainda
select count(*)
from ((select escola from escolas) minus (select escola from candidatos));
    
    
 -- 2.
-- Quantos candidatos há de cada uma das escolas (em que houve candidatos), ordenado da escola com mais candidatos para a escola com menos?
select nomeEscola, quantos
from escolas inner join (	select escola, count(*) as quantos
							from candidatos
							group by escola)
			using (escola)
order by quantos desc;


-- 3.
-- Para cada escola do país, quantos candidatos houve à FCT vindos dessa escola?
-- Para as escolas em que não houve candidatos, o nome da escola deve aparecer na mesma, mas com null no número de candidatos.
select nomeEscola, quantos
from escolas left join (	select escola, count(*) as quantos
							from candidatos
							group by escola)
			using (escola)
order by quantos desc nulls last;


-- 4.
-- Quais os candidatos colocados em Informática na Nova, e para cada um deles 
-- o seu nome, a média de candidatura, a média do secundário, a ordem de 
-- preferência, e a escola secundária que frequentaram?
select nome, notaCand, mediaSec, ordem, nomeEscola
from candidatos inner join escolas using (escola)
                inner join candidaturas using (idCandidato)
                inner join colocacoes using (idCandidato, estab, curso)
                inner join cursos using (curso)
                inner join estabelecimentosSup  using (estab)
where nomeCurso like '%Informática%' and nomeEstab like '%Universidade Nova%';

-- 5.
-- Quais os seus colegas do secundário que foram colocados na FCT 
-- (estabelecimento 903), e em que curso?
 select nome, nomeCurso
 from candidatos inner join colocacoes using (idCandidato)
                 inner join cursos using (curso)
                 inner join escolas using (escola)
 where nomeEscola like '%Stuart Carvalhais%' and estab = 903;
 -- Escola de exemplo. Deve meter a sua escola do secundário
      

-- 6.
-- Quais os candidatos colocados na Nova que não entraram num curso de 
-- Engenharia, mostrando para cada um deles em que curso entraram?
select nome, nomeCurso
from candidatos inner join colocacoes using (idCandidato)
                inner join cursos using (curso)
                inner join estabelecimentosSup  using (estab)
where nomeEstab like '%Universidade Nova%' and nomeCurso not like 'Engenharia%';

-- 7.
-- Quais os colocados deslocados (i.e. residentes num distrito diferente 
-- daquele em que se situa o estabelecimento de ensino superior onde foram 
-- colocados). Para cada um deles, mostre o nome, o distrito onde foram 
-- colocados, e o distrito onde residem. .
select nome, Col.descrDistrito as Colocado, Res.descrDistrito as Residente
from candidatos inner join colocacoes using (idcandidato)
                inner join estabelecimentossup using (estab)
                inner join distritos Res on (candidatos.distrito=Res.distrito)
                inner join distritos Col on (Col.distrito=estabelecimentossup.distrito)            
where candidatos.distrito != estabelecimentossup.distrito;



-- 8.
-- ﻿Quais os cursos do estabelecimento 903 (a FCT) que tiveram colocados que 
-- fizeram exame de Geometria Descritiva A?
select distinct nomeCurso
from colocacoes inner join alunosExames using (idCandidato)
                inner join exames using (exame)
                inner join cursos using (curso)
where nomeExame = 'Geometria Descritiva A' and estab = 903;

-- 9.
-- ﻿Quais os cursos do estabelecimento 903 (a FCT) que tiveram colocados 
-- que fizeram exame de Geometria Descritiva A, e que também tiveram 
-- colocados que fizeram algum exame de História?
(select nomeCurso
from colocacoes inner join alunosExames using (idCandidato)
                inner join exames using (exame)
                inner join cursos using (curso)
where nomeExame = 'Geometria Descritiva A' and estab = 903)
intersect
(select nomeCurso
from colocacoes inner join alunosExames using (idCandidato)
                inner join exames using (exame)
                inner join cursos using (curso)
where nomeExame like '%História%' and estab = 903);

-- 10.
-- ﻿Quais os cursos do estabelecimento 903 (a FCT) que tiveram colocados 
-- que fizeram exame de ﻿Geometria Descritiva e algum exame de História?
select distinct nomeCurso
from colocacoes      inner join alunosExames on 
						(colocacoes.IDCANDIDATO = alunosExames.IDCANDIDATO)
                     inner join exames using (exame),
     colocacoes ColM inner join alunosExames examesM on 
     					(ColM.IDCANDIDATO = examesM.IDCANDIDATO)
                     inner join exames ExM using (exame),
    cursos
where exames.nomeExame = 'Geometria Descritiva A' 
	and ExM.nomeExame like '%História%' 
	and colocacoes.estab = 903 and ColM.estab = 903
	and colocacoes.idCandidato = ColM.idCandidato
    and cursos.curso = colocacoes.curso;
    
    

-- 11.
-- Quais as escolas do distrito de Setúbal que tiveram mais de 30 candidatos à FCT?
-- Para simplificar, pode assumir que não há duas escolas no distrito de Setúbal com o mesmo nome.
select nomeEscola
from escolas inner join candidatos using (escola)
             inner join distritos on (escolas.distrito = distritos.distrito)
where descrDistrito like 'Setúbal'
group by nomeEscola
having count(*) > 30;


-- 12.
-- Qual o nome do candidato à FCT com maior média do secundário, e qual essa média? 
select nome, mediaSec/10
from candidatos, (select max(mediaSec) as mediaMax from candidatos) A
where A.mediaMax = mediaSec;

-- ou
select nome, mediaSec/10
from candidatos
where mediaSec = all (select max(mediaSec) from candidatos);

-- ou
select nome, mediasec/10
from candidatos 
where mediaSec in (select max(mediaSec) from candidatos);



-- 13.
-- Qual a nota mínima dos colocados no contingente geral em cada dos cursos da FCT (a que é anunciada nos jornais como nota do último colocado)?
select nomeCurso, min(notacand)/10 as ultimo
from contingentes inner join colocacoes using (conting)
                  inner join candidaturas using (idCandidato, estab, curso)
                  inner join cursos using (curso)
where estab = 903 and descrConting = 'Geral'
group by nomeCurso;


-- 14.
-- Quais as nomes, e respetivas médias do secundário, dos candidatos não colocados?
select candidatos.nome, candidatos.mediaSec/10
from candidatos left join colocacoes on (candidatos.idCandidato = colocacoes.idCandidato)
where colocacoes.idCandidato is null;

-- ou
select nome, mediaSec/10
from candidatos
where idCandidato not in (select idCandidato from colocacoes);


-- 15.
-- Quais os cursos da FCT que tiveram candidatos de escolas todos os distritos?
select nomeCurso
from cursos
where
	not exists
  ((select distrito from distritos)
    minus
    (	select distinct escolas.distrito
		from candidatos inner join escolas using (escola) 
                        inner join candidaturas using (idcandidato)
		where cursos.curso = candidaturas.curso and estab = 903
	  )
  );

-- ou
select nomeCurso
from candidatos inner join escolas using (escola)
	inner join candidaturas using (idcandidato)
  inner join cursos using (curso)
where estab = 903
group by nomeCurso
having count(distinct escolas.distrito)
          = some (select count(*) from distritos);

-- ou ainda, usando diretamente a definicao do operador de divisao

select distinct nomeCurso        -- Todos os cursos da FCT
from cursos natural join ofertas
where estab = 903

minus

select nomeCurso      -- Curso que nao tem candidatos de todos os distrito
from
(
  ( select distrito, nomeCurso         -- Todos os pares possiveis, com curso da FCT e distrito
    from distritos,
      ( select distinct nomeCurso       
        from cursos natural join ofertas
        where estab = 903)
  )
  minus
  ( select distinct escolas.distrito, nomeCurso -- Pares distrito-curso, em que ha um candidato desse distrito a esse curso
    from candidatos inner join escolas using (escola)
      inner join candidaturas using (idcandidato)
      inner join cursos using (curso)
    where estab = 903
  )
);





-- 16.
-- Para cada cursos da FCT, qual a percentagem de raparigas colocadas?

select nomeCurso, 100*raparigas/(raparigas+rapazes) as percentagemMulheres
from cursos inner join 
	(select curso, count(*) rapazes
	from colocacoes natural join candidatos
	where estab = 903 and sexo = 'M'
	group by curso) Rapazes using (curso)
	inner join
	(select curso, count(*) raparigas
	from colocacoes natural join candidatos
	where estab = 903 and sexo = 'F'
    group by curso) Raparigas using (curso)
order by percentagemMulheres;
    
-- 17.
-- Para cada curso da FCT, qual a média das notas de candidatura dos alunos que foram 
--  colocados nesse curso e que repetiram o exame Matemática A?
select nomeCurso, avg(notacand)/10
from cursos inner join 
     (select idCandidato, curso, estab
	  from alunosExames inner join colocacoes using (idCandidato)
                        inner join exames using (exame)
	  where nomeExame = 'Matemática A' and estab = 903
	  group by idCandidato, curso, estab
      having count(*) > 1) repet using (curso)
            inner join candidaturas using (idcandidato,curso,estab)
group by nomeCurso;

-- 18.
-- Qual a taxa de aceitação de cada curso da FCT, isto é, qual é a proporção entre 
-- o número de candidaturas e o número de vagas de cada curso? 
-- Para cada curso, para além do seu código, nome e taxa de aceitação, 
-- queremos também saber o número de vagas e o número de candidatos.        
with numCandidatos as
( select curso, count(*) as quantos from candidaturas.candidaturas where estab='0903' group by curso
)
select curso,nomecurso, vagas, quantos, vagas*100/quantos as acceptance_rate
from candidaturas.cursos inner join candidaturas.ofertas using (curso)
            inner join numCandidatos using (curso)
where estab='0903'
order by acceptance_rate;
