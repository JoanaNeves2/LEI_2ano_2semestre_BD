--1
  --1ºpasso:
create table t (
	a int primary key,
	b varchar2(30)
);
create table s (
	a int primary key,
	b int
);
  --4ºpasso:
select *
  from t;
  --6ºpasso:
select *
  from t;


--2
  --2ºpasso:
select *
  from t;
  --4ºpasso:
select *
  from t;


--3
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

select * from s;
select * from t;
insert into t values (4, 'quatro');
commit;

--4
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

  --1º
  select * from t;

  --3º
  update t set b= 'a' where a = 1;
  commit;

--5

  --1.
create table mulheres(nome varchar2 (20) primary key, marido varchar2(20) not null);
create table maridos (nome varchar2 (20) primary key, mulher varchar2(20) not null);
  --2
alter table mulheres add constraint fk_marido foreign key (marido) references maridos(nome) deferrable;
alter table maridos add constraint fk_mulher foreign key (mulher) references mulheres(nome) deferrable;

  --3
SET CONSTRAINTS ALL DEFERRED;
insert into mulheres values ('A', 'B');
insert into maridos values ('B', 'A');
