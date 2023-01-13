USE iths;

DROP TABLE IF EXISTS UNF;

CREATE TABLE `UNF` (
    `Id` DECIMAL(38, 0) NOT NULL,
    `Name` VARCHAR(26) NOT NULL,
    `Grade` VARCHAR(11) NOT NULL,
    `Hobbies` VARCHAR(25),
    `City` VARCHAR(10) NOT NULL,
    `School` VARCHAR(30) NOT NULL,
    `HomePhone` VARCHAR(15),
    `JobPhone` VARCHAR(15),
    `MobilePhone1` VARCHAR(15),
    `MobilePhone2` VARCHAR(15)
)  ENGINE=INNODB;

LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv'
INTO TABLE UNF
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
    StudentId INT NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (StudentId)
)  ENGINE=INNODB;

INSERT INTO Student (StudentID, FirstName, LastName) 
SELECT DISTINCT Id, SUBSTRING_INDEX(Name, ' ', 1), SUBSTRING_INDEX(Name, ' ', -1) 
FROM UNF;

DROP TABLE IF EXISTS PhoneType;
CREATE TABLE PhoneType (
    PhoneTypeId INT NOT NULL AUTO_INCREMENT,
    Type VARCHAR(32),
    CONSTRAINT PRIMARY KEY(PhoneTypeId)
);
INSERT INTO PhoneType(Type) VALUES("Home");
INSERT INTO PhoneType(Type) VALUES("Job");
INSERT INTO PhoneType(Type) VALUES("Mobile");

DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone (
    PhoneId INT NOT NULL AUTO_INCREMENT,
    StudentId INT NOT NULL,
    PhoneTypeId INT NOT NULL,
    Number VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY(PhoneId)
);

INSERT INTO Phone(StudentId, PhoneTypeId, Number) 
SELECT ID, PhoneTypeId, HomePhone FROM UNF JOIN PhoneType ON Type = "Home"
WHERE HomePhone IS NOT NULL AND HomePhone != ''
UNION SELECT ID, PhoneTypeId, JobPhone FROM UNF JOIN PhoneType ON Type = "Job"
WHERE JobPhone IS NOT NULL AND JobPhone != ''
UNION SELECT ID, PhoneTypeId, MobilePhone1 FROM UNF JOIN PhoneType ON Type = "Mobile"
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != ''
UNION SELECT ID, PhoneTypeId, MobilePhone2 FROM UNF JOIN PhoneType ON Type = "Mobile"
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != '';

DROP VIEW IF EXISTS PhoneList;
CREATE VIEW PhoneList AS SELECT StudentId, group_concat(Number) AS Numbers FROM Phone GROUP BY StudentId;

drop table if exists School; 
create table School (
	SchoolId int not null auto_increment,
	Name varchar(255) not null,
	City varchar(255) not null,
	primary key (SchoolId)
);
insert into School(Name, City) select distinct School as Name, City from UNF;


drop table if exists StudentSchool;
create table StudentSchool as select Id as StudentId, SchoolId from UNF join School on UNF.School = School.Name; 
alter table StudentSchool modify column StudentId INT;
alter table StudentSchool add primary key (StudentId, SchoolId);
SELECT StudentId, FirstName, LastName FROM Student
JOIN StudentSchool USING (StudentId);

drop view if exists SchoolList;
CREATE VIEW SchoolList AS
SELECT StudentId, FirstName, LastName, Name, City FROM Student
JOIN StudentSchool USING (StudentId) 
JOIN School USING (SchoolId);

DROP TABLE IF EXISTS Hobbies;
CREATE TABLE Hobbies (
    HobbyId INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (HobbyId)
)  ENGINE=INNODB;

INSERT INTO Hobbies(Name)
SELECT DISTINCT Hobby FROM (
  SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF
  WHERE HOBBIES != ""
) AS Hobbies2;

DROP TABLE IF EXISTS Hobby;
CREATE TABLE Hobby (
    StudentId INT NOT NULL,
    HobbyId INT NOT NULL,
    CONSTRAINT PRIMARY KEY (StudentId, HobbyId)
)  ENGINE=INNODB;

INSERT INTO Hobby(StudentId, HobbyId)
SELECT DISTINCT StudentId, HobbyId FROM (
  SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF
  WHERE HOBBIES != ""
) AS Hobbies2 INNER JOIN Hobbies ON Hobbies2.Hobby = Hobbies.Name;

DROP VIEW IF EXISTS HobbiesList;
CREATE VIEW HobbiesList AS SELECT StudentId, group_concat(Name) FROM Hobby JOIN Hobbies USING (HobbyId) 
GROUP BY StudentId;

DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade (
    GradeId INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (GradeId)
)  ENGINE=INNODB;

INSERT INTO Grade(Name) 
SELECT DISTINCT Grade FROM UNF;

ALTER TABLE Student ADD COLUMN GradeId INT NOT NULL;

