-------------------------------------------------------------------------------------------------------------------------------------------
/*	DATA SOURCE - https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak
	DATE OF DATA DOWNLOAD - 21ST NOVEMBER 2022 8:26AM
*/
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
/*AT THE END OF THIS QUERIES, THE FOLLOWING OBJECTIVES HAVE BEEN MET:
	1. THE NAMES AND COUNT OF EACH GROUPS, BY DEPARTMENT.
	2. THE HOURLY, AGE, YEARS AND EXPERIENCE CALCULATIONS HAVE BEEN INCLUDED INTO A TEMPORARY TABLE.
	3. THE TEMPORARY TABLE HAS BEEN QUERIED TO SHOW THE PRESENT/ABSENT HOURS, AND ALSO THE ORGANIZATION LEVEL.
	4. THE SUBCATEGORY IN EACH CATEGORY OF PRODUCTS HAS BEEN DISPLAYED.
	5. THE REASON FOR SCRAPPING PRODUCTS AND ALSO SHOWED THE COUNT OF SCRAPPED PRODUCTS IS ALSO PRESENTED BY JOINING TABLES.
	6. THE YEARLY QUANTITY AND YEARLY ACTUAL COSTS REQUIRED TO PRODUCE THIS QUANTITY IS SHOWED.
	7. THE DAYS DELAYED FOR COMMENCEMENT AND CONCLUSION OF WORK ARE ACCOUNTED FOR USING CASE STATEMENTS.
	8. THE LOCATIONS RESPONSIBLE FOR A DELAY OF WORK ORDERS ARE IDENTIFIED.
*/
-------------------------------------------------------------------------------------------------------------------------------------------
/*SELECTING DATA FROM HR.Department FOR USE*/
SELECT	GroupName, Name 
FROM HumanResources.Department

/*VIEWING NAMES UNDER EACH GROUP */
SELECT	GroupName, Name 
FROM HumanResources.Department
ORDER BY GroupName

/*CLASSIFYING NAMES INTO GROUPS*/
SELECT	GroupName, COUNT(Name) AS COUNT
FROM HumanResources.Department
GROUP BY GroupName
ORDER BY GroupName
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
 /*SELECTING DATA FROM HR.Employee FOR USE*/
SELECT	BusinessEntityID, OrganizationLevel,JobTitle, BirthDate, MaritalStatus,
		Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
FROM HumanResources.Employee

/*INCLUDING THE CALCULATIONS - HOURLY, AGE, YEARS EXPERIENCE AS A TEMP TABLE */
DROP TABLE IF EXISTS #emp
SELECT	BusinessEntityID, OrganizationLevel,JobTitle, MaritalStatus, Gender, 
		HireDate, YEAR(GETDATE()) - YEAR(HireDate) AS YearsExperience,
		BirthDate, YEAR(GETDATE()) - YEAR(BirthDate) AS Age,
		((8*5)*52) AS YearlyWorkingHours,VacationHours, SickLeaveHours, 
		VacationHours+SickLeaveHours AS TotalAbsentHours 
INTO #emp
FROM HumanResources.Employee

SELECT *
FROM #emp

/*QUERING TEMP TABLE*/
--- TOTAL PRESENT HOURS
SELECT *, (YearlyWorkingHours - TotalAbsentHours) AS TotalPresentHours
FROM #emp;
--- ABSENT HOURS BY ORGANIZATIONAL LEVEL
SELECT OrganizationLevel, SUM(TotalAbsentHours) AS TotalAbsentHours
FROM #emp
GROUP BY OrganizationLevel;
--- SHOW CATEGORY IN EACH ORGANIZATIONAL LEVEL
-- NULL
SELECT *
FROM #emp
WHERE OrganizationLevel IS NULL;
-- 1
SELECT *
FROM #emp
WHERE OrganizationLevel = 1;
--2
SELECT *
FROM #emp
WHERE OrganizationLevel = 2;
--3
SELECT *
FROM #emp
WHERE OrganizationLevel = 3;
--4
SELECT *
FROM #emp
WHERE OrganizationLevel = 4;
--- EMPLOYEES WITH NO VACATION HOURS
SELECT OrganizationLevel,JobTitle, VacationHours, SickLeaveHours, TotalAbsentHours
FROM #emp
WHERE VacationHours = 0

/*VISUALIZE ON TABLEAU*/
-- GENDER RATIO
-- YEARS EXPERIENCE BY AGE
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
/*SUBCATEGORY IN EACH PRODUCT CATEGORY*/
SELECT c.Name, COUNT(s.ProductSubcategoryID)
FROM [AdventureWorks2017].[Production].[ProductCategory] c
JOIN [AdventureWorks2017].[Production].[ProductSubcategory] s
ON c.ProductCategoryID =s.ProductCategoryID
GROUP BY c.Name 
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
/*WORK ORDER TABLE*/
SELECT *
FROM [AdventureWorks2017].[Production].[WorkOrder]

