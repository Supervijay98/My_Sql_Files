--Functions
--Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY. For example ifIpass in ‘2006-11-21 23:34:05.920’, the output ofthe functions should be 11/21/2006

	CREATE FUNCTION dbo.GetFormattedDate
(
    @InputDate DATETIME
)
RETURNS VARCHAR(10)
AS
BEGIN
    -- Format: MM/DD/YYYY using style 101
    RETURN CONVERT(VARCHAR(10), @InputDate, 101);
END;

SELECT dbo.GetFormattedDate('2006-11-21 23:34:05.920') AS FormattedDate;


--Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD

	CREATE FUNCTION dbo.FormatDate_YYYYMMDD
(
    @InputDate DATETIME
)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @InputDate, 112);
END;

SELECT dbo.FormatDate_YYYYMMDD('2006-11-21 23:34:05.920') AS FormattedDate;

--Views

--Create a view vwCustomerOrders which returns CompanyName,OrderID,OrderDate, ProductID,ProductName,Quantity,UnitPrice,Quantity * od.UnitPrice

	CREATE VIEW vwCustomerOrders AS
SELECT 
    SIC.FirstName+' '+SIC.LastName AS [COMPANY NAME],
    SOH.SalesOrderID AS [ORDER ID],
    SOH.OrderDate,
    PP.ProductID,
    PP.Name AS [PRODUCT NAME],
    SOD.OrderQty AS [ORDER QUNATITY],
    SOD.UnitPrice AS [UNIT PRICE],
    (SOD.OrderQty * SOD.UnitPrice) AS TotalPrice
FROM Sales.Customer SC
INNER JOIN Sales.vIndividualCustomer SiC ON SC.CustomerID = SIC.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader SOH ON SC.CustomerID=SOH.CustomerID
INNER JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID=SOD.SalesOrderDetailID
INNER JOIN Production.Product PP ON  SOD.ProductID=PP.ProductID;

SELECT * FROM vwCustomerOrders;


--Create a copy ofthe above view and modify it so that it only returns the above information for orders that were placed yesterday

		CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    SIC.FirstName+' '+SIC.LastName AS [COMPANY NAME],
    SOH.SalesOrderID AS [ORDER ID],
    SOH.OrderDate,
    PP.ProductID,
    PP.Name AS [PRODUCT NAME],
    SOD.OrderQty AS [ORDER QUNATITY],
    SOD.UnitPrice AS [UNIT PRICE],
    (SOD.OrderQty * SOD.UnitPrice) AS TotalPrice
FROM Sales.Customer SC
INNER JOIN Sales.vIndividualCustomer SiC ON SC.CustomerID = SIC.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader SOH ON SC.CustomerID=SOH.CustomerID
INNER JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID=SOD.SalesOrderDetailID
INNER JOIN Production.Product PP ON  SOD.ProductID=PP.ProductID
WHERE CAST(SOH.OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);


	SELECT * FROM vwCustomerOrders_Yesterday;

	
--Use a CREATE VIEW statement to create a view called MyProducts. Your view should
--contain the ProductID, ProductName, QuantityPerUnit and UnitPrice columns from the
--Products table. It should also contain the CompanyName column from the Suppliers table
--and the CategoryName column from the Categories table. Your view should only contain
--products that are not discontinued.


CREATE VIEW MyProducts AS
SELECT 
    PP.ProductID,
   PP.Name,
    PPV.OnOrderQty,
    PPV.StandardPrice,
    PV.Name AS [COMPANY NAME],
    PPC.NAME AS[CATEGORY NAME]
FROM Production.Product PP
INNER JOIN Purchasing.ProductVendor PPV ON PP.ProductID=PPV.ProductID
INNER JOIN Purchasing.Vendor PV ON PPV.ProductID=PV.BusinessEntityID
INNER JOIN Production.ProductCategory PPC ON PP.ProductID=PPC.ProductCategoryID
INNER JOIN Sales.SalesOrderDetail SOD ON PP.ProductID=SOD.ProductID
WHERE SOD.UnitPriceDiscount=0;

SELECT * FROM MyProducts;


				--Stored Procedures


--(Use Adventure Works Database)
--Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice,
--Quantiy, Discount as input parameters and inserts that order information in the
--Order Details table. After each order inserted, check the @@rowcount value to
--make sure that order was inserted properly. If for any reason the order was not
--inserted, print the message: Failed to place the order. Please try again. Also your
--procedure should have these functionalities
--Make the UnitPrice and Discount parameters optional
--Ifno UnitPrice is given, then use the UnitPrice value from the product table.
--Ifno Discount is given, then use a discount of 0.
--Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity
--sold from inventory.
--However, ifthere is notenough of a product in stock, then abort the stored procedure
--without making any changes to the database.
--Print a message ifthe quantity in stock ofa product drops below its Reorder Level as a
--result of the update.


