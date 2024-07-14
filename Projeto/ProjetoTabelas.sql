DROP TABLE Marcas CASCADE CONSTRAINTS;
DROP TABLE Modelos CASCADE CONSTRAINTS;
DROP TABLE Motores CASCADE CONSTRAINTS;
DROP TABLE Combustoes CASCADE CONSTRAINTS;
DROP TABLE Eletricos CASCADE CONSTRAINTS;
DROP TABLE TipoMotors CASCADE CONSTRAINTS;
DROP TABLE Carros CASCADE CONSTRAINTS;
DROP TABLE Usados CASCADE CONSTRAINTS;
DROP TABLE Pessoas CASCADE CONSTRAINTS;
DROP TABLE Funcionarios CASCADE CONSTRAINTS;
DROP TABLE Clientes CASCADE CONSTRAINTS;
DROP TABLE Vendas CASCADE CONSTRAINTS;
DROP TABLE TestDrives CASCADE CONSTRAINTS;


CREATE TABLE Marcas(
  NomeMarca varchar2(30) NOT NULL,
  Especialidade varchar2(30) NOT NULL,
  PRIMARY KEY (NomeMarca)
);

CREATE TABLE Modelos(
  NomeMarca varchar2(30) NOT NULL,
  NomeModelo varchar2(30) NOT NULL,
  PRIMARY KEY (NomeMarca, NomeModelo),
      FOREIGN KEY (NomeMarca) REFERENCES Marcas(NomeMarca)
);

CREATE TABLE Motores(
  NomeMotor varchar2(30) NOT NULL,
  Autonomia number(5,0),
  Potencia number(10,0),
  Consumos number(5,4),
  PRIMARY KEY (NomeMotor)
);

CREATE TABLE Combustoes(
  NomeMotor varchar2(30) NOT NULL,  
  Tipo varchar2(10) NOT NULL,
  TamanhoTanque number(6,0),
  Cilindrada number(10,0),  
  PRIMARY KEY (NomeMotor),
      FOREIGN KEY (NomeMotor) REFERENCES Motores(NomeMotor)
);

CREATE TABLE Eletricos(
  NomeMotor varchar2(30) NOT NULL,
  CapacidadeBat number(6,0),
  PRIMARY KEY (NomeMotor),
      FOREIGN KEY (NomeMotor) REFERENCES Motores(NomeMotor)  
);

CREATE TABLE TipoMotors(
  NomeModelo varchar2(30) NOT NULL,
  NomeMarca varchar2(30) NOT NULL,
  NomeMotor varchar2(30) NOT NULL,
  PRIMARY KEY (NomeMarca, NomeModelo, NomeMotor),
      FOREIGN KEY (NomeMarca, NomeModelo) REFERENCES Modelos(NomeMarca, NomeModelo),
      FOREIGN KEY (NomeMotor) REFERENCES Motores(NomeMotor)
);

CREATE TABLE Carros(
  IdC number(11,0) NOT NULL,
  Ano number(4,0),
  Cor varchar2(30),
  NomeModelo varchar2(30) NOT NULL,
  NomeMarca varchar2(30) NOT NULL,
  NomeMotor varchar2(30) NOT NULL,
  PRIMARY KEY (IdC),
      FOREIGN KEY (NomeMarca, NomeModelo, NomeMotor) REFERENCES TipoMotors(NomeMarca, NomeModelo, NomeMotor)
);

CREATE TABLE Usados(
  IdC number(11,0) not null,
  Quilometros number(20,0) not null,
  PRIMARY KEY (IdC),
    FOREIGN KEY (IdC) REFERENCES Carros(IdC)
);

CREATE TABLE Pessoas(
  Nif number(9,0) not null,
  Nome varchar2(20) not null,
  Apelido varchar2(20) not null, --9 ou 13 ?? 13 a contar com o +351 (por poder haver Clientes de outros paises)
  Email varchar2(60),
  Morada varchar2(60),
  NTelefone varchar2(13),
  PRIMARY KEY (Nif)
);

CREATE TABLE Funcionarios
(
  Nif number(9,0) not null,
  Cargo varchar2(15) not null,
  PRIMARY KEY (Nif),
    FOREIGN KEY (Nif) REFERENCES Pessoas(Nif)
);

CREATE TABLE Clientes(
  Nif number(9,0) not null,
  PRIMARY KEY (Nif),
    FOREIGN KEY (Nif) REFERENCES Pessoas(Nif)
);

