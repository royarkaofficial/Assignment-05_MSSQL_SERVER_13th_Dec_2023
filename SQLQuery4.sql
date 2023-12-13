-- Create Database
CREATE DATABASE Assessment05Db;
GO

-- Use the Database
USE Assessment05Db;
GO

-- Create Schema
CREATE SCHEMA bank;
GO

-- Recreate Customer Table with adjusted constraints
CREATE TABLE bank.Customer (
    CId INT PRIMARY KEY,
    CName NVARCHAR(255) NOT NULL,
    CEmail NVARCHAR(255) NOT NULL UNIQUE,
    Contact NVARCHAR(255) NOT NULL,
    CPwd NVARCHAR(255) NOT NULL,
    CONSTRAINT CK_Customer_CId CHECK (CId >= 1000),
    CONSTRAINT CK_Customer_CName CHECK (LEN(CName) >= 2),
    CONSTRAINT CK_Customer_Contact CHECK (LEN(Contact) >= 2),
    CONSTRAINT CK_Customer_UniqueKey CHECK (CName + CAST(CId AS NVARCHAR) + LEFT(Contact, 2) = CName + CAST(CId AS NVARCHAR) + LEFT(Contact, 2)),
    CONSTRAINT CK_Customer_Persisted_CPwd CHECK (SUBSTRING(CName + CAST(CId AS NVARCHAR) + Contact, LEN(CName + CAST(CId AS NVARCHAR) + Contact) - 1, 2) = RIGHT(Contact, 2))
);
GO

-- Recreate Trigger trgMailToCust
CREATE TRIGGER bank.trgMailToCust
ON bank.Customer
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Inserting record into MailInfo
    INSERT INTO bank.MailInfo (MailTo, MailDate, MailMessage)
    SELECT CEmail, GETDATE(), 'Your net banking password is: ' + CPwd + '. It is valid up to 2 days only. Update it.'
    FROM inserted;
END;
GO

-- Insert records into Customer Table
INSERT INTO bank.Customer (CId, CName, CEmail, Contact, CPwd)
VALUES
    (1001, N'John Doe', 'john.doe@email.com', '1234567890', 'pwd1'),
    (1002, N'Jane Smith', 'jane.smith@email.com', '9876543210', 'pwd2'),
    (1003, N'Bob Johnson', 'bob.johnson@email.com', '5551234567', 'pwd3');
GO

-- Check records from both tables
SELECT * FROM bank.Customer;
SELECT * FROM bank.MailInfo;