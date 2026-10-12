USE AFC;
GO



CREATE OR ALTER PROCEDURE afc.sp_GetCardUsageReport
    @StartDate  DATE,
    @EndDate    DATE,
    @CardNumber CHAR(5) = NULL
AS
BEGIN
    SET NOCOUNT ON;
 
   
    SELECT
        t.TransactionDate                   AS EventTime,
        SYSDATETIME()                        AS ReportGeneratedAt,
        'Boarding'                            AS EventType,
        t.CardNumber                          AS CardOrPan,
        v.Plate                               AS VehicleOrDevice,
        v.Validator_Id                        AS DeviceNumber,
        -t.Amount                             AS Amount,
        t.RemainingBalance + t.Amount          AS BalanceBefore,
        t.RemainingBalance                    AS BalanceAfter,
        t.Id                                  AS SourceId
    FROM afc.Transactions t
    JOIN afc.Vehicle v ON v.Id = t.Vehicle_Id
    WHERE t.TransactionDate >= @StartDate AND t.TransactionDate < DATEADD(DAY, 1, @EndDate)
      AND (@CardNumber IS NULL OR t.CardNumber = @CardNumber)
 
    UNION ALL
 
    
    SELECT
        tu.TransactionDate, SYSDATETIME(), 'Top-Up', tu.CardNumber,
        'POS #' + CAST(p.Id AS VARCHAR(10)), p.Id,
        tu.Amount, tu.BalanceAfter - tu.Amount, tu.BalanceAfter, tu.Id
    FROM afc.TopUps tu
    JOIN afc.Pos p ON p.Id = tu.Pos_Id
    WHERE tu.TransactionDate >= @StartDate AND tu.TransactionDate < DATEADD(DAY, 1, @EndDate)
      AND (@CardNumber IS NULL OR tu.CardNumber = @CardNumber)
 
    UNION ALL
 
    
    SELECT
        b.TransactionDate, SYSDATETIME(), 'Bank Card Tap', b.MaskedPan,
        v.Plate, v.Validator_Id, -b.Amount, NULL, NULL, b.Id
    FROM afc.BankCardTaps b
    JOIN afc.Vehicle v ON v.Id = b.Vehicle_Id
    WHERE b.TransactionDate >= @StartDate AND b.TransactionDate < DATEADD(DAY, 1, @EndDate)
      AND @CardNumber IS NULL     -- Banka kartlarının CardNumber'ı yoktur
 
    ORDER BY EventTime;
END;
GO


EXEC afc.sp_GetCardUsageReport @StartDate = '2026-09-01', @EndDate = '2026-09-30';

