use AdventureWorks2022;

--task 1

WITH TaskChain AS (
    SELECT *,
           CASE 
               WHEN LAG(End_Date) OVER (ORDER BY Start_Date) = Start_Date THEN 0 
               ELSE 1 
           END AS Is_New_Project
    FROM Projects
),
GroupedProjects AS (
    SELECT *,
           SUM(Is_New_Project) OVER (ORDER BY Start_Date ROWS UNBOUNDED PRECEDING) AS ProjectGroup
    FROM TaskChain
),
ProjectSummary AS (
    SELECT 
        MIN(Start_Date) AS ProjectStart,
        MAX(End_Date) AS ProjectEnd,
        DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) + 1 AS Duration
    FROM GroupedProjects
    GROUP BY ProjectGroup
)
SELECT ProjectStart, ProjectEnd
FROM ProjectSummary
ORDER BY Duration ASC, ProjectStart ASC;


--task 2

SELECT S.Name
FROM Students S
JOIN Friends F ON S.ID = F.ID
JOIN Packages PS ON S.ID = PS.ID
JOIN Packages PF ON F.Friend_ID = PF.ID
WHERE PF.Salary > PS.Salary
ORDER BY PF.Salary;

--task 3


SELECT DISTINCT
    LEAST(f1.X, f1.Y) AS X,
    GREATEST(f1.X, f1.Y) AS Y
FROM Functions f1
JOIN Functions f2
    ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X < f1.Y
ORDER BY X;


SELECT DISTINCT
    CASE WHEN f1.X < f1.Y THEN f1.X ELSE f1.Y END AS X,
    CASE WHEN f1.X < f1.Y THEN f1.Y ELSE f1.X END AS Y
FROM Functions f1
JOIN Functions f2
    ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <> f1.Y
  AND f1.X <= f1.Y
ORDER BY X;


CREATE TABLE Functions (
    X INT,
    Y INT
);

INSERT INTO Functions (X, Y) VALUES
(20, 20),
(10, 6),
(11, 55),
(12, 12),
(20, 23),
(23, 20),
(22, 21),
(21, 22);

--task 4

SELECT 
    c.contest_id,
    c.hacker_id,
    c.name,
    ISNULL(SUM(ss.total_submissions), 0) AS total_submissions,
    ISNULL(SUM(ss.total_accepted_submissions), 0) AS total_accepted_submissions,
    ISNULL(SUM(vs.total_views), 0) AS total_views,
    ISNULL(SUM(vs.total_unique_views), 0) AS total_unique_views
FROM Contests c
JOIN Colleges col ON c.contest_id = col.contest_id
JOIN Challenges ch ON col.college_id = ch.college_id
LEFT JOIN View_Stats vs ON ch.challenge_id = vs.challenge_id
LEFT JOIN Submission_Stats ss ON ch.challenge_id = ss.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING 
    ISNULL(SUM(ss.total_submissions), 0) +
    ISNULL(SUM(ss.total_accepted_submissions), 0) +
    ISNULL(SUM(vs.total_views), 0) +
    ISNULL(SUM(vs.total_unique_views), 0) > 0
ORDER BY c.contest_id;


--task 5

WITH DateWiseSubmissions AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS submission_count
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-15'
    GROUP BY submission_date, hacker_id
),
MaxSubmissionsPerDay AS (
    SELECT 
        submission_date,
        MAX(submission_count) AS max_submissions
    FROM DateWiseSubmissions
    GROUP BY submission_date
),
TopHackers AS (
    SELECT 
        d.submission_date,
        d.hacker_id,
        d.submission_count,
        ROW_NUMBER() OVER (PARTITION BY d.submission_date ORDER BY d.submission_count DESC, d.hacker_id ASC) AS rn
    FROM DateWiseSubmissions d
)
SELECT 
    t.submission_date,
    (SELECT COUNT(DISTINCT hacker_id) 
     FROM DateWiseSubmissions 
     WHERE submission_date = t.submission_date) AS total_hackers,
    t.hacker_id,
    h.name
FROM TopHackers t
JOIN Hackers h ON t.hacker_id = h.hacker_id
WHERE t.rn = 1
ORDER BY t.submission_date;


--task 6

	SELECT 
    ROUND(
        ABS(MIN_LAT - MAX_LAT) + ABS(MIN_LONG - MAX_LONG),
        4
    ) AS ManhattanDistance
FROM (
    SELECT 
        MIN(LAT_N) AS MIN_LAT,
        MAX(LAT_N) AS MAX_LAT,
        MIN(LONG_W) AS MIN_LONG,
        MAX(LONG_W) AS MAX_LONG
    FROM STATION
) AS Coordinates;


--task 7

WITH Numbers AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n + 1 <= 1000
),
Primes AS (
    SELECT n
    FROM Numbers n1
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Numbers n2
        WHERE n2.n < n1.n AND n2.n > 1 AND n1.n % n2.n = 0
    )
)
SELECT STRING_AGG(CAST(n AS VARCHAR), '&') AS PrimeNumbers
FROM Primes
OPTION (MAXRECURSION 1000);


--task 8

WITH RankedNames AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM Occupations
),
Pivoted AS (
    SELECT 
        MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
        MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
        MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
        MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor,
        RowNum
    FROM RankedNames
    GROUP BY RowNum
)
SELECT Doctor, Professor, Singer, Actor
FROM Pivoted
ORDER BY RowNum;

--task 9

SELECT 
    N,
    CASE 
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM BST
ORDER BY N;


--task 10

SELECT 
    c.company_code,
    c.founder,
    COUNT(DISTINCT lm.lead_manager_code) AS total_lead_managers,
    COUNT(DISTINCT sm.senior_manager_code) AS total_senior_managers,
    COUNT(DISTINCT m.manager_code) AS total_managers,
    COUNT(DISTINCT e.employee_code) AS total_employees
