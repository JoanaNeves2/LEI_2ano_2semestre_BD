alter session set current_schema = candidaturas;

--ex.1
select nome,mediasec from candidatos;

--ex.2
select count (*) from candidatos;

--ex.3
select avg(mediaSec)/10
from candidatos;
--ou mais completo--
select avg(mediaSec)/10
from candidatos, colocacoes
where estab = 0903;

--ex.4
select count(distinct escola)
from candidatos;
--ou mais completo--
select count(distinct escola)
from candidatos, colocacoes
where estab = 0903;

--ex.5
select sexo, count (sexo) as nCandiidatos
from candidatos 
group by sexo;

--ex.6
select count (distinct idcandidato) 
from alunosexames 
where fase = 2 and ano = 2022;

--ex.7
select count(distinct curso), sum(vagas)
from ofertas
where estab = 0903;

--ex.8
(select idcandidato from candidaturas where estab = 0902)
intersect
(select idcandidato from candidaturas where estab = 0903);

--ex.9
select max(notaCand)
from candidaturas
where estab = 0903;

--ex.10
(select idcandidato from candidatos)
minus
(select idcandidato from colocacoes );

--ex.11
select nome, nomeEscola
from candidatos, escolas
where candidatos.escola = escolas.escola;

-- ou
select nome, nomeEscola
from candidatos inner join escolas using (escola);

-- ou
select nome, nomeescola
from candidatos inner join escolas on (candidatos.escola = escolas.escola);

-- mas não:
select nome, nomeescola
from candidatos natural join escolas;

--ex.12
select nome, nomeEscola, descrConcelho
from escolas 
            natural join candidatos 
            natural join concelhos;
--ou--
select nome, nomeEscola, descrConcelho
from candidatos inner join escolas using (escola, distrito, concelho)
                inner join concelhos using (distrito, concelho);

--ex.13
select nomeCurso, nomeEstab, ordem, notaCand
from candidaturas 
                natural join cursos 
                natural join estabelecimentosSup
where idcandidato = 117454
order by ordem;
--ou-- solucao do prof
select ordem, nomecurso, nomeestab, notacand
from candidaturas
                inner join estabelecimentosSup using (estab)
                inner join cursos using (curso)
where idcandidato = 117454
order by ordem;

--ex.14
select nomeCurso, nomeEstab, ordem, notaCand, nome
from candidatos 
    inner join candidaturas using (idcandidato) 
    inner join cursos using (curso)
    inner join estabelecimentosSup using (estab)
where nome like 'JOANA S. N.%'
order by ordem;

--ex.15
select nomeexame, ano, fase
from alunosexames inner join exames using (exame)
where idcandidato = 117454;
--ou-- solucao do prof
select nomeexame, ano, fase
from alunosexames natural join exames
where idcandidato = 117454;
--e eu?--
select nomeexame, ano, fase
from alunosexames 
    inner join exames using (exame)
    inner join candidatos using (idcandidato)
where nome like 'JOANA S. N.%';

--ex.16
select nome, nomecurso, nomeestab
from colocacoes 
    inner join candidatos using (idcandidato)
    inner join estabelecimentossup using (estab)
    inner join cursos using (curso)
where nome like '%AFONSO%';

--ex.17
select nomecurso, avg(mediaSec)/10 media
from candidatos 
    inner join candidaturas using (idcandidato)
    inner join cursos using (curso)
where estab = 0903
group by nomeCurso;

--ex.18
select nomecurso, count(distinct escola)
from candidatos
    inner join candidaturas using (idcandidato)
    inner join cursos using (curso)
where estab = 0903
group by nomecurso;

--ex.19
select conting, descrconting, count(distinct idcandidato)
from colocacoes 
    inner join contingentes using (conting)
group by conting, descrconting;

--ex.20
select nomecurso, avg(mediasec)/10 media
from candidatos
                inner join colocacoes using (idcandidato)
                inner join cursos using (curso)
where estab = 0903
group by nomecurso;
