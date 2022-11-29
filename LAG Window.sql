
-- Positional 
--Find Total orderss per year and total orders for last year
USE Northwind
SELECT 
YEAR(OrderDate) AS OrderYear, 
COUNT(OrderId) AS TotalOrders, 
LAG (COUNT(OrderID), 1, NULL) OVER (ORDER BY YEAR(OrderDate)) AS LastYear,
COUNT(OrderId) - LAG (COUNT(OrderID), 1, NULL) OVER (ORDER BY YEAR(OrderDate)) AS YearChnge
FROM dbo.Orders 
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear ASC
