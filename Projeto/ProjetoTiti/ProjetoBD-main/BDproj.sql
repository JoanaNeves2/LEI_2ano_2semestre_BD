drop table userC cascade constraints;
drop table friend  cascade constraints;
drop table Producer cascade constraints;
drop table TypeG cascade constraints;
drop table Game cascade constraints;
drop table has cascade constraints;
drop table Achievement cascade constraints;
drop table Conq cascade constraints;
drop table AdminC cascade constraints;
drop table ManageG cascade constraints;

create table UserC(
  UserID number(10,0),
  UserName varchar2(50) not null,
  Email varchar(75) not null unique,
  NTelephone number(9,0) not null unique,
   PRIMARY KEY (UserID),
   check (NTelephone > 900000000 and NTelephone < 999999999)

  );

create table friend(
  UserID1 number(10,0),
  UserID2 number(10,0),
   PRIMARY KEY (UserID1,UserID2) ,
   FOREIGN KEY (UserID1) REFERENCES UserC(UserID),
   FOREIGN KEY (UserID2) REFERENCES UserC(UserID),
    check (UserID1 <> UserID2));

create table Producer(
  ProducerID number(10,0),
  ProducerName varchar2(30) not null unique,
  ProducerDescription varchar2(2000) not null,
   PRIMARY KEY (ProducerID)
  );
 
create table TypeG(
 GameCategory varchar2(30),
 JogadoresRecomendados number(2,0) not null,
  PRIMARY KEY (GameCategory)
 );
 
create table Game(
  GameID number(10,0),
  GameName varchar2(30) not null unique,
  Price number not null,
  GameDescription varchar2(2000) not null,
  ProducerID number(10,0) not null,
  GameCategory varchar2(30) not null,
   PRIMARY KEY (GameID),
   FOREIGN KEY(ProducerID) REFERENCES Producer(ProducerID),
   FOREIGN KEY(GameCategory) REFERENCES TypeG(GameCategory),
   check (price >=0)
   );
   
create table has(
   UserID number(10,0),
   GameID number(10,0),
   Score number(2,0),
   Review varchar2(2000),
    PRIMARY KEY (UserID, GameID),
    FOREIGN KEY (UserID) REFERENCES UserC(UserID),
    FOREIGN KEY (GameID) REFERENCES Game(GameID),
    check ((Score >= 0 AND Score <= 10) or Score = null)
    
    );

create table Achievement(
  AchievementID number(10,0),
  GameID number(10,0), 
  AchievementName varchar2(50) not null,
   PRIMARY KEY (AchievementID,GameID),
   FOREIGN KEY (GameID) REFERENCES Game(GameID)  
  );
    
create table Conq(
   UserID number(10,0),
   GameID number(10,0),
   AchievementID number(10,0),
    PRIMARY KEY (UserID, GameID, AchievementID),
    FOREIGN KEY (UserID) REFERENCES UserC(UserID),
    FOREIGN KEY (GameID,AchievementID) REFERENCES Achievement(GameID,AchievementID)
    );

create table AdminC(
  UserID number(10,0),
  nAdmin number(10,0) not null unique,
   PRIMARY KEY (UserID),
   FOREIGN KEY (UserID) REFERENCES UserC(UserID)
  );

create table ManageG(
   UserID number(10,0),
   GameID number(10,0),
   PRIMARY KEY (UserID, GameID),
    FOREIGN KEY (UserID) REFERENCES AdminC(UserID),
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
    );
 
create or replace trigger  FriendshipGoesBothWays
before insert on friend
referencing new AS nrow
FOR EACH ROW
declare yoMan INT;
begin
select Count(*) into yoMan
from friend
where userid1 = :nrow.UserId2 And UserId2 = :nrow.UserId1;
if (YoMan = 1)
then 
delete from friend where userid1 = :nrow.UserId2 And UserId2 = :nrow.UserId1 ;
end if;
end;
/   

create or replace trigger  avaliacao
before insert on has
referencing new AS newrow
FOR EACH ROW
begin
if ((:newrow.review is Null and :newrow.score is not Null) or (:newrow.review is not Null and :newrow.score is Null))
then  
Raise_application_error(-20034,'se é para avaliar é para avaliar como deve ser');
end if;
end;
/

