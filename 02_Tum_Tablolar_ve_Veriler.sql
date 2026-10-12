USE AFC;
GO


SET IDENTITY_INSERT afc.CardTypes ON;
INSERT INTO afc.CardTypes (Id, Description, Price, IsActive, IsDeleted, InsertDate, TransactionDate) VALUES
    (1, 'Full Fare', 15.0, 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (2, 'Student', 7.5, 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (3, 'Teacher', 7.5, 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (4, 'Senior', 5.0, 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.CardTypes OFF;


SET IDENTITY_INSERT afc.Validator ON;
INSERT INTO afc.Validator (Id, ValidatorNumber, SerialNumber, GsmNumber, IsActive, IsDeleted, InsertDate, TransactionDate) VALUES
    (1, 'VLD-1001', 'SN-A10023', '905301112201', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (2, 'VLD-1002', 'SN-A10024', '905301112202', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Validator OFF;


SET IDENTITY_INSERT afc.Vehicle ON;
INSERT INTO afc.Vehicle (Id, Plate, Validator_Id, Brand, Model, IsActive, IsDeleted, InsertDate, TransactionDate) VALUES
    (1, '34 ABC 101', 1, 'Mercedes-Benz', 'Citaro', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (2, '34 ABC 102', 2, 'MAN', 'Lion''s City', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Vehicle OFF;


SET IDENTITY_INSERT afc.Cards ON;
INSERT INTO afc.Cards (Id, CardNumber, MifareId, CardType_Id, CardStatus, Balance, ProductionDate, ExpirationDate, InsertDate, TransactionDate) VALUES
    (1, '10001', '04000F693580', 1, 'Active', 500.00, '2023-01-04', '2027-01-06', '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (2, '10002', '04000F902A80', 2, 'Active', 250.00, '2023-01-07', '2027-01-11', '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Cards OFF;


SET IDENTITY_INSERT afc.Institution ON;
INSERT INTO afc.Institution (Id, Name, Type, IsActive, IsDeleted, InsertDate, TransactionDate) VALUES
    (1, 'City Transport Authority', 'Municipality', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Institution OFF;


SET IDENTITY_INSERT afc.Dealer ON;
INSERT INTO afc.Dealer (Id, Name, Institution_Id, Region, IsActive, IsDeleted, InsertDate, TransactionDate) VALUES
    (1, 'Central Kiosk', 1, 'Downtown', 1, 0, '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Dealer OFF;


SET IDENTITY_INSERT afc.Pos ON;
INSERT INTO afc.Pos (Id, Dealer_Id, SerialNumber, Status, InsertDate, TransactionDate) VALUES
    (1, 1, 'POS-001', 'Active', '2026-09-10 09:00:00', '2026-09-10 09:00:00');
SET IDENTITY_INSERT afc.Pos OFF;


INSERT INTO afc.Transactions (Vehicle_Id, CardNumber, CardType_Id, Amount, RemainingBalance, TransactionDate)
VALUES (1, '10001', 1, 15.00, 485.00, '2026-09-15 10:30:00');

INSERT INTO afc.TopUps (Pos_Id, CardNumber, Amount, BalanceAfter, TransactionDate)
VALUES (1, '10001', 100.00, 585.00, '2026-09-14 08:00:00');


INSERT INTO afc.BankCardTaps (Vehicle_Id, MaskedPan, Amount, TransactionDate)
SELECT
    (SELECT TOP 1 Id FROM afc.Vehicle ORDER BY NEWID()),
    '453' + CAST(1000 + ABS(CHECKSUM(NEWID())) % 9000 AS VARCHAR(4)) + ' **** **** ' + CAST(1000 + ABS(CHECKSUM(NEWID())) % 9000 AS VARCHAR(4)),
    15.00,
    DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 86400,
            CAST(DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 30, '2026-09-01') AS DATETIME2))
FROM sys.all_objects
WHERE OBJECT_ID IS NOT NULL
ORDER BY (SELECT NULL)
OFFSET 0 ROWS FETCH NEXT 80 ROWS ONLY;
GO