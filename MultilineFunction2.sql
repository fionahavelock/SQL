ALTER FUNCTION dbo.udf_IndividualDelegateDays(@DelegateID INT)
	RETURNS TABLE
	AS 
	RETURN (
		SELECT @DelegateID AS DelegateID,
		SUM(CR.DurationDays) AS DelegateDays,
			COUNT(*) AS DelegateCourses
			FROM dbo.Delegate AS D
				INNER JOIN dbo.DelegateAttendance AS DA
				ON D.DelegateID = DA.DelegateID
				INNER JOIN dbo.CourseRun AS CR
				ON CR.CourseRunID = DA.CourseRunID
				WHERE D.DelegateID = @DelegateID
	)
	GO
	
	SELECT * FROM dbo.udf_IndividualDelegateDays(1)