create or replace trigger  HasGame
before insert on conq
referencing new AS newrow
FOR EACH ROW
declare numero Int;
begin
 select count(*) into numero
     from has 
     where UserId = :newRow.UserID AND GameId = :newRow.GameId;
if (numero =0)
then  
Raise_application_error(-20033,'nao tem o jogo');
end if;
end;
/

-- user inserts--
insert into UserC Values(1,'Masu','tms.guerra@campus.fct.unl.pt',964341370);
insert into UserC Values(2,'Boinito','mr.baiao@campus.fct.unl.pt',960035194);
insert into UserC Values(3,'Alexe','als.goncalves@campus.fct.unl.pt',926838221);
insert into UserC Values(4,'Vilheninha','fj.vilhena@campus.fct.unl.pt',965596306);
insert into UserC Values(5,'Cachaloto','Carloto1300@gmail.com',967539959);
insert into UserC Values(6,'GuidinhoPT','rd.alegria@campus.fct.unl.pt',932881240);
insert into UserC Values(7,'Raven','pan.ferreira@campus.fct.unl.pt',938727600);
insert into UserC Values(8,'VibeBoy','gf.santana@campus.fct.unl.pt',925860531);
insert into UserC Values(9,'GonçaloZen','gv.martins@campus.fct.unl.pt',933384688);
insert into UserC Values(10,'GonçaloDoritos','goluisilva@gmail.com',925604769);
insert into UserC Values(11,'SemNome5','daa.silva@campus.fct.unl.pt',912848778);

-- producer inserts --
insert into Producer Values(1,'Mojang','criadora do Minecraft');
insert into Producer Values(2,'Behaviour','criadora do Dead by Daylight');
insert into Producer Values(3,'CDProjektRED','criadora do Minecraft');
insert into Producer Values(4,'Riot','criadora do League of Legends');
insert into Producer Values(5,'SCS Software','criadora do EuroTruck Simulator2');
insert into Producer Values(6,'Psyonix','criadora do Rocket League');
insert into Producer Values(7,'EA Sports','criadora do Fifa');
insert into Producer Values(8,'NaugtyDog','criadora da Saga Last of Us');
insert into Producer Values(9,'Capcom','criadora do Resident Evil 2');
insert into Producer Values(10,'SquareEnix','criadora do Marvel Avengers');
insert into Producer Values(11,'Blizzard','criadora do OverWatch');
insert into Producer Values(12,'Crytek','criadora do Hunt:showdown');

-- TypeG insert --
insert into TypeG Values('SandBox',1);
insert into TypeG Values('Survival Horror',5);
insert into TypeG Values('Horror',5);
insert into TypeG Values('Simulation',4);
insert into TypeG Values('MOBA',10);
insert into TypeG Values('Sci-Fi',1);
insert into TypeG Values('Racing',6);
insert into TypeG Values('Sports',2);
insert into TypeG Values('Action',1);
insert into TypeG Values('First Person Shooter',1);
-- Game Insert --
insert into Game Values(1,'Minecraft',23.95,'jogo favorito do picasso',1,'SandBox');
insert into Game Values(2,'Dead By Daylight',19.99,'nem vale vale a pena',2,'Survival Horror');
insert into Game Values(3,'CyberPunk 2077',69.99,'um bug que parece um jogo',3,'Sci-Fi');
insert into Game Values(4,'League of Legends',0,'Contrato com diabo :)',4,'MOBA');
insert into Game Values(5,'EuroTruck Simulator2',19.99,'Conduzir camioes',5,'Simulation');
insert into Game Values(6,'Rocket League',0,'Futebol com carros',6,'Racing');
insert into Game Values(7,'Fifa',69.99,'Futebol com pessoas',7,'Sports');
insert into Game Values(8,'Last of us',69.99,'Historia muito gira',8,'Survival Horror');
insert into Game Values(9,'Last of us Part 2',69.99,'Continuaçao do primeiro',8,'Survival Horror');
insert into Game Values(10,'Resident evil 2',11.99,'Estas fechado na policia com muito zombie',9,'Horror');
insert into Game Values(11,'Marvel Avengers',79.99,'Nao comprem por mais que 20€',10,'Action');
insert into Game Values(12,'OverWatch',19.99,'5v5 com personagens com habilidades',11,'MOBA');
insert into Game Values(13,'Hunt: Showdown',19.99,'12 Cowboys e muito zombie',12,'First Person Shooter');