CREATE PROCEDURE InsertOrderDetails (
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = NULL
)
AS
BEGIN
    -- Determine UnitPrice if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @UnitPrice = p.ListPrice FROM Production.Product AS p WHERE p.ProductID = @ProductID;
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Error: Product not found.';
            RETURN;
        END;
    END;

    -- Determine Discount if not provided
    IF @Discount IS NULL
        SET @Discount = 0;

    -- Check if there are enough products in stock
    DECLARE @QuantityInStock INT;
    SELECT @QuantityInStock = UnitsInStock FROM Production.Product WHERE ProductID = @ProductID;
    
    IF @Quantity > @QuantityInStock
    BEGIN
        PRINT 'Error: Not enough products in stock.  Order cannot be placed.';
        RETURN;
    END;

    -- Insert Order Details
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice, @Discount);

    -- Check if the insertion was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
    END
    ELSE
    BEGIN
        -- Update product inventory
        UPDATE Production.Product
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;

        -- Check if the product inventory drops below reorder level
        DECLARE @ReorderLevel INT;
        SELECT @ReorderLevel = ReorderPoint FROM Production.Product WHERE ProductID = @ProductID;

        IF (UnitsInStock < @ReorderLevel)
        BEGIN
            PRINT 'Warning: Product quantity dropped below reorder level.';
        END;
    END;

END;

-- Minimal input, UnitPrice and Discount will default
EXEC InsertOrderDetails 
    @SalesOrderID = 43659,
    @ProductID = 776,  -- Replace with a valid ProductID
    @OrderQty = 3;

-- With optional values specified
EXEC InsertOrderDetails 
    @SalesOrderID = 43659,
    @ProductID = 776,
    @OrderQty = 2,
    @UnitPrice = 25.50,
    @Discount = 0.05;




--Create a procedure UpdateOrderDetails that takes OrderID, ProductID, UnitPrice,
--Quantity, and discount, and updates these values for that ProductID in that Order.
--All the parameters except the OrderID and ProductID should be optional so that if
--the user wants to only update Quantity s/he should be able to do so without
--providing the rest ofthe values. You need toalso make sure that ifany ofthe values
--are being passed in as NULL, then you want to retain the original value instead of
--overwriting it with NULL. To accomplish this, look for the ISNULLQ function in
--google or sql server books online. Adjust the UnitsInStock value in products table
--accordingly.

CREATE PROCEDURE UpdateOrderDetails
    @SalesOrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @OrderQty SMALLINT = NULL,
    @Discount DECIMAL(10, 4) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldQty INT,
        @NewQty INT,
        @QtyDiff INT,
        @LocationID INT,
        @CurrentQty INT;

    -- Get the existing order details
    SELECT 
        @OldQty = OrderQty
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID;

    IF @OldQty IS NULL
    BEGIN
        PRINT 'No matching order detail found.';
        RETURN;
    END

    -- Set new quantity (keep original if null)
    SET @NewQty = ISNULL(@OrderQty, @OldQty);
    SET @QtyDiff = @NewQty - @OldQty;

    BEGIN TRANSACTION;

    -- Update the SalesOrderDetail with non-null parameters
    UPDATE Sales.SalesOrderDetail
    SET 
        OrderQty = ISNULL(@OrderQty, OrderQty),
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        UnitPriceDiscount = ISNULL(@Discount, UnitPriceDiscount),
        ModifiedDate = GETDATE()
    WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID;

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Update failed. Please check input values.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Get LocationID and update inventory accordingly
    SELECT TOP 1 
        @LocationID = LocationID,
        @CurrentQty = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID
    ORDER BY Quantity DESC;

    IF @LocationID IS NOT NULL
    BEGIN
        UPDATE Production.ProductInventory
        SET Quantity = Quantity - @QtyDiff
        WHERE ProductID = @ProductID AND LocationID = @LocationID;
    END

    COMMIT TRANSACTION;
    PRINT 'Order detail updated successfully.';
END;

-- Only update quantity
EXEC UpdateOrderDetails 
    @SalesOrderID = 43659,
    @ProductID = 776,
    @OrderQty = 4;

-- Update quantity and price
EXEC UpdateOrderDetails 
    @SalesOrderID = 43659,
    @ProductID = 776,
    @OrderQty = 5,
    @UnitPrice = 32.50;




