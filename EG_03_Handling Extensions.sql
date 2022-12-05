-----------------------------------
-- EG_01 Extension Exercise
-- Product Sales Update Script
-- March 2020
--------------------------

-- Ensure to import the correct datatypes as before

-- Alter ProductSalesUpdate to have two new cleansed columns for Region and Country
ALTER TABLE [dbo].[ProductSalesUpdate]
ADD CountryClean varchar(50)


ALTER TABLE [dbo].[ProductSalesUpdate]
ADD RegionClean varchar(50)


-- Testing Geography Table

SELECT *
FROM dimCountry c
JOIN dimRegion r ON c.regionid = r.regionid
ORDER BY c.regionid,countryid

-- Update ProductSalesUpdateClean to change Country = "UK" to "United Kingdom" for matching

UPDATE ProductSalesUpdate
SET CountryClean = CASE WHEN Country = 'UK' then 'United Kingdom'
						ELSE Country
						END


SELECT * from ProductSalesUpdate

--See which countries match the dimCountry Table

SELECT DISTINCT P.CountryClean,P.Region,DC.*
FROM ProductSalesUpdate P
LEFT JOIN dimCountry DC ON P.CountryClean = DC.CountryName


-- Update ProductSalesUpdate to have North America region for US.
UPDATE ProductSalesUpdate
SET RegionClean = 'North America'
WHERE Country = 'United States'

------------------------------------------------------------------------------------
-- Create Copies of the tables for Loading so as not to interfere with "LIVE"
------------------------------------------------------------------------------------

-- Drop Mirror Tables (order Important)
DROP TABLE factSale_mr
DROP TABLE dimCountry_mr
DROP TABLE dimSalesChannel_mr
DROP TABLE dimRegion_mr
DROP TABLE dimCustomer_mr
DROP TABLE dimProduct_mr