/*REASON FOR SCRAPPING*/
SELECT  s.Name, SUM(w.ScrappedQty) AS ScrappedQty
FROM [AdventureWorks2017].[Production].[WorkOrder] w
JOIN [AdventureWorks2017].[Production].[ScrapReason] s
ON w.ScrapReasonID = s.ScrapReasonID
GROUP BY s.Name
ORDER BY ScrappedQty DESC

/*COUNT OF SCRAPS BY PRODUCTID*/

SELECT ProductID, SUM(ScrappedQty) AS ScrappedQty 
FROM [AdventureWorks2017].[Production].[WorkOrder] 
GROUP BY ProductID
ORDER BY ScrappedQty DESC
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
/*TRANSACTION HISTORY TABLE*/
SELECT *
FROM [AdventureWorks2017].[Production].[TransactionHistory]


/*YEARLY ACTUAL COSTS*/
SELECT CONVERT(Date, TransactionDate) AS TransactionDate, SUM(ActualCost) AS ActualCost
FROM [AdventureWorks2017].[Production].[TransactionHistory]
GROUP BY TransactionDate
ORDER BY TransactionDate

/*YEARLY QUANTITY*/
SELECT CONVERT(Date, TransactionDate) AS TransactionDate, SUM(Quantity) AS Quantity
FROM [AdventureWorks2017].[Production].[TransactionHistory]
GROUP BY TransactionDate
ORDER BY TransactionDate
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
/*WORK ORDER TABLE*/
SELECT *
FROM [AdventureWorks2017].[Production].[WorkOrderRouting]

/*DAYS DELAYED TO COMMENCE WORK*/
SELECT	DATEDIFF(dd, ScheduledStartDate, ActualStartDate) AS StartDelayDay, 
		COUNT(DATEDIFF(dd, ScheduledStartDate, ActualStartDate)) AS Total, 
		CASE WHEN DATEDIFF(dd, ScheduledStartDate, ActualStartDate) = 0 THEN  'ON TIME'
			 WHEN DATEDIFF(dd, ScheduledStartDate, ActualStartDate) > 0 AND DATEDIFF(dd, ScheduledStartDate, ActualStartDate) <= 7 THEN '1'
			 WHEN DATEDIFF(dd, ScheduledStartDate, ActualStartDate) > 7 AND DATEDIFF(dd, ScheduledStartDate, ActualStartDate) <= 14 THEN '2'
			 WHEN DATEDIFF(dd, ScheduledStartDate, ActualStartDate) > 14 AND DATEDIFF(dd, ScheduledStartDate, ActualStartDate) <= 21 THEN '3'
			 WHEN DATEDIFF(dd, ScheduledStartDate, ActualStartDate) > 21 AND DATEDIFF(dd, ScheduledStartDate, ActualStartDate) <= 28 THEN '4'
		END AS WEEK
FROM [AdventureWorks2017].[Production].[WorkOrderRouting]
GROUP BY DATEDIFF(dd, ScheduledStartDate, ActualStartDate)
ORDER BY Total DESC


/*DAYS DELAYED TO CONCLUDE WORK*/
SELECT	DATEDIFF(dd, ScheduledEndDate, ActualEndDate) AS EndDelayDay, 
		COUNT(DATEDIFF(dd, ScheduledEndDate, ActualEndDate)) AS Total,
		CASE WHEN DATEDIFF(dd, ScheduledEndDate, ActualEndDate) = 0 THEN  'ON TIME'
			 WHEN DATEDIFF(dd, ScheduledEndDate, ActualEndDate) > 0 AND DATEDIFF(dd, ScheduledEndDate, ActualEndDate) <= 7 THEN '1'
			 WHEN DATEDIFF(dd, ScheduledEndDate, ActualEndDate) > 7 AND DATEDIFF(dd, ScheduledEndDate, ActualEndDate) <= 14 THEN '2'
			 WHEN DATEDIFF(dd, ScheduledEndDate, ActualEndDate) > 14 AND DATEDIFF(dd, ScheduledEndDate, ActualEndDate) <= 21 THEN '3'
			 WHEN DATEDIFF(dd, ScheduledEndDate, ActualEndDate) > 21 AND DATEDIFF(dd, ScheduledEndDate, ActualEndDate) <= 28 THEN '4'
		END AS WEEK
FROM [AdventureWorks2017].[Production].[WorkOrderRouting]
GROUP BY DATEDIFF(dd, ScheduledEndDate, ActualEndDate)
ORDER BY Total DESC

/*DELAY BY LOCATION*/
SELECT LocationID, SUM(DATEDIFF(dd, ScheduledStartDate, ActualStartDate)) AS StartDelayDay
FROM [AdventureWorks2017].[Production].[WorkOrderRouting]
GROUP BY LocationID
ORDER BY StartDelayDay DESC
-------------------------------------------------------------------------------------------------------------------------------------------
