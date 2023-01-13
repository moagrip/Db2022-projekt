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