-- Create Mirror Tables (order Important)
CREATE TABLE dimSalesChannel_mr
( 
 	ChannelID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	ChannelName VARCHAR(10), 
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 


CREATE TABLE dimRegion_mr
( 
 	RegionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	RegionName VARCHAR(50), 
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

CREATE TABLE dimCustomer_mr
( 
 	CustID INT NOT NULL PRIMARY KEY, 
 	CustName VARCHAR(50),
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

CREATE TABLE dimProduct_mr
(
	ProductID VARCHAR(8)  PRIMARY KEY,
	ProductName VARCHAR(50),
	StdCost NUMERIC(8,2),
	StdPrice NUMERIC (8,2),
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
)

CREATE TABLE dimCountry_mr
( 
 	CountryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	CountryName VARCHAR(50), 
   	RegionID INT FOREIGN KEY REFERENCES dimRegion_mr(RegionID),
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

CREATE TABLE factSale_mr
( 
    SaleID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    DateSold Date NOT NULL, 
 	ProductID VARCHAR(8) NOT NULL FOREIGN KEY REFERENCES dimProduct_mr(ProductID),
    CustID INT NOT NULL FOREIGN KEY REFERENCES dimCustomer_mr(CustID), 
    CountryID INT NOT NULL FOREIGN KEY REFERENCES dimCountry_mr(CountryID), 
    ChannelID INT NOT NULL FOREIGN KEY REFERENCES dimSalesChannel_mr(ChannelID), 
    UnitsSold INT NOT NULL,
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

--- Insert into Mirror Tables
--- IDENTITY_INSERT needs to be turned off and on each time for where we have an IDENTITY column
--- IDENTITY_INSERT is set on a table level and when set to ON allows records to be inserted with an identity value already set (from the non mirror table)

SET IDENTITY_INSERT dimSalesChannel_mr ON
INSERT INTO dimSalesChannel_mr (ChannelID,ChannelName,CreateTimestamp,UpdateTimestamp)
SELECT ChannelID,
ChannelName,
CreateTimestamp,
UpdateTimestamp 
FROM dimSalesChannel
SET IDENTITY_INSERT dimSalesChannel_mr OFF


SET IDENTITY_INSERT [dbo].[dimRegion_mr] ON
INSERT INTO [dbo].[dimRegion_mr] ([RegionID],[RegionName],[CreateTimestamp],[UpdateTimestamp])
SELECT * FROM [dbo].[dimRegion]
SET IDENTITY_INSERT [dimRegion_mr] OFF


SET IDENTITY_INSERT [dimCountry_mr] ON
INSERT INTO [dbo].[dimCountry_mr] ([CountryID],[CountryName],[RegionID],[CreateTimestamp],[UpdateTimestamp])
SELECT * FROM dimCountry
SET IDENTITY_INSERT [dimCountry_mr] OFF

INSERT INTO [dbo].[dimCustomer_mr] 
SELECT * FROM [dbo].[dimCustomer]

INSERT INTO [dbo].[dimProduct_mr]
SELECT * FROM [dbo].[dimProduct]


SET IDENTITY_INSERT [dbo].[factSale_mr] ON
INSERT INTO [dbo].[factSale_mr] ([SaleID],[DateSold],[ProductID],[CustID],[CountryID],[ChannelID],[UnitsSold],[CreateTimestamp],[UpdateTimestamp])
SELECT * FROM [dbo].[factSale]
SET IDENTITY_INSERT [dbo].[factSale_mr] OFF


----------------------------------------------------------------------
-- Adding Country Records to dimCountry
----------------------------------------------------------------------

--Method 1: Add new Country row to dimCountry (Using MERGE statement)

MERGE INTO dimCountry_mr AS t
USING (SELECT DISTINCT CountryClean,regionID,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
		FROM ProductSalesUpdate U
		JOIN dimRegion_mr R on U.RegionClean = R.RegionName) AS s ON s.CountryClean = t.countryname
WHEN NOT MATCHED THEN INSERT (countryName,RegionID,createtimestamp,updatetimestamp ) VALUES (s.CountryClean,s.RegionID,s.createtimestamp,s.updatetimestamp);

--Method 2: Add new Country row to dimCountry (Using Insert into statement)
INSERT INTO dimCountry_mr
SELECT DISTINCT U.CountryClean,R.regionID,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
FROM ProductSalesUpdate U
INNER JOIN dimRegion_mr R ON U.RegionClean = R.RegionName 
LEFT JOIN dimCountry_mr C ON U.countryClean = C.countryName
WHERE C.countryName IS NULL

----------------------------------------------------------------------
-- Adding SalesChannel records to dimSalesChannel
----------------------------------------------------------------------

--Method 1:  Add new SalesChannel to dimSalesChannel (Using MERGE statement)
MERGE INTO dimSalesChannel_mr AS t
USING (SELECT DISTINCT salesChannel,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp 
		FROM ProductSalesUpdate) AS s ON s.salesChannel = t.ChannelName
WHEN NOT MATCHED THEN INSERT(ChannelName,createtimestamp,updatetimestamp ) VALUES (s.SalesChannel,s.createtimestamp,s.updatetimestamp);

--Method 2: 
INSERT INTO dimSalesChannel_mr
SELECT DISTINCT U.SalesChannel,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
FROM ProductSalesUpdate U
LEFT JOIN dimSalesChannel_mr S ON U.SalesChannel = S.ChannelName
WHERE S.ChannelID is NULL

----------------------------------------------------------------------
-- Adding Product records to DimProduct
----------------------------------------------------------------------

--Method 1:   Add new products to dimProduct (Using MERGE statement)
MERGE INTO dimProduct_mr as t
USING (SELECT DISTINCT ProductID,ProductName,stdCost,stdPrice,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp 
		FROM ProductSalesUpdate ) AS s ON s.ProductID = t.productID
WHEN NOT MATCHED THEN INSERT(ProductID,ProductName,StdCost,StdPrice,createtimestamp,updatetimestamp) VALUES (s.ProductID,s.ProductName,s.StdCost,s.StdPrice,s.createtimestamp,s.updatetimestamp);


--Method 2: 
INSERT INTO dimProduct_mr
SELECT DISTINCT U.ProductID,U.ProductName,U.stdCost,U.stdPrice,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
FROM ProductSalesUpdate U
LEFT JOIN dimProduct_mr PR on U.productID = PR.productID
WHERE PR.productID IS NULL

----------------------------------------------------------------------
-- Adding Fact Records to FactSale
----------------------------------------------------------------------

--Method 1:   Add new customers to dimCustomer (Using MERGE statement)
MERGE INTO dimCustomer_mr as t
USING (SELECT DISTINCT custid,custName, CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
		FROM ProductSalesUpdate) AS s ON s.custID = t.custID
WHEN NOT MATCHED THEN INSERT(custID,custName,createtimestamp,updatetimestamp) VALUES (s.custID,s.custName,s.createtimestamp,s.updatetimestamp);


--Method 2: 
INSERT INTO dimCustomer_mr
SELECT DISTINCT U.custID,U.custName,CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
FROM ProductSalesUpdate U
LEFT JOIN dimCustomer_mr C on U.custID= C.custID
WHERE C.custID IS NULL

----------------------------------------------------------------------
-- Adding Fact Records
----------------------------------------------------------------------

--Method 1:  Add new records into factSales (Using MERGE statement)
MERGE INTO factSale_mr AS t
USING (SELECT DISTINCT U.DateSold,U.ProductID,U.custID,C.countryID,SC.channelID,U.UnitsSold, CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
		FROM ProductSalesUpdate U
		JOIN dimCountry_mr C on U.CountryClean = C.countryName
		JOIN dimSalesChannel_mr SC on u.saleschannel = SC.channelName
		) AS s ON s.dateSold = t.DateSold AND 
				s.ProductID = t.ProductID AND 
				s.custID = t.custID AND
				s.ChannelID = t.ChannelID AND
				s.countryID = t.countryID
WHEN NOT MATCHED THEN 
	INSERT(DateSold,ProductID,CustID,CountryID,ChannelID,UnitsSold,createtimestamp,updatetimestamp) VALUES (s.DateSold,s.productID,s.custID,S.countryID,S.ChannelID,S.UnitsSold,s.createtimestamp,s.updatetimestamp);


--Method 2: dd new records into factSales (Using Insert into statement)
INSERT INTO factSale_mr
SELECT DISTINCT U.DateSold,U.ProductID,U.custID,C.countryID,SC.channelID,U.UnitsSold, CURRENT_TIMESTAMP AS createtimestamp,CURRENT_TIMESTAMP AS updatetimestamp
FROM ProductSalesUpdate U
JOIN dimCountry_mr C ON U.CountryClean = C.countryName
JOIN dimSalesChannel_mr SC ON U.saleschannel = SC.channelName
LEFT JOIN factSale_mr F ON	U.dateSold = F.DateSold AND 
						U.ProductID = F.ProductID AND 
						U.custID = F.custID AND
						SC.ChannelID = F.ChannelID AND
						C.countryID = F.countryID
WHERE F.SaleID IS NULL


------------------------------
-- Table Swap
------------------------------

exec sp_rename 'dimCountry' , 'dimCountry_tmp' 
exec sp_rename 'dimCountry_mr' , 'dimCountry' 
exec sp_rename 'dimCountry_tmp' , 'dimCountry_mr'

exec sp_rename 'dimRegion' , 'dimRegion_tmp' 
exec sp_rename 'dimRegion_mr' , 'dimRegion' 
exec sp_rename 'dimRegion_tmp' , 'dimRegion_mr'

exec sp_rename 'dimCustomer' , 'dimCustomer_tmp' 
exec sp_rename 'dimCustomer_mr' , 'dimCustomer' 
exec sp_rename 'dimCustomer_tmp' , 'dimCustomer_mr'

exec sp_rename 'dimProduct' , 'dimProduct_tmp' 
exec sp_rename 'dimProduct_mr' , 'dimProduct' 
exec sp_rename 'dimProduct_tmp' , 'dimProduct_mr'

exec sp_rename 'dimSalesChannel' , 'dimSalesChannel_tmp' 
exec sp_rename 'dimSalesChannel_mr' , 'dimSalesChannel' 
exec sp_rename 'dimSalesChannel_tmp' , 'dimSalesChannel_mr'

exec sp_rename 'factSale' , 'factSale_tmp' 
exec sp_rename 'factSale_mr' , 'factSale' 
exec sp_rename 'factSale_tmp' , 'factSale_mr'


------------------------------
-- End
------------------------------