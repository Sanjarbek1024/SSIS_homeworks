USE SSIS4
GO

CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    LoadDate DATETIME
);

CREATE TABLE dbo.PackageLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    FileName NVARCHAR(255),
    Status NVARCHAR(50),
    LogDate DATETIME,
    PackageName NVARCHAR(100),
    ErrorMessage NVARCHAR(MAX)
);


truncate table Customers
truncate table PackageLog

Select * from Customers
Select * from PackageLog

