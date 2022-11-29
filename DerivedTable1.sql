-- Derived Tables
USE Northwind
SELECT * FROM (
SELECT TOP 3 CustomerId FROM orders GROUP BY CustomerID ORDER BY Count(CustomerID)
) AS DerivedTable

SELECT ProductName, UnitPrice, CategoryName, AveragePrice FROM Products AS p
INNER JOIN
(
SELECT 
CategoryID, 
AVG(UnitPrice) AS AveragePrice FROM PRODUCTS 
GROUP BY CategoryID
)
AS DerivedAveragePrice
ON 
p.CategoryID = DerivedAveragePrice.CategoryID
JOIN Categories c
ON 
p.CategoryID = c.CategoryID
WHERE UnitPrice >= AveragePrice