use [AdventureWorks2022];

--1. List of all Customers
	SELECT * FROM Sales.Customer;

--2. list of all Customers where company name ending in N

	SELECT * FROM Sales.vIndividualCustomer WHERE CountryRegionName LIKE '%N';

--3.list of all Customers who live in berlin or London

	SELECT *FROM Sales.vIndividualCustomer WHERE City IN ('Berlin', 'London');

--4.list of Customers who live in UK or USA

	SELECT * FROM Sales.vIndividualCustomer WHERE CountryRegionName IN ('UK', 'USA');

--5.list of all products stored by product name

	SELECT * FROM Production.Product ORDER BY Name;

--6.list of all products where name starts with an A

	SELECT * FROM Production.Product WHERE Name like 'A%';

--7.list of Customers who ever placed an order
	
	SELECT  c.CustomerID,o.OrderQty  FROM Sales.Customer c JOIN Sales.SalesOrderDetail o ON c.CustomerID = o.SalesOrderDetailID;

--8.list of Customers who live in london and have brought chai

		SELECT  c.* FROM Sales.vIndividualCustomer c join Production.vProductAndDescription p  on c.BusinessEntityID = p.ProductID WHERE c.city='london' and p.Name='chai';
		

--9.list of customer who never placed an order
	
	
	SELECT DISTINCT c.CustomerID,o.OrderQty  FROM Sales.Customer c JOIN Sales.SalesOrderDetail o ON c.CustomerID = o.SalesOrderDetailID WHERE O.OrderQty IS NULL;


--10 list of customer1s who ordered tofu

	SELECT DISTINCT c.CustomerID,ISNULL(p.FirstName + ' ' + p.LastName, 'Company Account') AS CustomerName FROM Sales.SalesOrderDetail sod JOIN Production.Product pr ON sod.ProductID = pr.ProductID JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID WHERE pr.Name = 'Tofu';


--11.list of first order of the system

	SELECT TOP 1 * FROM Sales.SalesOrderDetail;
	
--12.find the details of most expensive order date

	SELECT TOP 1 OD.SalesOrderID,OD.OrderDate,SUM(O.OrderQty*O.UnitPrice)AS TOTALAMOUNT FROM Sales.SalesOrderDetail O JOIN Sales.SalesOrderHeader OD ON O.SalesOrderID = OD.SalesOrderID GROUP BY OD.SalesOrderID,OD.OrderDate ORDER BY TOTALAMOUNT DESC ;

--13.For each order get the orderID and Average quantity of items in that order
	
	SELECT SalesOrderID,AVG(CAST(OrderQty AS FLOAT)) AS AverageQuantity FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

--14.For each order get the orderID,maximum quantity and minimum quantity for  that order

	SELECT SalesOrderID,MAX(OrderQty) AS MaxQuantity,MIN(OrderQty) AS MinQuantity FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

--15.get a list of all managers and total number of employees who report to them.

	SELECT BusinessEntityID AS MANAGER_ID,FirstName +' '+LastName AS MANAGER_NAME,COUNT(BusinessEntityID) AS NUMBER_OF_REPORTS FROM HumanResources.vEmployeeDepartment GROUP BY BusinessEntityID,FirstName,LastName ORDER BY NUMBER_OF_REPORTS

--16.get the orderID and the total quantity for each order that has a total quantity of greater than 300

	select SalesOrderID,sum(OrderQty) as TotalQuantity from Sales.SalesOrderDetail group by SalesOrderID having sum(OrderQty)>300;

--17.list of all order placed on after 1996/12/31

	SELECT * FROM Sales.SalesOrderHeader WHERE OrderDate > '1996-12-31';

--18.list of all orders shipped to canada

	SELECT SE.SalesOrderDetailID,SO.FirstName,SO.CountryRegionName FROM Sales.SalesOrderDetail SE JOIN Sales.vSalesPerson SO ON SE.SalesOrderDetailID=SO.BusinessEntityID WHERE CountryRegionName = 'Canada';	



--19.list of all order with order total > 200

	SELECT SalesOrderID,SUM(OrderQty*UnitPrice) AS ORDERTOTAL FROM Sales.SalesOrderDetail GROUP BY SalesOrderID HAVING SUM(OrderQty*UnitPrice)>200
	
