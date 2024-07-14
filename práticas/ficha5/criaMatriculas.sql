drop table colocados cascade constraints;
drop table matriculas cascade constraints;
drop table cursos cascade constraints;
drop table cadeiras cascade constraints;
drop table planos cascade constraints;
drop table inscricoes cascade constraints;

create table colocados(
  idCandidato number(11,0),
  nome varchar2(30),
  curso varchar2(4),
  ano number(4,0)
);

create table matriculas(
  numero number(6,0),
  idCandidato number(11,0),
  curso varchar2(4),
  dataMatr date
);

create table cursos(
  curso varchar2(4),
  nomeCurso varchar2(255)
);

create table cadeiras(
  cadeira number(5,0),
  nomeCad varchar2(200),
  ects number(2,0)
);

create table planos(
  cadeira number(5,0),
  curso varchar2(4),
  semestre number(2,0)
);

create table inscricoes(
  numero number(6,0),
  curso varchar2(4),
  cadeira number(5,0),
  anoLetivo number(4,0),
  dataInscr date
);


