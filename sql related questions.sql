
Identity
@@IDENTITY  ==>  last value inserted into the IDENTITY column of any table at any scope
SCOPE_IDENTITY() last value inserted into the IDENTITY column of any table at current scope
IDENT_CURRENT(Table_Name)	==>  last value inserted into the IDENTITY column of specified table at current scope



-- Error
@@ERROR ==> ErrorCode


select @@IDENTITY ,SCOPE_IDENTITY() , IDENT_CURRENT('demotable'), @@ERROR, ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_PROCEDURE(), ERROR_STATE()

-- Ranking


ROW_NUM1BER() OVER(ORDER BY ASC/DESC ColumnName) => Gives Row number
Rank() OVER(ORDER BY ASC/DESC ColumnName) => Gives Rank Based on frequency 
DENSE_RANK() OVER(ORDER BY ASC/DESC ColumnName) => Gives Rank Based on frequency 


select ROW_NUMBER() OVER(order by a.b) as rn,RANK() OVER (ORDER BY a.b) AS rnk,DENSE_RANK() OVER (ORDER BY a.b) AS dnrk, NTILE(4) OVER (ORDER BY a.b) AS Quartile,  b  as data from demotable a



rn                   rnk                  dnrk                 Quartile             data
-------------------- -------------------- -------------------- -------------------- -----------
1                    1                    1                    1                    5
2                    1                    1                    1                    5
3                    1                    1                    1                    5
4                    1                    1                    2                    5
5                    1                    1                    2                    5
6                    1                    1                    2                    5
7                    1                    1                    3                    5
8                    8                    2                    3                    6
9                    8                    2                    3                    6
10                   8                    2                    4                    6
11                   11                   3                    4                    101


@@ROWCOUNT => affected number of rows in last trasnsaction

@table ==> created in memory ==> current batch

#temp created in tempdb database ==> till current instance is open

##glbal ==> avaialble till all instances are closed


//sp_executesql

BEGIN 
DECLARE @IntVariable int;  
DECLARE @SQLString nvarchar(500);  
DECLARE @ParmDefinition nvarchar(500);  
  
/* Build the SQL string one time.*/  
SET @SQLString =  
     N'SELECT * from demotable where b = @BusinessEntityID';  
SET @ParmDefinition = N'@BusinessEntityID int';  
/* Execute the string with the first parameter value. */  
SET @IntVariable = 101;  
EXECUTE sp_executesql @SQLString, @ParmDefinition,  
                      @BusinessEntityID = @IntVariable;  
END 
GO


-- //Case 

CREATE PROCEDURE HumanResources.Update_VacationHours  
@NewHours smallint  
AS   
SET NOCOUNT ON;  
UPDATE HumanResources.Employee  
SET VacationHours =   
    ( CASE  
         WHEN SalariedFlag = 0 THEN VacationHours + @NewHours  
         ELSE @NewHours  
       END  
    )  
WHERE CurrentFlag = 1;  
GO  
  
EXEC HumanResources.Update_VacationHours 40;  


-- //Raising Error

 RAISERROR(@ErrorMessage, @ErrorSeverity, 1);  


 -- // stored procedure in/outparama


IF OBJECT_ID ( 'uspGetEmployees2', 'P' ) IS NOT NULL   
    DROP PROCEDURE uspGetEmployees2;  
GO  
CREATE PROCEDURE uspGetEmployees2   
    @LastName nvarchar(50) = N'D%',   
    @FirstName nvarchar(50) = N'%',
	@op int  out
AS   
    SET NOCOUNT ON;  
    SELECT * from demotable
	select top 1 @op=b from demotable
GO
declare @outp int
Execute uspGetEmployees2 @LastName = '', @FirstName = '' ,@op= @outp out



-- // table valued function


IF OBJECT_ID (N'Sales.ufn_SalesByStore', N'IF') IS NOT NULL  
    DROP FUNCTION Sales.ufn_SalesByStore;  
GO  
CREATE FUNCTION Sales.ufn_SalesByStore (@storeid int)  
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT P.ProductID, P.Name, SUM(SD.LineTotal) AS 'Total'  
    FROM Production.Product AS P   
    JOIN Sales.SalesOrderDetail AS SD ON SD.ProductID = P.ProductID  
    JOIN Sales.SalesOrderHeader AS SH ON SH.SalesOrderID = SD.SalesOrderID  
    JOIN Sales.Customer AS C ON SH.CustomerID = C.CustomerID  
    WHERE C.StoreID = @storeid  
    GROUP BY P.ProductID, P.Name  
); 



select * from ufn_SalesByStore()



-- / Fucntion return defained table

IF OBJECT_ID (N'dbo.ufn_FindReports', N'TF') IS NOT NULL  
    DROP FUNCTION dbo.ufn_FindReports;  
GO  
CREATE FUNCTION dbo.ufn_FindReports (@InEmpID INTEGER)  
RETURNS @retFindReports TABLE   
(  
    EmployeeID int primary key NOT NULL,  
    FirstName nvarchar(255) NOT NULL,  
    LastName nvarchar(255) NOT NULL,  
    JobTitle nvarchar(50) NOT NULL,  

    RecursionLevel int NOT NULL  
)  
--Returns a result set that lists all the employees who report to the   
--specific employee directly or indirectly.*/  
AS  
BEGIN  
WITH EMP_cte(EmployeeID, OrganizationNode, FirstName, LastName, JobTitle, RecursionLevel) -- CTE name and columns  
    AS (  
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, 0 -- Get the initial list of Employees for Manager n  
        FROM HumanResources.Employee e   
INNER JOIN Person.Person p   
ON p.BusinessEntityID = e.BusinessEntityID  
        WHERE e.BusinessEntityID = @InEmpID  
        UNION ALL  
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, RecursionLevel + 1 -- Join recursive member to anchor  
        FROM HumanResources.Employee e   
            INNER JOIN EMP_cte  
            ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode  
INNER JOIN Person.Person p   
ON p.BusinessEntityID = e.BusinessEntityID  
        )  
-- copy the required columns to the result of the function   
   INSERT @retFindReports  
   SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel  
   FROM EMP_cte   
   RETURN  
END;  
GO


-- CTE


WITH
  cteReports (EmpID, FirstName, LastName, MgrID, EmpLevel)
  AS
  (
    SELECT EmployeeID, FirstName, LastName, ManagerID, 1
    FROM Employees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID, 
      r.EmpLevel + 1
    FROM Employees e
      INNER JOIN cteReports r
        ON e.ManagerID = r.EmpID
  )
SELECT
  FirstName + ' ' + LastName AS FullName, 
  EmpLevel,
  (SELECT FirstName + ' ' + LastName FROM Employees 
    WHERE EmployeeID = cteReports.MgrID) AS Manager
FROM cteReports 
ORDER BY EmpLevel, MgrID 


-- Update with join

UPDATE
  books
SET
  books.primary_author = authors.name
FROM
  books
INNER JOIN
  authors
ON
  books.author_id = authors.id
WHERE
  books.title = 'The Hobbit'


