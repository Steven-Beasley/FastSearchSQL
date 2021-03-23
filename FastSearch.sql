USE [master]
GO

CREATE DATABASE [FastSearch]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FastSearch', FILENAME = N'/var/opt/mssql/data/FastSearch.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'FastSearch_log', FILENAME = N'/var/opt/mssql/data/FastSearch_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

USE [FastSearch]
GO

CREATE TABLE [dbo].[Words] (
  [WordId] [int] IDENTITY(1,1) NOT NULL,
  [Word] [nvarchar](50) NOT NULL,
  CONSTRAINT [PK_FastSearch] PRIMARY KEY CLUSTERED ([WordId] ASC),
  CONSTRAINT [UIX_Word] UNIQUE ([Word])
);

CREATE TABLE [dbo].[WordFragments] (
  [WordId] [int] NOT NULL,
  [WordFragment] [nvarchar](50) NOT NULL,
  CONSTRAINT [PK_WordFragment] PRIMARY KEY CLUSTERED ([WordFragment] ASC, [WordId] ASC),
  CONSTRAINT [FK_Vehicle] FOREIGN KEY([WordId]) REFERENCES [dbo].[Words]([WordId]),
);
GO

CREATE TRIGGER T_Delete_Word_Fragements ON [dbo].[Words]
	INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DELETE wf
	FROM WordFragments wf
	INNER JOIN deleted ON wf.WordId = deleted.WordId

	DELETE w
	FROM Words w
	INNER JOIN deleted ON w.WordId = deleted.WordId
END
GO

CREATE TRIGGER T_Create_Word_Fragments ON [dbo].[Words]
   FOR INSERT
AS 
BEGIN
  SET NOCOUNT ON;

  WITH frag(WordId, ind) AS
  (
    SELECT WordId, 1 FROM inserted i
	UNION ALL
	SELECT i.WordId, frag.ind + 1
	FROM frag INNER JOIN inserted i ON frag.WordId = i.WordId
	WHERE frag.ind < (LEN(i.Word)) 
  )
  INSERT INTO dbo.WordFragments
  SELECT i.WordId, Fragment = SUBSTRING(i.Word, frag.ind, LEN(i.Word))
  FROM frag INNER JOIN inserted i on frag.WordId = i.WordId
END
GO

-- Random Data Population
DECLARE @Word nvarchar(50);
DECLARE @count int = 1;
DECLARE @error int = 0;
SET NOCOUNT ON;
WHILE @count <= 10000
BEGIN
  SELECT @Word = CONVERT(bigint, ROUND((99999999999999999-11111111111111111)*RAND()+11111111111111111, 0));
  IF (NOT EXISTS(SELECT 1 FROM [dbo].[Words] WHERE Word = @Word))
  BEGIN
    INSERT INTO [dbo].[Words] ([Word]) VALUES (@Word);
	SET @count = @count + 1;
  END
  ELSE
  BEGIN
    SET @error = @error + 1;
	IF @error > 1000
	BEGIN
	  BREAK
	END
  END
END;
GO

SELECT COUNT(1) FROM dbo.Words
SELECT COUNT(1) FROM dbo.WordFragments