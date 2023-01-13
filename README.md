# db2022-projekt

## Description
This is my presentation in SQL, normalization and Java toward relationsshipdatabase, during the course "Development toward databases 2022" at IT-Högkolan.

## Entity Relationship Diagram
``` mermaid
erDiagram
Student ||..o{ Phone: has
    Student }|..|{ Grade: has
    Student ||..o{ StudentSchool: attends
    Student ||..o{ StudentHobby :has
    School ||..o{ StudentSchool: enrools
    Hobby ||..o{ StudentHobby:involves

 Student{
    int StudentId
    string FirstName
    string LastName
    int GradeId
}

Phone{ 
int PhoneId
int StudentId
tinyint Type
string Number
}

Grade{
int GradeId
string FirstName
string LastName
}

StudentSchool{
int StudentId
int SchoolId
}

StudentHobby{
int StudentId
int HobbyId
}

School{
int SchoolId
string Name
string City
}

Hobby{
int HobbyId
string Name
}
``` 
## Prerequisites
Install
- Docker
- Gradle 
- Java

## Setting up the DB
1:
``` bash
$ docker pull mysql/mysql-server:latest
```
2: 
``` bash
$ docker run --name iths-mysql\
           -e MYSQL_ROOT_PASSWORD=root\
           -e MYSQL_USER=iths\
           -e MYSQL_PASSWORD=iths\
           -e MYSQL_DATABASE=iths\
           -p 3306:3306\
           --tmpfs /var/lib/mysql\
           -d mysql/mysql-server:latest
```
3:
``` bash
$ docker start iths-mysql
```

## Populate and normalize the DB
1: 
```bash
$ git clone https://github.com/moagrip/db2022-projekt.git
```
2: In the project, run the following command
```bash
$ docker exec -i iths-mysql mysql -uroot -proot <<< "GRANT ALL ON iths.* TO 'iths'@'%'"
```
3: 
```bash
$ docker cp denormalized-data.csv iths-mysql:/var/lib/mysql-files
```
4: 
```bash
docker exec -i iths-mysql mysql -uroot -proot < normalisering.sql
```