CREATE TABLE Vendas(
  IdV number(11,0) not null,
  DataVenda varchar2(10),
  Montante number(11,0) not null,
  NifC number(9,0) not null,  -- NIF for Clientes
  NifF number(9,0) not null,  -- NIF for Funcionarios
  IdC number(11,0) not null,
  PRIMARY KEY (IdV),
      FOREIGN KEY (NifC) REFERENCES Clientes(Nif),
      FOREIGN KEY (NifF) REFERENCES Funcionarios(Nif),
      FOREIGN KEY (IdC) REFERENCES Carros(IdC)
);

CREATE TABLE TestDrives(
  DataTeste varchar2(10),
  HoraTeste varchar2(5),
  NifF number(9,0) not null, --como distingo que e do cliente e o do funcionario??? e quando adicionamos as chaves estrangeiras??
  NifC number(9,0) not null,
  IdC number(11,0) not null,
  Classificacao number(5,0),
  PRIMARY KEY (DataTeste, HoraTeste, IdC, NifC, NifF),
    FOREIGN KEY (NifF) REFERENCES Funcionarios(Nif), --nif ou nifF ???
    FOREIGN KEY (NifC) REFERENCES Clientes(Nif), --nif ou nifC ???
    FOREIGN KEY (IdC) REFERENCES Carros(IdC)
);

--TRIGGERS
--controllor of the sales for employees
CREATE OR REPLACE TRIGGER CheckNifVendas
BEFORE INSERT ON Vendas
REFERENCING new AS newRow
FOR EACH ROW
BEGIN
  IF (:newRow.NifF = :newRow.NifC) THEN
    Raise_application_error(-20033,'Um funcionário não pode vender um carro a si próprio');
  END IF;
END;
/

--check if the car exists
CREATE OR REPLACE TRIGGER  HasCar
BEFORE INSERT ON Carros
referencing new AS newrow
FOR EACH ROW
DECLARE numero Int;
BEGIN
 SELECT count(*) INTO numero
     FROM Carros 
     WHERE IdC = :newRow.IdC;
IF (numero =0)
THEN  
Raise_application_error(-20033,'nao tem carro');
END IF;
END;
/

--check if is possible insert a car
CREATE OR REPLACE TRIGGER CanInsertCar
BEFORE INSERT ON Carros
REFERENCING NEW AS newRow
FOR EACH ROW
DECLARE
    numero INT;
BEGIN
    SELECT count(*) INTO numero
    FROM TipoMotors
    WHERE NomeMarca = :newRow.NomeMarca AND
          NomeModelo = :newRow.NomeModelo AND
          NomeMotor = :newRow.NomeMotor;
    IF (numero = 0) THEN
        RAISE_APPLICATION_ERROR(-20033, 'não existe um o motor com o ID fornecido da marca e modelo pedido');
    END IF;
END;
/

--trigger mais fácil para inserir carro
CREATE OR REPLACE TRIGGER InsertCar
BEFORE INSERT ON Carros
FOR EACH ROW
DECLARE
  car_count INT;
BEGIN
  SELECT COUNT(*) INTO car_count FROM Carros WHERE IdC = :NEW.IdC;
  IF car_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Car with this ID already exists.');
  END IF;
END;
/


--check if the testDrive can happen
CREATE OR REPLACE TRIGGER CanBeTestDrive
BEFORE INSERT ON TestDrives
--porque é que quando retirarmos a linha REFERENCING ... dá erro e sem não??
FOR EACH ROW
DECLARE
  nCar INT;
  nCli INT;
  nFun INT;
BEGIN
  -- Check if the car exists
  SELECT COUNT(*) INTO nCar FROM Carros WHERE IdC = :new.IdC;
  IF nCar = 0 THEN
    RAISE_APPLICATION_ERROR(-20033, 'Car does not exist.');
  END IF;

  -- Check if the client exists
  SELECT COUNT(*) INTO nCli FROM Clientes WHERE Nif = :new.NifC;
  IF nCli = 0 THEN
    RAISE_APPLICATION_ERROR(-20034, 'Client does not exist.');
  END IF;

  -- Check if the employee exists
  SELECT COUNT(*) INTO nFun FROM Funcionarios WHERE Nif = :new.NifF;
  IF nFun = 0 THEN
    RAISE_APPLICATION_ERROR(-20035, 'Employee does not exist.');
  END IF;
END;
/

-- Additional Brands and Models
INSERT INTO Marcas (NomeMarca, Especialidade) VALUES ('Toyota', 'General');
INSERT INTO Marcas (NomeMarca, Especialidade) VALUES ('Tesla', 'Electric');
INSERT INTO Marcas (NomeMarca, Especialidade) VALUES ('Ford', 'General');
INSERT INTO Marcas (NomeMarca, Especialidade) VALUES ('BMW', 'Luxury');
INSERT INTO Marcas (NomeMarca, Especialidade) VALUES ('Porsche', 'Sports');

