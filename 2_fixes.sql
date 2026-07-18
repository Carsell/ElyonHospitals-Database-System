-- ============================================================
-- fixes.sql — corrections to the original ElyonHospitals schema
-- Run AFTER the original "ElyonHospital Database System.sql".
-- Each fix is numbered and explained; see CHANGES.md for detail.
-- ============================================================

USE ElyonHospitals;
GO

-- ------------------------------------------------------------
-- FIX 1: Replace the two archive triggers with ONE, properly scoped.
-- Problem: the originals deleted EVERY row with that status, not just
-- the rows that were actually updated (unscoped DELETE), and two
-- AFTER UPDATE triggers on one table for the same event is fragile.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS MoveCompletedAppointmentToArchiveTrigger;
DROP TRIGGER IF EXISTS MoveCancelledAppointmentToArchiveTrigger;
GO

CREATE TRIGGER ArchiveFinishedAppointments
ON Appointments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(AppointmentStatus)
    BEGIN
        -- Archive only the rows updated in THIS statement,
        -- and only if not already archived (protects the PK).
        INSERT INTO AppointmentsArchive (AppointmentID, PatientID, DoctorID,
            AppointmentDate, AppointmentStartTime, AppointmentEndTime,
            CancellationReason, CancellationDate, AppointmentStatus, ReasonForVisit)
        SELECT i.AppointmentID, i.PatientID, i.DoctorID,
            i.AppointmentDate, i.AppointmentStartTime, i.AppointmentEndTime,
            i.CancellationReason, i.CancellationDate, i.AppointmentStatus, i.ReasonForVisit
        FROM inserted AS i
        WHERE i.AppointmentStatus IN ('Completed', 'Cancelled')
          AND NOT EXISTS (SELECT 1 FROM AppointmentsArchive a
                          WHERE a.AppointmentID = i.AppointmentID);

        -- Delete only the rows we just archived — scoped to `inserted`.
        DELETE ap
        FROM Appointments AS ap
        INNER JOIN inserted AS i ON ap.AppointmentID = i.AppointmentID
        WHERE i.AppointmentStatus IN ('Completed', 'Cancelled');
    END
END;
GO

-- ------------------------------------------------------------
-- FIX 2: Usernames must be unique. The original data even contained
-- a duplicate ('yawAlioune' for patients 9 and 10) — proof the
-- constraint was needed. Fix the data first, then add constraints.
-- ------------------------------------------------------------
UPDATE PatientsCredentials
SET Username = 'ayanaAlioune'
WHERE PatientID = 10 AND Username = 'yawAlioune';
GO

ALTER TABLE PatientsCredentials ADD CONSTRAINT UQ_PatientsCredentials_Username UNIQUE (Username);
ALTER TABLE DoctorCredentials  ADD CONSTRAINT UQ_DoctorCredentials_Username  UNIQUE (Username);
GO

-- ------------------------------------------------------------
-- FIX 3: Remove the non-deterministic CHECK constraint.
-- Problem: CHECK (AppointmentDate >= GETDATE()) is re-evaluated on
-- every future UPDATE, so touching any old row fails forever.
-- Business rules involving "now" belong in the procedure layer.
-- ------------------------------------------------------------
ALTER TABLE Appointments DROP CONSTRAINT IF EXISTS chk_appointmentdatenotinpast;
GO

-- Enforce the rule where it belongs: in ScheduleAppointment.
ALTER PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATE,
    @AppointmentStartTime TIME,
    @AppointmentEndTime TIME = NULL,
    @ReasonForVisit VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF @AppointmentDate < CONVERT(DATE, GETDATE())
        THROW 50001, 'Appointment date cannot be in the past.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate,
            AppointmentStartTime, AppointmentEndTime, ReasonForVisit, AppointmentStatus)
        VALUES (@PatientID, @DoctorID, @AppointmentDate,
            @AppointmentStartTime, @AppointmentEndTime, @ReasonForVisit, 'Pending');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ------------------------------------------------------------
-- FIX 4: Recreate the view — the archived half concatenated
-- FirstName + LastName without a space.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS DoctorsAppointmentDetails;
GO

CREATE VIEW DoctorsAppointmentDetails AS
SELECT
    D.DoctorID,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    D.Specialization,
    DP.DepartmentName,
    A.AppointmentID, A.AppointmentDate, A.AppointmentStartTime, A.AppointmentEndTime,
    A.AppointmentStatus, A.ReasonForVisit,
    R.ReviewText, R.Ratings
FROM Appointments A
JOIN Doctors D      ON A.DoctorID = D.DoctorID
JOIN Departments DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN Reviews R ON A.AppointmentID = R.AppointmentID
UNION ALL
SELECT
    D.DoctorID,
    D.FirstName + ' ' + D.LastName AS DoctorName,   -- space added
    D.Specialization,
    DP.DepartmentName,
    AA.AppointmentID, AA.AppointmentDate, AA.AppointmentStartTime, AA.AppointmentEndTime,
    AA.AppointmentStatus, AA.ReasonForVisit,
    R.ReviewText, R.Ratings
FROM AppointmentsArchive AA
JOIN Doctors D      ON AA.DoctorID = D.DoctorID
JOIN Departments DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN Reviews R ON AA.AppointmentID = R.AppointmentID;
GO

-- ------------------------------------------------------------
-- FIX 5: Reviews.DoctorID had no foreign key.
-- ------------------------------------------------------------
ALTER TABLE Reviews
ADD CONSTRAINT FK_Reviews_Doctors FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID);
GO
