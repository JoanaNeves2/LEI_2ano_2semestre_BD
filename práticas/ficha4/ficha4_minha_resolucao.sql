alter session set current_schema = candidaturas;

--ex.1
select count (escola)
from(
    select distinct escola
    from escolas
    minus
    select distinct escola
    from candidatos inner join escolas using (escola));
    
--ex.2
select nomeescola, escola, count (idcandidato) as totalcandidatos
from candidatos inner join escolas using (escola)
group by nomeescola, escola
order by totalcandidatos desc;

--ex.3
select nomeescola, count(idcandidato) as total
from escolas left join candidatos using (escola)
group by nomeescola
order by total desc nulls last;

--ou--
with contagem as
    (select escola, count(*) as n
    from candidatos 
    group by escola)
select nomeescola, n
from escolas left join contagem using (escola)
order by n desc nulls last;

--ex.4
select nome, notacand, mediasec, ordem, nomeescola
from candidatos 
                inner join colocacoes using (idcandidato)
                inner join escolas using (escola)
                inner join candidaturas using (idcandidato, curso, estab)
                inner join cursos using (curso)
where nomecurso like '%Informática%' and estab=0903;

--ex.7
with distrC as
    (select idcandidato, descrdistrito
    from candidatos inner join distritos using (distrito)),
distrR as
    (select estab, descrdistrito
    from estabelecimentossup
                    inner join distritos using (distrito))
select nome, distrR.descrdistrito, distrC.descrdistrito
from colocacoes
                inner join candidatos using  (idcandidato)
                inner join distrR using (estab)
                inner join distrC using (idcandidato)
where distrC.descrdistrito <> distrR.descrdistrito;

--ex.11
select distinct nomeescola
from (
    select nomeescola, count(idcandidato) 
    from escolas 
            inner join distritos using (distrito)
            inner join candidatos using (escola)
            inner join candidaturas using (idcandidato)
    group by nomeescola
    having count(idcandidato) > 30)
where estab=0903 and descrdistrito = 'Setúbal';

select nomeescola
from candidaturas 
                inner join candidatos using (idcandidato)
                inner join escolas using (escola)
                inner join distritos using (distrito)
where estab=0903 and descrdistrito = 'Setúbal'
having count(idcandidato)>30;


select nomeEscola
from escolas inner join candidatos using (escola)
             inner join distritos on (escolas.distrito = distritos.distrito)
where descrDistrito like 'Setúbal'
group by nomeEscola
having count(*) > 30;


--ex.12


--ex.14

--ex.15


--ex.16