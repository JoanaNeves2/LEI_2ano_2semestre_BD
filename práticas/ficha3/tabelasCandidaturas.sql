drop table colocacoes;
drop table candidaturas;
drop table alunosExames;
drop table candidatos;
drop table exames;
drop table escolas;
drop table ofertas;
drop table cursos;
drop table estabelecimentosSup;
drop table contingentes;
drop table concelhos;
drop table distritos;



create table distritos (
  distrito varchar2(2),
  descrDistrito varchar2(20) not null,
  primary key (distrito)
  );

create table concelhos (
  distrito varchar2(2),
  concelho varchar2(2),
  descrConcelho varchar2(30) not null,
  primary key (distrito, concelho),
  foreign key (distrito) references distritos(distrito)
  );

create table contingentes (
  conting varchar2(1),
  descrConting varchar2(10) not null,
  primary key (conting)
  );

create table estabelecimentosSup (
  estab varchar2(4),
  nomeEstab varchar2(255) not null,
  distrito varchar2(2),
  primary key (estab),
  foreign key (distrito) references distritos(distrito)
  );
  
create table cursos (
  curso varchar2(4),
  nomeCurso varchar2(255) not null,
  grau varchar2(2) not null check ( grau in ('L1', 'MI', 'PM', 'PL') ),
  primary key (curso)
  );

create table ofertas (
  estab varchar2(4),
  curso varchar2(4),
  vagas number(3),
  primary key (estab, curso),
  foreign key (estab) references estabelecimentosSup(estab),
  foreign key (curso) references cursos(curso)
  );

create table escolas (
  escola varchar2(4),
  nomeEscola varchar2(75) not null,
  distrito varchar2(2) not null,
  concelho varchar2(2) not null,
  primary key (escola),
  foreign key (distrito, concelho) references concelhos(distrito, concelho)
  );

create table exames (
  exame varchar2(3),
  nomeExame varchar2(37) not null,
  primary key (exame)
  );

create table candidatos (
  idCandidato number(11),
  nome varchar2(30) not null,
  sexo char(1) not null CHECK ( sexo IN ( 'F' , 'M' )  ), 
  distrito varchar2(2),
  concelho varchar2(2),
  escola varchar2(4),
  mediaSec number(3),
  primary key (idCandidato),
  foreign key (distrito, concelho) references concelhos(distrito, concelho),
  foreign key (escola) references escolas(escola)
  );

create table alunosExames (
  idCandidato number(11),
  exame varchar2(3),
  fase number(1) not null check (fase in (1,2)),
  ano number(4) not null check (ano > 2012),
  primary key (idCandidato, exame, fase, ano),
  foreign key (idCandidato) references candidatos(idCandidato),
  foreign key (exame) references exames(exame)
  );

create table candidaturas (
  idCandidato number(11),
  ordem number(1) not null check ( ordem <= 6 ),
  estab varchar2(4),
  curso varchar2(4),
  notaCand float not null check (notaCand >= 95.0),
  primary key (idCandidato, ordem),
  unique (idCandidato, estab, curso),
  foreign key (idCandidato) references candidatos(idCandidato),
  foreign key (estab, curso) references ofertas(estab, curso)
  );

create table colocacoes (
  idCandidato number(11),
  estab varchar2(4),
  curso varchar2(4),
  conting varchar2(1),
  primary key (idCandidato),
  foreign key (idCandidato) references candidatos(idCandidato),
  foreign key (conting) references contingentes(conting),
  foreign key (estab, curso) references ofertas(estab, curso),
-- Uma colocação tem que corresponder a uma candidatura feita pelo candidato
  foreign key (idCandidato, estab, curso)
  			references candidaturas(idCandidato, estab, curso)
  );


