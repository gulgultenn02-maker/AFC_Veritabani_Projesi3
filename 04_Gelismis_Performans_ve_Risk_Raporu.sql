USE AFC;
GO

CREATE OR ALTER PROCEDURE afc.sp_GetVehiclePerformanceAndRiskReport
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    WITH VehicleStats AS (
        SELECT 
            v.Plate,
            COUNT(t.Id) AS TotalBoardings,
            SUM(t.Amount) AS TotalRevenue,
            DATEPART(HOUR, t.TransactionDate) AS TransactionHour
        FROM afc.Transactions t
        JOIN afc.Vehicle v ON v.Id = t.Vehicle_Id
        WHERE t.TransactionDate >= @StartDate AND t.TransactionDate < DATEADD(DAY, 1, @EndDate)
        GROUP BY v.Plate, DATEPART(HOUR, t.TransactionDate)
    ),
    PeakHours AS (
        SELECT 
            Plate,
            TransactionHour AS PeakHour,
            ROW_NUMBER() OVER (PARTITION BY Plate ORDER BY COUNT(*) DESC) AS HourRank
        FROM VehicleStats
        GROUP BY Plate, TransactionHour
    )
    SELECT 
        vs.Plate                                                     AS VehiclePlate,
        SUM(vs.TotalBoardings)                                       AS TotalBoardings,
        SUM(vs.TotalRevenue)                                         AS TotalRevenue,
        DENSE_RANK() OVER (ORDER BY SUM(vs.TotalRevenue) DESC)       AS RevenueRank,
        CAST(ph.PeakHour AS VARCHAR(2)) + ':00 - ' + 
        CAST(ph.PeakHour + 1 AS VARCHAR(2)) + ':00'                  AS PeakTimeWindow,
        (SELECT COUNT(*) FROM afc.Cards c WHERE c.Balance < 15.00 AND c.CardStatus = 'Active') AS LowBalanceRiskCardCount
    FROM VehicleStats vs
    JOIN PeakHours ph ON ph.Plate = vs.Plate AND ph.HourRank = 1
    GROUP BY vs.Plate, ph.PeakHour
    ORDER BY RevenueRank;

END;
GO

EXEC afc.sp_GetVehiclePerformanceAndRiskReport 
    @StartDate = '2026-09-01', 
    @EndDate   = '2026-09-30';