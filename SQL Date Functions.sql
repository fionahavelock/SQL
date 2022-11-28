/*Date Functions*/
/*Retrive orders placed in a specific year*/
SELECT c.CompanyName, COUNT(o.OrderID) AS NumOrders,
MIN(o.OrderDate) AS MinDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
ON o.CustomerID = c.CustomerID
/*Add clause where Year Function to select only those  rows whose order date was placed in 1996*/
WHERE YEAR(o.OrderDate) = 1996
GROUP BY c.CompanyName
ORDER BY NumOrders