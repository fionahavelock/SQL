-- That finds revenue per year from a provided starting year


ALTER FUNCTION dbo.RevenuePerYear(@StartYear INT)
RETURNS @Revenue TABLE(FinancialYears INT, Revenue MONEY)
BEGIN --START
	INSERT INTO @Revenue
		SELECT YEAR(OrderDate) AS [Year], SUM(UnitPrice * Quantity) AS TotalRevenue
		FROM dbo.Orders AS o Join dbo.[OrderDetails] AS od ON o.OrderID = od.OrderID
		WHERE YEAR(OrderDate) >= @StartYear
		Group BY YEAR (OrderDate)
		ORDER BY [YEAR] ASC

	RETURN
END --STOP
GO
SELECT * FROM Northwind.dbo.RevenuePerYear(1998) 
GO