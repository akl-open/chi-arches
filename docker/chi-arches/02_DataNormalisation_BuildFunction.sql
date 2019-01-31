IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Split')
BEGIN
    DROP FUNCTION dbo.Split;
END;
GO

CREATE FUNCTION [dbo].[Split]
(
    @String VARCHAR(8000),
    @Delimiter CHAR(1)
)
RETURNS @temptable TABLE
(
    items VARCHAR(8000)
)
AS
BEGIN
    DECLARE @idx INT;
    DECLARE @slice VARCHAR(8000);

    SELECT @idx = 1;
    IF LEN(@String) < 1
       OR @String IS NULL
        RETURN;

    WHILE @idx != 0
    BEGIN
        SET @idx = CHARINDEX(@Delimiter, @String);
        IF @idx != 0
            SET @slice = LEFT(@String, @idx - 1);
        ELSE
            SET @slice = @String;

        IF (LEN(@slice) > 0)
            INSERT INTO @temptable
            (
                items
            )
            VALUES
            (@slice);

        SET @String = RIGHT(@String, LEN(@String) - @idx);
        IF LEN(@String) = 0
            BREAK;
    END;
    RETURN;
END;

