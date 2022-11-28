/*Modify a query so that it outputs an informational
message rather than the word null 
modify the query so that it formats the dates*/


SELECT c.CompanyName, COUNT(o.OrderID) AS NumOrders, 
ISNULL (MIN(o.OrderDate),  'None placed') AS MinDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = 1996
GROUP BY c.CompanyName
ORDER BY NumOrders

/*Use the convert function to format a datetime column*/
SELECT c.CompanyName, COUNT(o.OrderID) AS NumOrders, 
ISNULL(
	CONVERT(VARCHAR(20),
	/*Min aggregrate function*/
	MIN(o.OrderDate),
	106)
	'None Placed') AS MinDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = 1996
GROUP BY c.CompanyName
ORDER BY NumOrders