-- Has insert -- 
insert into has Values(1,1,10,'jogo bueda loko bueda nice');
insert into has Values(1,2,1,'nao joguem isto');
insert into has Values(1,4,null,null);
insert into has Values(1,5,null,null);
insert into has Values(1,6,null,null);
insert into has Values(1,7,null,null);
insert into has Values(1,8,10,'2ºmelhor jogo de sempre');
insert into has Values(1,9,10,'melhor jogo de sempre');
insert into has Values(1,10,null,null);
insert into has Values(1,12,null,null);
insert into has Values(1,13,null,null);

insert into has Values(2,3,5,'bug com shoting razoavel');
insert into has Values(2,11,5,'A minha playstation ia levantando voo');
insert into has Values(2,2,null,null);
insert into has Values(2,4,null,null);
insert into has Values(2,5,null,null);
insert into has Values(2,6,null,null);

insert into has Values(3,2,2,'se queres perder neuronios este jogo e para ti');
insert into has Values(3,1,null,null);
insert into has Values(3,10,9,'Nunca mais quero ver um licker à frente :)');
insert into has Values(3,5,null,null);
insert into has Values(3,4,null,null);

insert into has Values(4,1,null,null);
insert into has Values(4,2,9,'Se fosse experiencia solo queue mudava para 3');
insert into has Values(4,5,null,null);
insert into has Values(4,6,null,null);
insert into has Values(4,7,null,null);
insert into has Values(4,8,null,null);
insert into has Values(4,10,null,null);
insert into has Values(4,12,null,null);
insert into has Values(4,13,9,'Se os teus amigos comprarem tens a melhor semana da tua vida');

insert into has Values(5,1,null,null);
insert into has Values(5,2,null,null);
insert into has Values(5,4,null,null);
insert into has Values(5,5,7,'Parem de me bater pls :c');
insert into has Values(5,6,8,'Macaco muito bonito');
insert into has Values(5,12,null,null);
insert into has Values(5,13,null,null);

insert into has Values(6,1,null,null);
insert into has Values(6,2,null,null);
insert into has Values(6,4,null,null);
insert into has Values(6,5,8,'Se ultrapassas metes-te a jeito');
insert into has Values(6,6,null,null);
insert into has Values(6,7,3,'nunca mais vou jgr isto');
insert into has Values(6,12,null,null);
insert into has Values(6,13,null,null);

insert into has Values(7,1,10,'tenho saudades do meu moinho');
insert into has Values(7,2,null,null);
insert into has Values(7,4,null,null);
insert into has Values(7,6,null,null);
insert into has Values(7,12,2,'preciso de esperar pelo 2º para ter a certeza');

insert into has Values(8,1,null,null);
insert into has Values(8,2,null,null);
insert into has Values(8,6,null,null);
insert into has Values(8,7,3,'Parti a mesa a jgr isto D:');
insert into has Values(8,8,null,null);
insert into has Values(8,12,7,'Jogo bom mas há com cada burrinho');

insert into has Values(9,1,null,null);
insert into has Values(9,4,null,null);
insert into has Values(9,8,null,null);
insert into has Values(9,12,null,null);

insert into has Values(10,1,10,'Saudades do que ainda nao vivi');
insert into has Values(10,4,0,'Eu ja nao tenho salvaçao, salvem-se vcs e nao joguem isto');
insert into has Values(10,5,null,null);
insert into has Values(10,6,null,null);
insert into has Values(10,7,null,null);
insert into has Values(10,8,null,null);


