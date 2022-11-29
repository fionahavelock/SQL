--Common table expression
/*
USE QATSQLPLUS
SELECT CourseRunID, StartDate
	FROM dbo.Trainer AS T
		INNER JOIN dbo.CourseRun AS CR
			ON T.TrainerID = CR.TrainerID
WHERE TrainerName = 'Jason Bourne'
*/
/*
WITH BourneCourses AS (
SELECT CourseRunID, StartDate
FROM dbo.Trainer AS T
INNER JOIN dbo.CourseRun AS CR
ON T.TrainerID = CR.TrainerID
WHERE TrainerName = 'Jason Bourne'
)
SELECT *
FROM BourneCourses
*/

WITH BourneCourses AS (
SELECT CourseRunID, StartDate
FROM dbo.Trainer AS T
INNER JOIN dbo.CourseRun AS CR
ON T.TrainerID = CR.TrainerID
WHERE TrainerName = 'Jason Bourne'
)
SELECT D.DelegateID, D.DelegateName, D.CompanyName, JB.StartDate
FROM dbo.Delegate AS D
INNER JOIN dbo.DelegateAttendance AS DA
ON D.DelegateID = DA.DelegateID
INNER JOIN BourneCourses AS JB
ON DA.CourseRunID = JB.CourseRunID