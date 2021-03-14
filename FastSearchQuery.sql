USE [FastSearch]
GO

DECLARE @input nvarchar(50) = N'1'

DECLARE @results TABLE (
  [Name] nvarchar(50),
  [SearchValue] nvarchar(50),
  [Exec (ms)] int,
  [Query Row Count] int,
  [Words Count] int,
  [WordFragments Count] int
);

DECLARE @rc int
DECLARE @wc int = (SELECT COUNT(1) FROM Words)
DECLARE @wfc int = (SELECT COUNT(1) FROM WordFragments)
DECLARE @t1 DATETIME
DECLARE @t2 DATETIME

DECLARE @count int = 1

WHILE @count < 6
BEGIN
	SET @t1 = GETDATE()
	SELECT @rc = count(1)
	FROM dbo.Words w
	WHERE w.Word LIKE N'%' + @input + N'%'
	SET @t2 = GETDATE()
	INSERT INTO @results
	SELECT 'Query 1', @input, DATEDIFF(millisecond, @t1, @t2), @rc, @wc, @wfc;

	SET @t1 = GETDATE()
	SELECT @rc = count(1) FROM (
		SELECT DISTINCT w.*
		FROM dbo.Words w
		INNER JOIN dbo.WordFragments wf
			ON wf.WordId = w.WordId
			AND wf.WordFragment LIKE @input + N'%') q
	SET @t2 = GETDATE()
	INSERT INTO @results
	SELECT 'Query 2', @input, DATEDIFF(millisecond, @t1, @t2), @rc, @wc, @wfc;

	SET @t1 = GETDATE()
	SELECT @rc = count(1) FROM dbo.Words w
	WHERE 
	  EXISTS ( 
		SELECT 1 FROM dbo.WordFragments wf
		WHERE wf.WordId = w.WordId
		AND wf.WordFragment LIKE @input + N'%'
	  )
	SET @t2 = GETDATE()
	INSERT INTO @results
	SELECT 'Query 3', @input, DATEDIFF(millisecond, @t1, @t2), @rc, @wc, @wfc;

	SET @count = @count + 1
	SET @input = @input + CAST(@count as nvarchar(5))

END
SELECT * FROM @results 