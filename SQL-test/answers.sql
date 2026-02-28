
-- Question 1: Create Departments table and insert data

CREATE TABLE Departments (
    DepartmentID   INT            NOT NULL IDENTITY(1,1), --start at 1 and increment by 1
    DepartmentName NVARCHAR(50)   NOT NULL,
    CONSTRAINT PK_Departments PRIMARY KEY (DepartmentID) -- set as primary key
);

-- inserting departments
-- ID will be auto assigned, so we just need name
INSERT INTO Departments (DepartmentName)
VALUES
    ('Sales'),
    ('Marketing'),
    ('Engineering'),
    ('Finance'),
    ('Operations');



-- Question 2: Create Employees table and insert data

-- DepartmentID is nullable for people like Ted with no department
CREATE TABLE dbo.Employees (
    EmployeeID   INT           NOT NULL IDENTITY(1,1),
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    DepartmentID INT           NULL,
    CONSTRAINT PK_Employees   PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Employees_Departments
    -- FK references department
        FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- temporarily allow ID insert so we are sure they are as stated in question
SET IDENTITY_INSERT dbo.Employees ON;

INSERT INTO dbo.Employees (EmployeeID, FirstName, LastName, DepartmentID)
VALUES
    (1, 'John',    'Doe',     1),
    (2, 'Jane',    'Smith',   2),
    (3, 'Mark',    'Johnson', 3),
    (4, 'Emily',   'Brown',   2),
    (5, 'Michael', 'Clark',   1),
    (6, 'Susan',   'Lee',     3),
    (7, 'Ted',     'McCall',  NULL);   -- no department yet

SET IDENTITY_INSERT dbo.Employees OFF;



-- Question 3: Create Salaries table and insert  data


-- employee can have multiple salary records over time, so use 
-- (EmployeeID, EffectiveDate) as PK to differentiate different records
-- EmployeeID good FK for integrity
CREATE TABLE Salaries (
    EmployeeID    INT             NOT NULL,
    Salary        DECIMAL(10, 2)  NOT NULL,
    EffectiveDate DATE            NOT NULL,
    CONSTRAINT PK_Salaries PRIMARY KEY (EmployeeID, EffectiveDate),
    CONSTRAINT FK_Salaries_Employees
        FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
);

INSERT INTO Salaries (EmployeeID, Salary, EffectiveDate)
VALUES
    (1, 40000.00, '2013-01-01'),
    (1, 41000.00, '2015-01-01'),
    (2, 50000.00, '2014-01-02'),
    (3, 35000.00, '2015-01-03'),
    (4, 45000.00, '2018-12-05'),
    (5, 42000.00, '2019-11-06'),
    (6, 38000.00, '2017-07-07');



-- Question 4: View — Employees with department name & current salary


-- We'll use a view to avoid complexity of a JOIN

-- current salary will be the one for a specific employee with
-- most recent EffectiveDate
GO
CREATE VIEW vw_EmployeeCurrentSalary AS
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        d.DepartmentName,
        ISNULL(s.Salary, 0) AS CurrentSalaryGBP -- handle no salary
    FROM dbo.Employees e
    LEFT JOIN Departments d
        ON e.DepartmentID = d.DepartmentID
    OUTER APPLY (
        SELECT TOP 1 Salary
        FROM Salaries
        WHERE EmployeeID = e.EmployeeID
        ORDER BY EffectiveDate DESC
    ) s;
GO
GO

-- test view — no filter 
SELECT * FROM vw_EmployeeCurrentSalary;

-- test the view — apply a filter
SELECT * FROM vw_EmployeeCurrentSalary
WHERE DepartmentName = 'Engineering';



-- Question 5: Average current salary across all salaried employees


-- only include employees with a salary (excluding Ted), filter salary>0
SELECT
    AVG(CurrentSalaryGBP) AS AverageCurrentSalaryGBP
FROM vw_EmployeeCurrentSalary
WHERE CurrentSalaryGBP > 0;



-- Question 6: Employee with the highest current salary


-- select TOP 1 with salaries descending - ties will allow multiple if there is a tie
-- 
SELECT TOP 1 WITH TIES
    EmployeeID,
    FirstName,
    LastName,
    DepartmentName,
    CurrentSalaryGBP
FROM vw_EmployeeCurrentSalary
ORDER BY CurrentSalaryGBP DESC;



-- Question 7: Total salary for Engineering department employees


SELECT
    SUM(CurrentSalaryGBP) AS TotalEngineeringSalaryGBP
FROM vw_EmployeeCurrentSalary
WHERE DepartmentName = 'Engineering'
  AND CurrentSalaryGBP > 0;



-- Question 8: Employees earning above the average salary


-- Subquery to calculate average - outer query filters against it
SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentName,
    CurrentSalaryGBP
FROM vw_EmployeeCurrentSalary
WHERE CurrentSalaryGBP > (
    SELECT AVG(CurrentSalaryGBP)
    FROM vw_EmployeeCurrentSalary
    WHERE CurrentSalaryGBP > 0
);



-- Question 9: Insert new employee Mary Johnson (Marketing, £47000)


-- marketing already exists with ID 2, would insert into departments table otherwise

-- insert employee — ID will be auto-generated
INSERT INTO dbo.Employees (FirstName, LastName, DepartmentID)
VALUES ('Mary', 'Johnson', 2);

-- insert salary using SCOPE_IDENTITY() to get the EmployeeID that was just generated
INSERT INTO Salaries (EmployeeID, Salary, EffectiveDate)
VALUES (SCOPE_IDENTITY(), 47000.00, CAST(GETDATE() AS DATE)); -- remove time from date



-- Question 10: Update current salary for all Sales employees to £44000


-- insert a new salary record dated today rather than updating existing

INSERT INTO Salaries (EmployeeID, Salary, EffectiveDate)
SELECT
    e.EmployeeID,
    44000.00,
    CAST(GETDATE() AS DATE)
FROM dbo.Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID -- match department ID
WHERE d.DepartmentName = 'Sales';



-- Question 11: Increase all current salaries by 5%


-- again, insert a new salary record dated today rather than updating existing
INSERT INTO Salaries (EmployeeID, Salary, EffectiveDate)
SELECT
    EmployeeID,
    ROUND(CurrentSalaryGBP * 1.05, 2), -- 5% increase
    CAST(GETDATE() AS DATE)
FROM vw_EmployeeCurrentSalary
WHERE CurrentSalaryGBP > 0;



-- Question 12: Transaction — update EmployeeID 3 salary & department


-- SERIALIZABLE to lock data during transaction

-- OUTPUT shows the before/after values within the transaction


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

BEGIN TRY

    -- update department to sales
    UPDATE dbo.Employees
    SET DepartmentID = 1
    WHERE EmployeeID = 3;

    -- insert new  salary record for EmployeeID 3
    -- UseOUTPUT to show what was inserted
    INSERT INTO Salaries (EmployeeID, Salary, EffectiveDate)
    OUTPUT
        inserted.EmployeeID     AS EmployeeID,
        inserted.Salary         AS NewSalaryGBP,
        inserted.EffectiveDate  AS EffectiveDate
    VALUES (3, 47000.00, CAST(GETDATE() AS DATE));

    COMMIT TRANSACTION;

    -- display all employees with their new department and current salary
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        DepartmentName      AS NewDepartment,
        CurrentSalaryGBP    AS NewCurrentSalaryGBP
    FROM vw_EmployeeCurrentSalary
    ORDER BY EmployeeID;

END TRY
BEGIN CATCH

    -- if anything fails, roll back changes
    ROLLBACK TRANSACTION;

    -- show error
    SELECT
        ERROR_NUMBER()    AS ErrorNumber,
        ERROR_MESSAGE()   AS ErrorMessage,
        ERROR_SEVERITY()  AS Severity;

END CATCH;