-- Models for additional brands
INSERT INTO Modelos (NomeMarca, NomeModelo) VALUES ('Toyota', 'Corolla');
INSERT INTO Modelos (NomeMarca, NomeModelo) VALUES ('Tesla', 'Model S');
INSERT INTO Modelos (NomeMarca, NomeModelo) VALUES ('Ford', 'Mustang');
INSERT INTO Modelos (NomeMarca, NomeModelo) VALUES ('BMW', 'M3');
INSERT INTO Modelos (NomeMarca, NomeModelo) VALUES ('Porsche', '911');

-- Insert Motores
INSERT INTO Motores (NomeMotor, Autonomia, Potencia, Consumos) VALUES ('Motor1', 500, 150, 0.05);
INSERT INTO Motores (NomeMotor, Autonomia, Potencia, Consumos) VALUES ('Motor2', 450, 180, 0.06);
INSERT INTO Motores (NomeMotor, Autonomia, Potencia, Consumos) VALUES ('Motor3', 550, 200, 0.04);
INSERT INTO Motores (NomeMotor, Autonomia, Potencia, Consumos) VALUES ('Motor4', 600, 250, 0.07);
INSERT INTO Motores (NomeMotor, Autonomia, Potencia, Consumos) VALUES ('Motor5', 650, 300, 0.08);

-- Insert Combustoes
INSERT INTO Combustoes (NomeMotor, Tipo, TamanhoTanque, Cilindrada) VALUES ('Motor1', 'Petrol', 50, 2000);
INSERT INTO Combustoes (NomeMotor, Tipo, TamanhoTanque, Cilindrada) VALUES ('Motor2', 'Petrol', 55, 2200);
INSERT INTO Combustoes (NomeMotor, Tipo, TamanhoTanque, Cilindrada) VALUES ('Motor3', 'Diesel', 60, 1800);
INSERT INTO Combustoes (NomeMotor, Tipo, TamanhoTanque, Cilindrada) VALUES ('Motor4', 'Diesel', 65, 2400);
INSERT INTO Combustoes (NomeMotor, Tipo, TamanhoTanque, Cilindrada) VALUES ('Motor5', 'Petrol', 70, 3000);

-- Insert Elétricos
INSERT INTO Eletricos (NomeMotor, CapacidadeBat) VALUES ('Motor1', 75);
INSERT INTO Eletricos (NomeMotor, CapacidadeBat) VALUES ('Motor2', 85);
INSERT INTO Eletricos (NomeMotor, CapacidadeBat) VALUES ('Motor3', 95);
INSERT INTO Eletricos (NomeMotor, CapacidadeBat) VALUES ('Motor4', 100);
INSERT INTO Eletricos (NomeMotor, CapacidadeBat) VALUES ('Motor5', 110);

-- Insert into TipoMotors
INSERT INTO TipoMotors (NomeModelo, NomeMarca, NomeMotor) VALUES ('Corolla', 'Toyota', 'Motor1');
INSERT INTO TipoMotors (NomeModelo, NomeMarca, NomeMotor) VALUES ('Model S', 'Tesla', 'Motor2');
INSERT INTO TipoMotors (NomeModelo, NomeMarca, NomeMotor) VALUES ('Mustang', 'Ford', 'Motor3');
INSERT INTO TipoMotors (NomeModelo, NomeMarca, NomeMotor) VALUES ('M3', 'BMW', 'Motor4');
INSERT INTO TipoMotors (NomeModelo, NomeMarca, NomeMotor) VALUES ('911', 'Porsche', 'Motor5');

-- Insert into Carros
INSERT INTO Carros (IdC, Ano, Cor, NomeModelo, NomeMarca, NomeMotor) VALUES (1, 2020, 'Red', 'Corolla', 'Toyota', 'Motor1');
INSERT INTO Carros (IdC, Ano, Cor, NomeModelo, NomeMarca, NomeMotor) VALUES (2, 2021, 'Blue', 'Model S', 'Tesla', 'Motor2');
INSERT INTO Carros (IdC, Ano, Cor, NomeModelo, NomeMarca, NomeMotor) VALUES (3, 2022, 'Black', 'Mustang', 'Ford', 'Motor3');
INSERT INTO Carros (IdC, Ano, Cor, NomeModelo, NomeMarca, NomeMotor) VALUES (4, 2023, 'White', 'M3', 'BMW', 'Motor4');
INSERT INTO Carros (IdC, Ano, Cor, NomeModelo, NomeMarca, NomeMotor) VALUES (5, 2024, 'Green', '911', 'Porsche', 'Motor5');

