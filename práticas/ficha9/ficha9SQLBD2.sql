--1
  --2ºpasso:
insert into t values (
	1,
	'um'
);
insert into t values (
	2,
	'dois'
);
  --3ºpasso:
select *
  from t;
  --5ºpasso:
commit;

--2
  --1ºpasso:
insert into t values (
	3,
	'tres'
);
  --3ºpasso:
commit;

--3
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

select * from s;

select * from t;
commit;

--4
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

  --2º
  select * from t;

  --4º
  update t set b= 'c' where a = 1;
  commit;