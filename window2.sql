USE QATSQLPLUS
SELECT * 
FROM dbo.VendorCourseDelegateCount

SELECT *,
RANK() OVER (ORDER BY NumberDelegates DESC)
AS LeaguePos_Rank, 
DENSE_RANK() OVER (ORDER BY NumberDelegates DESC)
AS LeaguePos_DenseRank,
ROW_NUMBER() OVER (ORDER BY NumberDelegates DESC)
AS LeaguePos_Row,
NTILE(3) OVER (ORDER BY NumberDelegates DESC)
AS LeaguePos_Ntile
FROM dbo.VendorCourseDelegateCount
GO

SELECT *
FROM dbo.VendorCourseDelegateCount
GO

SELECT *, RANK () OVER (PARTITION BY Vendorname ORDER BY
NumberDelegates DESC)
FROM dbo.VendorCourseDelegateCount
GO

WITH Ranked_Courses AS (
SELECT *, 
RANK() OVER (PARTITION BY VendorName
ORDER BY NumberDelegates DESC) AS LeaguePos
FROM dbo.VendorCourseDelegateCount
)
SELECT VendorName, CourseName NumberDelegates
FROM Ranked_Courses
WHERE LeaguePos = 1
GO
USE QATSQLPLUS
SELECT VendorName, CourseName, NumberDelegates
FROM (SELECT *,
RANK() OVER (PARTITION BY VendorName
ORDER BY NumberDelegates DESC) AS LeaguePos
FROM dbo.VendorCourseDelegateCount
) AS DT
WHERE LeaguePos = 1
GO