-- Insert into Usados
INSERT INTO Usados (IdC, Quilometros) VALUES (1, 10000);
INSERT INTO Usados (IdC, Quilometros) VALUES (2, 20000);
INSERT INTO Usados (IdC, Quilometros) VALUES (3, 30000);

-- Insert into Pessoas
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (123456789, 'John', 'Doe', 'john.doe@example.com', '123 Elm St', '+351123456789');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (234567890, 'Jane', 'Doe', 'jane.doe@example.com', '234 Oak St', '+351234567890');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (345678901, 'Jim', 'Beam', 'jim.beam@example.com', '345 Maple St', '+351345678901');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (456789012, 'Jack', 'Daniels', 'jack.daniels@example.com', '456 Pine St', '+351456789012');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (567890123, 'Jose', 'Cuervo', 'jose.cuervo@example.com', '567 Birch St', '+351567890123');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (234567890, 'Alice', 'Brown', 'alice.brown@example.com', '1234 Maple Street', '+3512345678');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (345678901, 'Bob', 'White', 'bob.white@example.com', '5678 Spruce Street', '+3513456789');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (456789012, 'Charlie', 'Green', 'charlie.green@example.com', '9101 Pine Street', '+3514567890');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (567890123, 'David', 'Black', 'david.black@example.com', '1234 Oak Street', '+3515678901');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (678901234, 'Eva', 'Gray', 'eva.gray@example.com', '5678 Cedar Street', '+3516789012');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (789012345, 'Frank', 'Stone', 'frank.stone@example.com', '9101 Birch Street', '+3517890123');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (890123456, 'Grace', 'Hall', 'grace.hall@example.com', '1234 Walnut Street', '+3518901234');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (901234567, 'Hannah', 'Lee', 'hannah.lee@example.com', '5678 Elm Street', '+3519012345');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (123456780, 'Ivan', 'River', 'ivan.river@example.com', '9101 Ash Street', '+3511234560');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (234567801, 'Julia', 'Cloud', 'julia.cloud@example.com', '1234 Pine Avenue', '+3512345670');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (345678912, 'Kevin', 'Brooks', 'kevin.brooks@example.com', '5678 Oak Avenue', '+3513456781');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (456789023, 'Lily', 'Frost', 'lily.frost@example.com', '9101 Cedar Avenue', '+3514567892');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (567890134, 'Mike', 'Sky', 'mike.sky@example.com', '1234 Birch Avenue', '+3515678903');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (678901245, 'Nina', 'Woods', 'nina.woods@example.com', '5678 Walnut Avenue', '+3516789014');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (789012356, 'Oscar', 'Jordan', 'oscar.jordan@example.com', '9101 Maple Avenue', '+3517890125');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (890123467, 'Patricia', 'Ford', 'patricia.ford@example.com', '1234 Spruce Avenue', '+3518901236');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (901234578, 'Quentin', 'Rush', 'quentin.rush@example.com', '5678 Pine Street', '+3519012347');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (123456789, 'Rachel', 'Smith', 'rachel.smith@example.com', '9101 Oak Street', '+3511234567');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (987654322, 'Sophia', 'Turner', 'sophia.turner@example.com', '1234 Cedar Street', '+3519876543');
INSERT INTO Pessoas (Nif, Nome, Apelido, Email, Morada, NTelefone) VALUES (876543213, 'Tom', 'Adams', 'tom.adams@example.com', '5678 Birch Street', '+3518765432');

-- Insert into Funcionarios
INSERT INTO Funcionarios (Nif, Cargo) VALUES (123456789, 'Salesman');
INSERT INTO Funcionarios (Nif, Cargo) VALUES (234567890, 'Manager');
INSERT INTO Funcionarios (Nif, Cargo) VALUES (345678901, 'Technician');
INSERT INTO Funcionarios (Nif, Cargo) VALUES (456789012, 'Salesman');
INSERT INTO Funcionarios (Nif, Cargo) VALUES (567890123, 'Manager');

-- Insert into Clientes
INSERT INTO Clientes VALUES (222333444);
INSERT INTO Clientes VALUES (333444555);

-- Insert into Vendas
INSERT INTO Vendas VALUES (2001, '2024-05-01', 32000, 222333444, 333444555, 2);
INSERT INTO Vendas VALUES (2002, '2024-05-02', 45000, 333444555, 222333444, 3);

-- Insert into TestDrives
INSERT INTO TestDrives VALUES ('2024-05-10', '10:00', 333444555, 222333444, 1, 4);
INSERT INTO TestDrives VALUES ('2024-05-10', '11:00', 222333444, 333444555, 3, 5);