--20.list of countries and sale made in each country
		SELECT  PCR.NAME AS COUNTRY,SUM(SOH.TotalDue) AS TOTALSALES FROM Sales.SalesOrderHeader SOH JOIN Person.Address PA ON SOH.BillToAddressID= PA.AddressID JOIN Person.StateProvince PSP ON PA.StateProvinceID=PSP.StateProvinceID JOIN Person.CountryRegion PCR ON PSP.CountryRegionCode=PCR.CountryRegionCode GROUP BY PCR.Name ORDER BY TOTALSALES DESC


--21.list of Customer ContactName and number of order they placed

	SELECT c.CustomerID,ISNULL(p.FirstName + ' ' + p.LastName, 'Company Account') AS ContactName,COUNT(soh.SalesOrderID) AS NumberOfOrders FROM Sales.Customer c JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID GROUP BY c.CustomerID, p.FirstName, p.LastName ORDER BY NumberOfOrders DESC;


--22.list of customers contactnames who have placed mare than 3 order

	SELECT c.CustomerID,ISNULL(p.FirstName + ' ' + p.LastName, 'Company Account') AS ContactName,COUNT(soh.SalesOrderID) AS NumberOfOrders FROM Sales.Customer c JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID GROUP BY c.CustomerID, p.FirstName, p.LastName HAVING COUNT(soh.SalesOrderID) > 3 ORDER BY NumberOfOrders DESC;

--23.List of Discounted products where were ordered between 1/1/1997 and 1/1/1998

	SELECT PP.Name AS PRODUCT_NAME,SOD.UnitPrice,SOD.UnitPriceDiscount,SOH.OrderDate FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID=SOD.SalesOrderID JOIN Production.Product PP ON SOD.ProductID=PP.ProductID WHERE SOH.OrderDate >='1997-1-01' AND SOH.OrderDate < '1998-1-01' AND SOD.UnitPriceDiscount > 0 ORDER BY PP.Name

--24.list of employee firstname,lastname,superviser FirstName,LastName

	SELECT HE.BusinessEntityID,HE.FirstName,HE.LastName,HO.Name FROM HumanResources.vEmployeeDepartment HE JOIN HumanResources.Department HO ON HE.BusinessEntityID =HO.DepartmentID 

--25.List of employee id and total sale conducted by employee
	
	SELECT HE.BusinessEntityID,SUM(SE.OrderQty*SE.UnitPrice) AS TOTALSALES FROM HumanResources.Employee HE JOIN Sales.SalesOrderDetail SE ON HE.BusinessEntityID = SE.SalesOrderDetailID GROUP BY HE.BusinessEntityID ORDER BY TOTALSALES
	
--26.List of employee whose FirstName contains Character a

	SELECT * FROM HumanResources.vEmployee WHERE FirstName LIKE '%a%'

--27.List of manager who have more than four people reporting to them

	SELECT HE.BusinessEntityID AS MANAGER_ID,FirstName+' '+LastName AS MANAGER_NAME, COUNT(HO.DepartmentID) AS NUMBER_OF_REPORTS FROM HumanResources.vEmployee HE JOIN HumanResources.Department HO ON HE.BusinessEntityID=HO.DepartmentID GROUP BY HE.BusinessEntityID,HE.FirstName,HE.LastName HAVING COUNT(HO.DepartmentID)>4 ORDER BY NUMBER_OF_REPORTS


--28.List of Orders and productNames

	SELECT SE.SalesOrderDetailID,PP.Name FROM Sales.SalesOrderDetail SE JOIN Production.Product PP ON SE.SalesOrderDetailID = PP.ProductID ORDER BY SE.SalesOrderDetailID

--29.List of Order placed by the best Customer

	-- Step 1: Identify the best customer (highest total revenue)
WITH CustomerTotals AS (
    SELECT 
        CustomerID,
        SUM(TotalDue) AS TotalSpent
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        CustomerID
),
BestCustomer AS (
    SELECT TOP 1 CustomerID
    FROM CustomerTotals
    ORDER BY TotalSpent DESC
)
-- Step 2: Get all orders placed by that customer
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    soh.Status,
    soh.SalesPersonID
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    BestCustomer bc ON soh.CustomerID = bc.CustomerID
ORDER BY 
    soh.OrderDate DESC;


--30.List of Order placed by Customer who do not have a fax number





