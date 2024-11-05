CREATE DATABASE Company;
USE Company;

CREATE TABLE Employee (
    FNAME VARCHAR(50) NOT NULL,
    LNAME VARCHAR(50) NOT NULL,
    SSN CHAR(9) NOT NULL,
    BDATE DATE NULL,
    ADDRESS VARCHAR(100) NULL,
    SALARY DECIMAL(10,2) NULL,
    SUPERSSN CHAR(9) NULL,
    DNO INT NULL,
	PRIMARY KEY(SSN),

);

CREATE TABLE Department (
    DNAME VARCHAR(50),
    DNUMBER INT PRIMARY KEY,
    MGRSSN CHAR(9),
	FOREIGN KEY (MGRSSN) REFERENCES Employee(SSN)

);

ALTER TABLE Employee
ADD CONSTRAINT Dep_id FOREIGN KEY (DNO) REFERENCES Department(DNUMBER);


CREATE TABLE Dept_Locations (
    DNUMBER INT ,
    DLOCATION VARCHAR(50),
	PRIMARY KEY (DNUMBER, DLOCATION),
    FOREIGN KEY (DNUMBER) REFERENCES Department(DNUMBER)
);

CREATE TABLE Project (
    PNAME VARCHAR(50),
    PNUMBER INT PRIMARY KEY,
    PLOCATION VARCHAR(50),
    DNUM INT,
    FOREIGN KEY (DNUM) REFERENCES Department(DNUMBER)
);

CREATE TABLE Works_On (
    ESSN CHAR(9),
    PNO INT,
    HOURS DECIMAL(5,2),
    PRIMARY KEY (ESSN, PNO),
    FOREIGN KEY (ESSN) REFERENCES Employee(SSN),
    FOREIGN KEY (PNO) REFERENCES Project(PNUMBER)
);



CREATE TABLE Dependent (
    ESSN CHAR(9) NOT NULL,
    DEPENDENT_NAME VARCHAR(50) NOT NULL,
    SEX CHAR(1) NULL,
    BDATE DATE NULL,
    RELATIONSHIP VARCHAR(50) NULL,
	PRIMARY KEY (ESSN, DEPENDENT_NAME),

);



-- Insert at least 2 rows per table
INSERT INTO Employee (FNAME, LNAME, SSN, BDATE, ADDRESS, SALARY, SUPERSSN, DNO) VALUES
('Youssef', 'Mohamed', '123456779', '2002-01-21', '123 Mar St', 5000, '123456789', 1),
('Youssef', 'Lamei', '987655321', '2002-02-05', '456 Moa St', 9000, '987654321', 2)
;



ALTER TABLE Employee
ALTER COLUMN FNAME VARCHAR(50) NULL;

ALTER TABLE Employee
ALTER COLUMN LNAME VARCHAR(50) NULL; 

ALTER TABLE Employee
DROP CONSTRAINT CK_Address;

INSERT INTO Employee (FNAME, LNAME, SSN, BDATE, ADDRESS, SALARY, SUPERSSN, DNO) VALUES
(NULL, NULL, '123456778', '2002-01-21', '123 oc St', 5000, '123456789', 1),
(NULL, 'Mohamed', '123456777', '2002-01-21', '123 dem St', 5000, '123456789', 2)
;

INSERT INTO Employee (FNAME, LNAME, SSN, BDATE, ADDRESS, SALARY, SUPERSSN, DNO) VALUES
('Yasmeen', 'Khaled', '11', '2002-01-21', '123 oc St', 5000, '123456789', 1),
('Shaban', 'Khaled', '22', '2002-01-21', '123 dem St', 5000, '123456789', 2)
;

INSERT INTO Employee (FNAME, LNAME, SSN, BDATE, ADDRESS, SALARY, SUPERSSN, DNO) VALUES
('Mohamed', 'Magdey', '66', '2002-01-21', '123 oc St', 5000, '123456789', 3),
('Hanaa', 'Gharieb', '88', '2001-01-21', '123 dem St', 5000, '123456789', 4)
;


UPDATE Employee
SET SALARY=NULL
WHERE FNAME='Hanaa';

SELECT * FROM Employee;

ALTER TABLE Employee
DROP CONSTRAINT Dep_id;




INSERT INTO Department (DNAME, DNUMBER, MGRSSN) VALUES
('HR', 1, '123456779'),
('IT', 2, '987655321')
;

INSERT INTO Department (DNAME, DNUMBER, MGRSSN) VALUES
('CS', 3, '66'),
('IS', 4, '88')
;

SELECT * FROM Department;


INSERT INTO Dept_Locations (DNUMBER, DLOCATION) VALUES
(1, 'Cairo'),
(2, 'Giza');

INSERT INTO Project (PNAME, PNUMBER, PLOCATION, DNUM) VALUES
('Project A', 1, 'Cairo', 1),
('Project B', 2, 'Giza', 2);

INSERT INTO Works_On (ESSN, PNO, HOURS) VALUES
('123456779', 1, 10),
('987655321', 2, 8);

