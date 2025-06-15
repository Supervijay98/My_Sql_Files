use AdventureWorks2022;


CREATE PROCEDURE AllocateElectives
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear any previous allocations
    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;

    -- Declare a cursor to go through students ordered by GPA descending
    DECLARE StudentCursor CURSOR FOR
    SELECT StudentId
    FROM StudentDetails
    ORDER BY GPA DESC;

    DECLARE @StudentId VARCHAR(20);
    DECLARE @Preference INT = 1;
    DECLARE @SubjectId VARCHAR(20);
    DECLARE @Allocated BIT;

    OPEN StudentCursor;

    FETCH NEXT FROM StudentCursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Preference = 1;
        SET @Allocated = 0;

        WHILE @Preference <= 5 AND @Allocated = 0
        BEGIN
            -- Get subject preference for current student and current preference level
            SELECT @SubjectId = sp.SubjectId
            FROM StudentPreference sp
            WHERE sp.StudentId = @StudentId AND sp.Preference = @Preference;

            -- Check if the subject has remaining seats
            IF EXISTS (
                SELECT 1 FROM SubjectDetails
                WHERE SubjectId = @SubjectId AND RemainingSeats > 0
            )
            BEGIN
                -- Allocate the subject to the student
                INSERT INTO Allotments(StudentId, SubjectId)
                VALUES (@StudentId, @SubjectId);

                -- Decrement the remaining seats
                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;

                SET @Allocated = 1;
            END

            SET @Preference = @Preference + 1;
        END

        -- If student wasn't allotted to any subject, mark them unallotted
        IF @Allocated = 0
        BEGIN
            INSERT INTO UnallotedStudents(StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM StudentCursor INTO @StudentId;
    END

    CLOSE StudentCursor;
    DEALLOCATE StudentCursor;
END;

EXEC AllocateElectives;