--31.List of Postal code where the product tofu was shipped
	
	SELECT PA.PostalCode AS POSTAL FROM Sales.SalesOrderHeader SO JOIN Sales.SalesOrderDetail SE ON SO.SalesOrderID=SE.SalesOrderID JOIN Production.Product PP ON SE.ProductID=PP.ProductID JOIN Person.Address PA ON SE.SalesOrderDetailID=PA.AddressID WHERE PP.Name='TOFU'


	
--32.List of ProductNmae that were shipped to france


	SELECT SE.Name,SO.CountryRegionName AS SHIPPED_COUNTRY FROM Production.vProductAndDescription SE JOIN Sales.vSalesPerson SO ON SE.ProductID=SO.BusinessEntityID WHERE SO.CountryRegionName='FRANCE' ORDER BY SE.Name

--33.list of ProductNames and Categories for the supplier 'Specially Biscuites',LTD.

	SELECT PP.Name AS PRODUCT_NAME,PE.Description as Category FROM Production.Product PP JOIN Production.vProductAndDescription PE ON PP.ProductID=PE.ProductID JOIN Purchasing.ProductVendor PSC ON PE.ProductID=PSC.ProductID JOIN Purchasing.Vendor PV ON PSC.BusinessEntityID=PV.BusinessEntityID WHERE PV.Name='Specially Biscuites,LTD'
	

--34.List of Products That were never ordered

SELECT PP.ProductID,PP.Name FROM Production.Product PP LEFT JOIN Sales.SalesOrderDetail SO ON PP.ProductID=SO.ProductID WHERE SO.ProductID IS NULL ORDER BY PP.NAME

--35.List of products where units in stock less than 10 and units on order are 0

	SELECT PP.ProductID,PP.Name,PO.StockedQty,PO.OrderQty FROM Production.Product PP JOIN Purchasing.PurchaseOrderDetail PO ON PP.ProductID=PO.ProductID WHERE PO.OrderQty <10 AND PO.OrderQty=0 ORDER BY PP.Name

--36.List of top 10 countries by sale

	SELECT TOP 10 PCR.NAME AS COUNTRY,SUM(SOH.TotalDue) AS TOTALSALES FROM Sales.SalesOrderHeader SOH JOIN Person.Address PA ON SOH.BillToAddressID= PA.AddressID JOIN Person.StateProvince PSP ON PA.StateProvinceID=PSP.StateProvinceID JOIN Person.CountryRegion PCR ON PSP.CountryRegionCode=PCR.CountryRegionCode GROUP BY PCR.Name ORDER BY TOTALSALES DESC

--37.Numbers of orders each employee has taken for customers with CustomerId between A and AO

	SELECT 
    e.BusinessEntityID AS EmployeeID,
    ISNULL(p.FirstName + ' ' + p.LastName, 'Unknown') AS EmployeeName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN 
    HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN 
    Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE 
    c.CustomerID BETWEEN 1 AND 40 -- Example range (adjust if needed)
GROUP BY 
    e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY 
    NumberOfOrders DESC;


--38.OrderDate of Most Expensive Order
	
	SELECT SalesOrderID,OrderDate,TotalDue FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC

--39.Product Name and total revenue from that product
	
	SELECT  PP.NAME AS PRODUCT_NAME,SUM(SOD.OrderQty*SOD.UnitPrice*(1 - SOD.UnitPriceDiscount)) AS TOTAL_REVENUE FROM Sales.SalesOrderDetail SOD JOIN Production.Product PP ON SOD.ProductID=PP.ProductID GROUP BY PP.Name ORDER BY TOTAL_REVENUE DESC	
	
--40.SuplierId and number of product offered

	SELECT BusinessEntityID AS SUPLIER_ID,COUNT(ProductID) AS NUMBER_OF_PRODUCT_OFFERED FROM Purchasing.ProductVendor GROUP BY BusinessEntityID ORDER BY NUMBER_OF_PRODUCT_OFFERED DESC

--41.top 10 customers based on their business
	
SELECT TOP 10 c.CustomerID,ISNULL(p.FirstName + ' ' + p.LastName, 'Company Account') AS CustomerName,SUM(soh.TotalDue) AS TotalBusiness FROM Sales.SalesOrderHeader soh JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID LEFT JOIN  Person.Person p ON c.PersonID = p.BusinessEntityID GROUP BY  c.CustomerID, p.FirstName, p.LastName ORDER BY TotalBusiness DESC;


--42.what is the total revenue of company

	SELECT SUM(TotalDue) AS TotalRevenue FROM  Sales.SalesOrderHeader;