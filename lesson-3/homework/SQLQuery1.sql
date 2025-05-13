USE SSIS3
GO

CREATE TABLE SalaryFactTable (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Salary INT
);

INSERT INTO SalaryFactTable (ID, Name, Age, Salary) VALUES
(1, 'John Smith', 30, 50000),
(2, 'Jane Doe', 28, 60000),
(3, 'Mike Ross', 35, 45000),
(4, 'Rachel Zane', 33, 75000),
(5, 'Donna Paulsen', 40, 85000);


SELECT * FROM SalaryFactTable;

-- ===============================================


CREATE TABLE SecondSalaryTable (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary INT
);

INSERT INTO SecondSalaryTable (ID, Name, Department, Salary) VALUES
(101, 'Alex Pearson', 'IT', 55000),
(102, 'Samantha Harvey', 'HR', 67000),
(103, 'Harvey Specter', 'Legal', 90000),
(104, 'Louis Litt', 'Legal', 80000),
(105, 'Sheila Sazs', 'Finance', 60000);

SELECT * FROM SecondSalaryTable;


SELECT ID, Name, Department, Salary
FROM SecondSalaryTable
WHERE Salary > 63000


-- Step 1: Calculate the average salary from the SalaryFactTable (First Salary Table)
-- Step 2: Select the records from the SecondSalaryFactTable (Second Salary Table) where the salary is greater than the average from the First Salary Table

SELECT
    s.ID,
    s.Name,
    s.Department,
    s.Salary
FROM
    SecondSalaryTable s
WHERE
    s.Salary > (SELECT AVG(f.Salary) FROM SalaryFactTable f)


