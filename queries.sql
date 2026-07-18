-- ============================================================
-- queries.sql — showcase queries against the ElyonHospitals schema
-- Six queries demonstrating joins, aggregation, window functions,
-- CTEs and date logic. Each answers a question a hospital manager
-- might actually ask.
-- ============================================================

USE ElyonHospitals;
GO

-- Q1. Upcoming appointments with doctor and department context
SELECT a.AppointmentDate, a.AppointmentStartTime,
       p.FirstName + ' ' + p.LastName AS Patient,
       d.FirstName + ' ' + d.LastName AS Doctor,
       dp.DepartmentName, a.ReasonForVisit
FROM Appointments a
JOIN Patients p     ON a.PatientID = p.PatientID
JOIN Doctors d      ON a.DoctorID = d.DoctorID
JOIN Departments dp ON d.DepartmentID = dp.DepartmentID
WHERE a.AppointmentStatus = 'Pending'
ORDER BY a.AppointmentDate, a.AppointmentStartTime;

-- Q2. Rank doctors by average review rating within their department (window function)
SELECT dp.DepartmentName,
       d.FirstName + ' ' + d.LastName AS Doctor,
       AVG(CAST(r.Ratings AS DECIMAL(3,2))) AS AvgRating,
       RANK() OVER (PARTITION BY dp.DepartmentName
                    ORDER BY AVG(CAST(r.Ratings AS DECIMAL(3,2))) DESC) AS RankInDept
FROM Reviews r
JOIN Doctors d      ON r.DoctorID = d.DoctorID
JOIN Departments dp ON d.DepartmentID = dp.DepartmentID
GROUP BY dp.DepartmentName, d.FirstName, d.LastName;

-- Q3. Completed vs cancelled appointments per month (archive analysis)
SELECT FORMAT(AppointmentDate, 'yyyy-MM') AS Month,
       SUM(CASE WHEN AppointmentStatus = 'Completed' THEN 1 ELSE 0 END) AS Completed,
       SUM(CASE WHEN AppointmentStatus = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled
FROM AppointmentsArchive
GROUP BY FORMAT(AppointmentDate, 'yyyy-MM')
ORDER BY Month;

-- Q4. Patients with more than one recorded allergy (junction table + HAVING)
SELECT p.FirstName + ' ' + p.LastName AS Patient,
       COUNT(pa.AllergyID) AS AllergyCount,
       STRING_AGG(al.AllergyName, ', ') AS Allergies
FROM PatientsAllergies pa
JOIN Patients p  ON pa.PatientID = p.PatientID
JOIN Allergies al ON pa.AllergyID = al.AllergyID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(pa.AllergyID) > 1;

-- Q5. Medicines expiring within 60 days (date arithmetic for stock control)
SELECT MedicineName, ExpiryDate,
       DATEDIFF(DAY, GETDATE(), ExpiryDate) AS DaysRemaining
FROM Medicines
WHERE ExpiryDate <= DATEADD(DAY, 60, GETDATE())
ORDER BY ExpiryDate;

-- Q6. Cancellation rate per doctor (CTE + conditional aggregation)
WITH DoctorAppointments AS (
    SELECT DoctorID, AppointmentStatus FROM Appointments
    UNION ALL
    SELECT DoctorID, AppointmentStatus FROM AppointmentsArchive
)
SELECT d.FirstName + ' ' + d.LastName AS Doctor,
       COUNT(*) AS TotalAppointments,
       SUM(CASE WHEN da.AppointmentStatus = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       CAST(100.0 * SUM(CASE WHEN da.AppointmentStatus = 'Cancelled' THEN 1 ELSE 0 END)
            / COUNT(*) AS DECIMAL(5,1)) AS CancellationRatePct
FROM DoctorAppointments da
JOIN Doctors d ON da.DoctorID = d.DoctorID
GROUP BY d.FirstName, d.LastName
ORDER BY CancellationRatePct DESC;
