USE QATSQLPLUS
SELECT ProductID, TransferDate, TransferAmount
FROM dbo.BookTransfers

SELECT ProductID, SUM(TransferAmount) AS Stock
FROM dbo.BookTransfers
GROUP BY ProductID

SELECT ProductID, TransferDate, TransferAmount, 
	SUM(TransferAmount) OVER 
	(PARTITION BY ProductID ORDER BY TransferDate)
	AS RunningStock
	FROM dbo.BookTransfers