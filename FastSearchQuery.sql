USE [FastSearch]
GO

DECLARE @input nvarchar(50) = N'123456'

SELECT COUNT(1) FROM dbo.Words
SELECT COUNT(1) FROM dbo.WordFragments

DECLARE @t1 DATETIME
DECLARE @t2 DATETIME

SET @t1 = GETDATE()
SELECT w.*
FROM dbo.Words w
WHERE w.Word LIKE N'%' + @input + N'%'
SET @t2 = GETDATE()
SELECT DATEDIFF(millisecond, @t1, @t2) AS ms;

SET @t1 = GETDATE()
SELECT DISTINCT w.*
FROM dbo.Words w
INNER JOIN dbo.WordFragments wf
  ON wf.WordId = w.WordId
  AND wf.WordFragment LIKE @input + N'%'
SET @t2 = GETDATE()
SELECT DATEDIFF(millisecond, @t1, @t2) AS ms;

SET @t1 = GETDATE()
SELECT * FROM dbo.Words w
WHERE 
  EXISTS (
    SELECT 1 FROM dbo.WordFragments wf
	WHERE wf.WordId = w.WordId
	AND wf.WordFragment LIKE @input + N'%'
  )
SET @t2 = GETDATE()
SELECT DATEDIFF(millisecond, @t1, @t2) AS ms;