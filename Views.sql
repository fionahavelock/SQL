/*Initial query which can be made into a view*/
/*
USE QATSQLPLUS
SELECT V.VendorName, C.CourseName, C.CourseID
	FROM dbo.Vendor AS V
		INNER JOIN dbo.Course AS C
			ON V.VendorID = C.VendorID
*/
/*View*/

CREATE VIEW dbo.CourseList AS

	SELECT V.VendorName, C.CourseName, C.CourseID
		FROM dbo.Vendor AS V
			INNER JOIN dbo.Course AS C
				ON V.VendorID = C.VendorID
GO
SELECT * FROM dbo.CourseList