INSERT INTO Dependent (ESSN, DEPENDENT_NAME, SEX, BDATE, RELATIONSHIP) VALUES
('123456779', 'Fatma', 'F', '2004-03-03', 'Wife'),
('987655321', 'Afsha', 'M', '2012-04-04', 'Son');




--task1
SELECT D.*, E.FNAME, E.LNAME
FROM Dependent D
JOIN Employee E ON D.ESSN = E.SSN;



--task2
SELECT E.FNAME, E.LNAME, P.PNAME
FROM Employee E
JOIN Works_On W ON E.SSN = W.ESSN
JOIN Project P ON W.PNO = P.PNUMBER
ORDER BY P.PNAME;

--task3

SELECT DISTINCT TOP 2 SALARY
FROM Employee
ORDER BY SALARY DESC;


--task4
SELECT FNAME, LNAME, COALESCE(SALARY, 3000) AS SALARY
FROM Employee;

--Task5
SELECT e.FNAME, S.SSN AS SupervisorID
FROM Employee e
LEFT JOIN Employee s ON e.SupervisorID = s.EmployeeID;


--task6
SELECT *
FROM Employee
WHERE Salary = (
    SELECT DISTINCT TOP 1 Salary
    FROM (
        SELECT DISTINCT TOP 2 Salary
        FROM Employee
        ORDER BY Salary DESC
    ) AS subquery
    ORDER BY Salary ASC
);

--task7
SELECT *
FROM Project
WHERE PNAME LIKE 'P%';



--task8
ALTER TABLE Employee
ADD CONSTRAINT Check_Salary_Less_Than_6000 CHECK (SALARY < 6000);




--task9

UPDATE Employee
SET ADDRESS = 'mansoura'
WHERE ADDRESS NOT IN ('alex', 'mansoura', 'cairo');

ALTER TABLE Employee
ADD CONSTRAINT CK_Address CHECK (ADDRESS IN ('alex', 'mansoura', 'cairo'));


--task10
CREATE FUNCTION CheckEmployeeName (@SSN CHAR(9))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Message NVARCHAR(100);
    SELECT @Message = 
        CASE 
            WHEN FNAME IS NULL AND LNAME IS NULL THEN 'First name & last name are null'
            WHEN FNAME IS NULL THEN 'First name is null'
            WHEN LNAME IS NULL THEN 'Last name is null'
            ELSE 'First name & last name are not null'
        END
    FROM Employee
    WHERE SSN = @SSN;
    RETURN @Message;
END;

SELECT dbo.CheckEmployeeName('123456778') AS Result;


--task11
CREATE FUNCTION GetNameDetails (@Type NVARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT 
        CASE 
            WHEN @Type = 'first name' THEN FNAME 
            WHEN @Type = 'last name' THEN LNAME 
            ELSE NULL 
        END AS Name 
    FROM Employee
);

SELECT Name FROM GetNameDetails('first name');

--task12
CREATE VIEW ProjectEmployeeCount AS
SELECT P.PNAME AS ProjectName, COUNT(W.ESSN) AS EmployeeCount
FROM Project P
LEFT JOIN Works_On W ON P.PNUMBER = W.PNO
GROUP BY P.PNAME;


SELECT * FROM ProjectEmployeeCount;

--task13
CREATE VIEW DeptEmployee AS
SELECT E.SSN AS EmployeeNumber, E.LNAME
FROM Employee E
JOIN Department D ON E.DNO = D.DNUMBER
WHERE D.DNUMBER = 1;

SELECT *
FROM DeptEmployee;

--task14
CREATE PROCEDURE UpdateEmployeeAssignment
    @OldEmpNumber CHAR(9),
    @NewEmpNumber CHAR(9),
    @ProjectID INT,
    @NewHoursWorked DECIMAL(5,2)
AS
BEGIN
    UPDATE Works_On
    SET ESSN = @NewEmpNumber, HOURS = @NewHoursWorked
    WHERE ESSN = @OldEmpNumber AND PNO = @ProjectID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Assignment update failed. No matching records found.', 16, 1);
    END
END;


EXEC UpdateEmployeeAssignment 
    @OldEmpNumber = '123456779',  
    @NewEmpNumber = '987655321',  
    @ProjectID = 1,               
    @NewHoursWorked = 20.5;       


	SELECT * FROM Works_On;

	CREATE TABLE EmployeeAudit (
    UserName VARCHAR(50),
    Date DATETIME,
    Note VARCHAR(100)
);


--task15

CREATE TRIGGER DeleteEmployeeAudit
ON Employee
AFTER DELETE
AS
BEGIN
    INSERT INTO EmployeeAudit (UserName, Date, Note)
    SELECT 
        SYSTEM_USER, 
        GETDATE(), 
        CONCAT('Tried to delete row with key value = ', DELETED.SSN)
    FROM 
        DELETED;
END;

UPDATE Department
SET MGRSSN = NULL
WHERE MGRSSN = '123456779';

DELETE FROM Employee
WHERE SSN = '123456779';

SELECT SSN FROM Employee;