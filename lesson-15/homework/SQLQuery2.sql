;USE SSIS15;  -- O'zingiz ishlatayotgan database nomini qo'ying

CREATE TABLE LogTable (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Message NVARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);

INSERT INTO LogTable (Message)
VALUES 
('First log message'),
('Second log message'),
('Another event occurred');


SELECT * from LogTable

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'Sanjarbek_service',  
    @recipients = 'sayyoraibrohimova11@gmail.com',  
    @subject = 'Test Email',  
    @body = 'This is a test email from SSIS Database Mail.' ;


--============================================================	--============================================================	--============================================================	--============================================================
DROP PROCEDURE Send_Log_Report;


CREATE PROCEDURE Send_Log_Report
    @EmailRecipients NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HTMLBody NVARCHAR(MAX);

    -- HTML Header
    SET @HTMLBody = 
    '<html><body><h3>Log Report</h3><table border="1" cellpadding="4" cellspacing="0" style="border-collapse: collapse;">' +
    '<tr style="background-color:#f2f2f2;"><th>ID</th><th>Message</th><th>LogDate</th></tr>';

    -- Cursor orqali log table'dan HTML qatorlar yasaymiz
    DECLARE @ID INT, @Message NVARCHAR(255), @LogDate DATETIME;

    DECLARE log_cursor CURSOR FOR
        SELECT ID, Message, LogDate FROM [dbo].[LogTable];

    OPEN log_cursor;
    FETCH NEXT FROM log_cursor INTO @ID, @Message, @LogDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @HTMLBody += 
            '<tr>' +
            '<td>' + CAST(@ID AS NVARCHAR) + '</td>' +
            '<td>' + ISNULL(@Message, '') + '</td>' +
            '<td>' + CONVERT(NVARCHAR, @LogDate, 120) + '</td>' +
            '</tr>';

        FETCH NEXT FROM log_cursor INTO @ID, @Message, @LogDate;
    END

    CLOSE log_cursor;
    DEALLOCATE log_cursor;

    -- HTML End
    SET @HTMLBody += '</table></body></html>';

    -- Email yuborish
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Sanjarbek_service',
        @recipients = @EmailRecipients,
        @subject = 'Log Table Report',
        @body = @HTMLBody,
        @body_format = 'HTML';
END



--EXEC Send_Log_Report @EmailRecipients = 'sayyoraibrohimova11@gmail.com';
