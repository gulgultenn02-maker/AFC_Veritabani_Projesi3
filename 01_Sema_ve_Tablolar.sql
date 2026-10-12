USE AFC;
GO


DROP PROCEDURE IF EXISTS afc.sp_GetCardUsageReport;
DROP TABLE IF EXISTS afc.BankCardTaps;
DROP TABLE IF EXISTS afc.TopUps;
DROP TABLE IF EXISTS afc.Transactions;
DROP TABLE IF EXISTS afc.Pos;
DROP TABLE IF EXISTS afc.Dealer;
DROP TABLE IF EXISTS afc.Institution;
DROP TABLE IF EXISTS afc.Cards;
DROP TABLE IF EXISTS afc.Vehicle;
DROP TABLE IF EXISTS afc.Validator;
DROP TABLE IF EXISTS afc.CardTypes;
GO


CREATE TABLE afc.CardTypes (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Description     VARCHAR(50) NOT NULL,
    Price           DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    IsActive        BIT NOT NULL DEFAULT 1,
    IsDeleted       BIT NOT NULL DEFAULT 0,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Validator (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    ValidatorNumber VARCHAR(20) NOT NULL UNIQUE,
    SerialNumber    VARCHAR(20) NOT NULL UNIQUE,
    GsmNumber       VARCHAR(20) NOT NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    IsDeleted       BIT NOT NULL DEFAULT 0,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Vehicle (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Plate           VARCHAR(15) NOT NULL,
    Validator_Id    INT NOT NULL UNIQUE REFERENCES afc.Validator(Id),
    Brand           VARCHAR(50) NOT NULL,
    Model           VARCHAR(50) NOT NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    IsDeleted       BIT NOT NULL DEFAULT 0,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Cards (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    CardNumber      CHAR(5) NOT NULL UNIQUE,
    MifareId        VARCHAR(20) NOT NULL UNIQUE,
    CardType_Id     INT NOT NULL REFERENCES afc.CardTypes(Id),
    CardStatus      VARCHAR(10) NOT NULL DEFAULT 'Active' CHECK (CardStatus IN ('Active','Blocked','Lost')),
    Balance         DECIMAL(10,2) NOT NULL CHECK (Balance >= 0),
    ProductionDate  DATE NOT NULL,
    ExpirationDate  DATE NOT NULL,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Transactions (
    Id                INT IDENTITY(1,1) PRIMARY KEY,
    Vehicle_Id        INT NOT NULL REFERENCES afc.Vehicle(Id),
    CardNumber        CHAR(5) NOT NULL REFERENCES afc.Cards(CardNumber),
    CardType_Id       INT NOT NULL REFERENCES afc.CardTypes(Id),
    TransactionDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Amount            DECIMAL(10,2) NOT NULL,
    RemainingBalance  DECIMAL(10,2) NOT NULL,
    InsertDate        DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Institution (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Type            VARCHAR(30) NOT NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    IsDeleted       BIT NOT NULL DEFAULT 0,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Dealer (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Institution_Id  INT NOT NULL REFERENCES afc.Institution(Id),
    Region          VARCHAR(50) NOT NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    IsDeleted       BIT NOT NULL DEFAULT 0,
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.Pos (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Dealer_Id       INT NOT NULL REFERENCES afc.Dealer(Id),
    SerialNumber    VARCHAR(20) NOT NULL UNIQUE,
    Status          VARCHAR(10) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active','Inactive')),
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.TopUps (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Pos_Id          INT NOT NULL REFERENCES afc.Pos(Id),
    CardNumber      CHAR(5) NOT NULL REFERENCES afc.Cards(CardNumber),
    Amount          DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    BalanceAfter    DECIMAL(10,2) NOT NULL CHECK (BalanceAfter > 0),
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE afc.BankCardTaps (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Vehicle_Id      INT NOT NULL REFERENCES afc.Vehicle(Id),
    MaskedPan       VARCHAR(25) NOT NULL,
    Amount          DECIMAL(10,2) NOT NULL,
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    InsertDate      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO