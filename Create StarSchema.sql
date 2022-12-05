
USE SalesDW
CREATE TABLE dbo.Customer(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO

CREATE TABLE dbo.Product(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO

CREATE TABLE dbo.Country(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO

CREATE TABLE dbo.Region(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO
CREATE TABLE dbo.SalesChannel(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO
CREATE TABLE dbo.SaleData(
ROWID INT IDENTITY (1,1) PRIMARY KEY
)
GO
DROP TABLE dbo.SalesChannel

--Create Sales channel table
CREATE TABLE SalesChannel (
ChannelID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
ChannelName VARCHAR(10),
CreateTimeStamp DATETIME,
UpdateTimeStamp DATETIME
)
INSERT INTO SalesChannel
SELECT DISTINCT [SalesChannel],
CURRENT_TIMESTAMP AS CreateTimeStamp,
CURRENT_TIMESTAMP AS UpdateTimeStamp
FROM SalesDW.[dbo].ProductSales


--Alter Region table
ALTER TABLE Region
ADD RegionName VARCHAR(50)
GO

DROP TABLE dbo.Region
CREATE TABLE Region (
ChannelID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
RegionName VARCHAR(50),
CreateTimeStamp DATETIME,
UpdateTimeStamp DATETIME
)

INSERT INTO Region
SELECT DISTINCT [Region],
CURRENT_TIMESTAMP AS CreateTimeStamp,
CURRENT_TIMESTAMP AS UpdateTimeStamp
FROM SalesDW.[dbo].ProductSales

ALTER TABLE ProductSales
ADD RegionClean varchar(50)