--Create a procedure GetOrderDetails that takes OrderID as input parameter and
--returns all the records for that OrderID. Ifno records are found in Order Details
--table, then it should print the line: “The OrderI[D XXXX does not exits”, where
--XXX should be the OrderID entered by user and the procedure should RETURN
--the value 1.

CREATE PROCEDURE GetOrderDetails
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the order exists
    IF NOT EXISTS (
        SELECT 1 
        FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @SalesOrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@SalesOrderID AS VARCHAR(10)) + ' does not exist';
        RETURN 1;
    END

    -- If found, return order details
    SELECT *
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @SalesOrderID;
END;

-- Existing OrderID
EXEC GetOrderDetails @SalesOrderID = 43659;

-- Non-existent OrderID
EXEC GetOrderDetails @SalesOrderID = 99999;




--Create a procedure DeleteOrderDetails that takes OrderID and ProductID and
--deletes that from Order Details table. Your procedure should validate parameters.
--It should return an error code (-1) and print a message ifthe parameters are
--invalid. Parameters are valid ifthe given order ID appears in the table and ifthe
--given product ID appears in that order.


CREATE PROCEDURE DeleteOrderDetails
    @SalesOrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the order ID exists
    IF NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @SalesOrderID
    )
    BEGIN
        PRINT 'Error: SalesOrderID ' + CAST(@SalesOrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN -1;
    END

    -- Check if the product exists for the given order
    IF NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Error: ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' does not exist in Order ' + CAST(@SalesOrderID AS VARCHAR(10)) + '.';
        RETURN -1;
    END

    -- Perform the delete
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID;

    PRINT 'Order detail deleted successfully.';
END;

-- Valid delete
EXEC DeleteOrderDetails @SalesOrderID = 43659, @ProductID = 776;

-- Invalid order
EXEC DeleteOrderDetails @SalesOrderID = 99999, @ProductID = 776;

-- Valid order, invalid product
EXEC DeleteOrderDetails @SalesOrderID = 43659, @ProductID = 999;


--Triggers

--Ifsomeone cancels an order in northwind database, then you want to delete that
--order from the Orders table. But you will not be able to delete that Order before
--deleting the records from Order Details table for that particular order due to
--referential integrity constraints. Create an Instead ofDelete trigger on Orders table
--so that if some one tries to delete an Order that trigger gets fired and that trigger
--should first delete everything in order details table and then delete that order from
--the Orders table

CREATE TRIGGER tr_DeleteSalesOrder
ON Sales.SalesOrderHeader
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete from detail table first
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    -- Delete from header table
    DELETE FROM Sales.SalesOrderHeader
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    PRINT 'Order and its details deleted successfully.';
END;

-- Check if a specific SalesOrderID exists (e.g., 43659)
SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID = 43659;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 43659;

-- Try deleting
DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID = 43659;

-- Verify deletion
SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID = 43659;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 43659;


--When an orderis placed forXunits ofproduct Y, we must first check the Products
--table to ensure that there is sufficient stock to fill the order. This trigger will operate
--on the Order Details table. If sufficient stock exists, then fill the order and
--decrement Xunits from the UnitsInStock column in Products. Ifinsufficient stock
--exists, then refuse the order (i.e. do not insert it) and notify the user that the order
--could not be filled because ofinsufficient stock.
--Note: Based on the understanding candidate has to create a sample data to perform these
--queries.

CREATE TRIGGER tr_ValidateStockBeforeInsert
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @OrderQty INT, @LocationID INT, @StockQty INT;

    -- Assume only one row is inserted at a time for simplicity
    SELECT 
        @ProductID = ProductID,
        @OrderQty = OrderQty
    FROM INSERTED;

    -- Pick a location with the most stock
    SELECT TOP 1 
        @StockQty = Quantity,
        @LocationID = LocationID
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID
    ORDER BY Quantity DESC;

    IF @StockQty IS NULL
    BEGIN
        PRINT 'Product does not exist in inventory.';
        RETURN;
    END

    IF @StockQty < @OrderQty
    BEGIN
        PRINT 'Order could not be placed: Insufficient stock.';
        RETURN;
    END

    -- Proceed with inserting the order
    INSERT INTO Sales.SalesOrderDetail (
        SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
    )
    SELECT 
        SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
    FROM INSERTED;

    -- Update inventory
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @OrderQty
    WHERE ProductID = @ProductID AND LocationID = @LocationID;

    PRINT 'Order placed successfully and inventory updated.';
END;

-- Succeeds if enough stock
INSERT INTO Sales.SalesOrderDetail (
    SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
)
VALUES (
    43659, 776, 1, 100.00, 0.0, NEWID(), GETDATE()
);

-- Fails if not enough stock
INSERT INTO Sales.SalesOrderDetail (
    SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
)
VALUES (
    43659, 776, 9999, 100.00, 0.0, NEWID(), GETDATE()
);
