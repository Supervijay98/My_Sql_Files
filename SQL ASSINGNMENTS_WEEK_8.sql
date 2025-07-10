CREATE TABLE DimDate (
    DateKey DATE PRIMARY KEY,
    DayNumber INT,
    DayName NVARCHAR(20),
    MonthNumber INT,
    MonthName NVARCHAR(20),
    QuarterNumber INT,
    WeekOfYear INT,
    YearNumber INT,
    IsWeekend BIT
);


CREATE PROCEDURE PopulateDimDate
    @InputDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
    DECLARE @EndDate DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);

    ;WITH DateSequence AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateSequence
        WHERE DateValue < @EndDate
    )
    INSERT INTO DimDate (
        DateKey,
        DayNumber,
        DayName,
        MonthNumber,
        MonthName,
        QuarterNumber,
        WeekOfYear,
        YearNumber,
        IsWeekend
    )
    SELECT
        DateValue,
        DAY(DateValue),
        DATENAME(WEEKDAY, DateValue),
        MONTH(DateValue),
        DATENAME(MONTH, DateValue),
        DATEPART(QUARTER, DateValue),
        DATEPART(WEEK, DateValue),
        YEAR(DateValue),
        CASE WHEN DATENAME(WEEKDAY, DateValue) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
    FROM DateSequence
    OPTION (MAXRECURSION 366);
END;



EXEC PopulateDimDate @InputDate = '2020-07-14';