-- Achievement insert  --
insert into Achievement values (1, 1, 'Kill Zombie');
insert into Achievement values (2, 1, 'Kill Dragon');
insert into Achievement values (1, 2, 'Kill 4 players in a match');
insert into Achievement values (2, 2, 'Survive 1 trial');
insert into Achievement values (1, 3, 'Hack 1 device');
insert into Achievement values (2, 3, 'Change your hair 2 times');
insert into Achievement values (1, 4, 'Win the first Game');
insert into Achievement values (2, 4, 'Buy first Champion');
insert into Achievement values (1, 5, 'Crash into another player');
insert into Achievement values (2, 5, 'Complete the first delivery');
insert into Achievement values (1, 6, 'Win a game with boionito');
insert into Achievement values (2, 6, 'Spam "what a save"');
insert into Achievement values (1, 7, 'Rage quit the first time');
insert into Achievement values (2, 7, 'Break a controller');
insert into Achievement values (1, 8, 'Finish the game twice');
insert into Achievement values (2, 8, 'Throw a brick at 10 zombies');
insert into Achievement values (1, 9, 'Watch Joel die');
insert into Achievement values (2, 9, 'Finish the game');
insert into Achievement values (1, 10, 'Get bonked by Mr.X');
insert into Achievement values (2, 10, 'Kill a licker');
insert into Achievement values (1, 11, 'Smash a car using Hulk');
insert into Achievement values (2, 11, 'Using thors hammer');
insert into Achievement values (1, 12, 'Get play of the game');
insert into Achievement values (2, 12, 'Get baited by DPS');
insert into Achievement values (1, 13, 'Throw Lantern to a teammate');
insert into Achievement values (2, 13, 'Extract the bounty once');



-- Cronq Insert --
insert into Conq values (1, 1, 2);
insert into Conq values (1, 7, 1);
insert into Conq values (1, 8, 2);
insert into Conq values (1, 8, 1);
insert into Conq values (1, 9, 2);
insert into Conq values (1, 9, 1);

insert into Conq values (2, 3, 1);
insert into Conq values (2, 6, 2);

insert into Conq values (3, 2, 1);
insert into Conq values (3, 2, 2);

insert into Conq values (4, 12, 1);
insert into Conq values (4, 2, 1);

insert into Conq values (5, 6, 2);
insert into Conq values (5, 6, 1);

insert into Conq values (7, 2, 2);
insert into Conq values (7, 12, 2);

insert into Conq values (8, 7, 2);
insert into Conq values (8, 12, 1);

insert into Conq values (9, 12, 2);
insert into Conq values (9, 12, 1);

insert into Conq values (10, 5, 1);
insert into Conq values (10, 7, 1);


-- Friend insert --
insert into Friend values (1,3);
insert into Friend values (1,2);
insert into Friend values (1,4);
insert into Friend values (1,5);
insert into Friend values (1,6);
insert into Friend values (1,7);
insert into Friend values (1,8);
insert into Friend values (1,9);
insert into Friend values (1,10);
insert into Friend values (1,11);

insert into Friend values (2,3);
insert into Friend values (2,6);
insert into Friend values (2,5);
insert into Friend values (2,10);

insert into Friend values (3,2);
insert into Friend values (3,9);
insert into Friend values (3,8);
insert into Friend values (3,4);

insert into Friend values (4,5);
insert into Friend values (4,10);
insert into Friend values (4,11);
insert into Friend values (4,1);

insert into Friend values (5,4);
insert into Friend values (5,9);
insert into Friend values (5,11);
insert into Friend values (5,1);

insert into Friend values (6,7);
insert into Friend values (6,9);
insert into Friend values (6,11);
insert into Friend values (6,3);

insert into Friend values (7,4);
insert into Friend values (7,9);
insert into Friend values (7,10);
insert into Friend values (7,3);

insert into Friend values (8,7);
insert into Friend values (8,9);
insert into Friend values (8,5);
insert into Friend values (8,3);

insert into Friend values (9,7);
insert into Friend values (9,11);
insert into Friend values (9,5);
insert into Friend values (9,3);

insert into Friend values (10,7);
insert into Friend values (10,1);
insert into Friend values (10,5);
insert into Friend values (10,3);

insert into Friend values (11,7);
insert into Friend values (11,1);
insert into Friend values (11,10);
insert into Friend values (11,3);


-- adminC insert --
insert into AdminC values (2,1);
insert into AdminC values (1,2);
insert into AdminC values (3,3);
-- ManageG insert --
insert into ManageG values (1,1);
insert into ManageG values (2,2);
insert into ManageG values (3,3);
insert into ManageG values (3,4);
insert into ManageG values (2,5);
insert into ManageG values (1,6);
insert into ManageG values (1,8);
insert into ManageG values (1,9);
insert into ManageG values (3,10);
insert into ManageG values (2,11);
insert into ManageG values (2,4);
insert into ManageG values (3,1); 