FROM Company c
LEFT JOIN Lead_Manager lm 
    ON c.company_code = lm.company_code
LEFT JOIN Senior_Manager sm 
    ON c.company_code = sm.company_code
LEFT JOIN Manager m 
    ON c.company_code = m.company_code
LEFT JOIN Employee e 
    ON c.company_code = e.company_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code;

--task 11

	SELECT 
    s.Name
FROM 
    Students s
JOIN 
    Friends f ON s.ID = f.ID
JOIN 
    Packages sp ON s.ID = sp.ID      -- student's salary
JOIN 
    Packages fp ON f.Friend_ID = fp.ID  -- friend's salary
WHERE 
    fp.Salary > sp.Salary
ORDER BY 
    fp.Salary;


--task 12

	WITH CostSummary AS (
    SELECT
        SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) AS IndiaCost,
        SUM(CASE WHEN Country != 'India' THEN Cost ELSE 0 END) AS InternationalCost
    FROM JobCost
),
PercentageBreakdown AS (
    SELECT
        IndiaCost,
        InternationalCost,
        ROUND(IndiaCost * 100.0 / (IndiaCost + InternationalCost), 2) AS IndiaPercentage,
        ROUND(InternationalCost * 100.0 / (IndiaCost + InternationalCost), 2) AS InternationalPercentage
    FROM CostSummary
)
SELECT 
    CONCAT(IndiaPercentage, '%') AS India_Cost_Percentage,
    CONCAT(InternationalPercentage, '%') AS International_Cost_Percentage
FROM PercentageBreakdown;


--task 13
SELECT
    BU,
    FORMAT(OrderDate, 'yyyy-MM') AS YearMonth,
    SUM(CostAmount) AS TotalCost,
    SUM(RevenueAmount) AS TotalRevenue,
    CASE 
        WHEN SUM(RevenueAmount) = 0 THEN NULL
        ELSE ROUND((SUM(CostAmount) * 1.0 / SUM(RevenueAmount)) * 100, 2)
    END AS CostToRevenueRatioPercent
FROM
    YourBusinessUnitCostRevenueTable
GROUP BY
    BU,
    FORMAT(OrderDate, 'yyyy-MM')
ORDER BY
    BU,
    YearMonth;

--task 14
SELECT 
    JobTitle AS SubBand,
    COUNT(*) AS HeadCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PercentageOfHeadcount
FROM 
    HumanResources.Employee
GROUP BY 
    JobTitle
ORDER BY 
    JobTitle;

--task 15
-- Get the 5th highest salary first
DECLARE @FifthHighestSalary MONEY;

SELECT @FifthHighestSalary = MIN(Salary)
FROM (
    SELECT TOP 5 Salary
    FROM HumanResources.EmployeePayHistory
    GROUP BY Salary
) AS TopSalaries;

-- Select employees who have salary >= 5th highest salary
SELECT TOP 5 e.BusinessEntityID, p.JobTitle, eph.Rate AS Salary
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e ON eph.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE eph.Rate >= @FifthHighestSalary
GROUP BY e.BusinessEntityID, p.JobTitle, eph.Rate;


--task 16
UPDATE MyTable
SET 
    Col1 = Col1 + Col2,
    Col2 = Col1 - Col2,
    Col1 = Col1 - Col2;


	UPDATE MyTable
SET 
    Col1 = Col1 + Col2,
    Col2 = LEFT(Col1, LEN(Col1) - LEN(Col2)),
    Col1 = RIGHT(Col1, LEN(Col1) - LEN(Col2));


--task 17
CREATE LOGIN [NewLoginName] WITH PASSWORD = 'StrongPasswordHere!';
USE AdventureWorks;
GO

CREATE USER [NewUserName] FOR LOGIN [NewLoginName];

ALTER ROLE db_owner ADD MEMBER [NewUserName];

-- Create login at server level
CREATE LOGIN [JohnDoeLogin] WITH PASSWORD = 'StrongP@ssw0rd2025!';
GO

-- Use the target database
USE AdventureWorks;
GO

-- Create user in database mapped to login
CREATE USER [JohnDoeUser] FOR LOGIN [JohnDoeLogin];
GO

-- Add user to db_owner role
ALTER ROLE db_owner ADD MEMBER [JohnDoeUser];
GO

--task 18

SELECT
    BU,
    FORMAT(MonthYear, 'yyyy-MM') AS YearMonth,
    SUM(Salary * HeadCount) * 1.0 / NULLIF(SUM(HeadCount), 0) AS WeightedAverageSalary
FROM EmployeeCosts
GROUP BY
    BU,
    FORMAT(MonthYear, 'yyyy-MM')
ORDER BY
    BU,
    YearMonth;

--task 19

WITH SalaryData AS (
    SELECT
        Salary,
        -- Convert salary to varchar, remove zeros, convert back to float (handle empty string)
        CASE
            WHEN LEN(REPLACE(CAST(Salary AS VARCHAR(20)), '0', '')) = 0 THEN 0
            ELSE CAST(REPLACE(CAST(Salary AS VARCHAR(20)), '0', '') AS FLOAT)
        END AS SalaryNoZeros
    FROM Employees
)

SELECT
    CEILING(AVG(Salary) - AVG(SalaryNoZeros)) AS AmountOfError
FROM SalaryData;

--task 20

INSERT INTO DestinationTable (ID, Col1, Col2, Col3, ...) 
SELECT s.ID, s.Col1, s.Col2, s.Col3, ...
FROM SourceTable s
LEFT JOIN DestinationTable d ON s.ID = d.ID
WHERE d.ID 
