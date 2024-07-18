CREATE DATABASE ElyonHospitals
USE ElyonHospitals


-- Create Departments Table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(50) NOT NULL,
    DepartmentLocation VARCHAR(30) NOT NULL,
    DepartmentEmailAddress VARCHAR(100) NOT NULL,
    DepartmentPhoneLine VARCHAR(20) NOT NULL
);

-- Create Medicines Table
CREATE TABLE Medicines (
    MedicineID INT PRIMARY KEY IDENTITY(1,1),
    MedicineName VARCHAR(100) NOT NULL,
    DateOfPurchase DATE NOT NULL,
    ExpiryDate DATE NOT NULL
);

CREATE TABLE Patients (
	PatientID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50),
	LastName NVARCHAR(50) NOT NULL,
	Gender CHAR(1) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Occupation VARCHAR(30) NOT NULL,
	EmailAddress VARCHAR(100),
	TelephoneNumber VARCHAR(20),
	HashedInsuranceNumber BINARY(64) NOT NULL CONSTRAINT UC_InsuranceNumber UNIQUE,
	RegistrationDate DATE NOT NULL,
	ExitDate DATE,
	CONSTRAINT CHK_PatientDateOfBirth CHECK (DateOfBirth <= GETDATE()), -- Date of birth should not be in the future
	CONSTRAINT CHK_Patient_Gender CHECK (Gender IN ('M', 'F')), -- Gender should be 'M' or 'F'
	CONSTRAINT CHK_ValidEmailAddress CHECK (EmailAddress LIKE '%_@__%.%') -- Valid email address pattern
);


CREATE TABLE PatientsCredentials (
    PatientID INT PRIMARY KEY,
    Username VARCHAR(30) NOT NULL,
    PasswordHash BINARY(64) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

--- Create Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL,
    DateOfBirth DATE NOT NULL,
    DoctorType VARCHAR(50) NOT NULL,
	HashedMedicalLicenseNumber BINARY (64) NOT NULL  CONSTRAINT UC_MedicalLicenseNumber UNIQUE,
    Specialization VARCHAR(100),
	EmailAddress VARCHAR(100),
	AvailabilityStatus VARCHAR(20) NOT NULL,
    EmploymentDate DATE NOT NULL DEFAULT GETDATE(),
    TerminationDate DATE,
	CONSTRAINT CHK_DoctorEmailAddress CHECK (EmailAddress LIKE '%@%._%'),
    FOREIGN KEY (DepartmentID) REFERENCES Departments (DepartmentID),
	CONSTRAINT CHK_DoctorGender CHECK (Gender IN ('M', 'F')), -- Gender should be 'M' or 'F'
	CONSTRAINT CHK_DoctorDateOfBirth CHECK (DateOfBirth <= GETDATE()), -- Date of birth should not be in the future
	CONSTRAINT CHK_AvailabilityStatus CHECK (AvailabilityStatus IN ('Available', 'Unavailable')), -- Availability status should be either 'Available' or 'Unavailable'
);

CREATE TABLE DoctorCredentials (
    DoctorID INT PRIMARY KEY,
    Username VARCHAR(30) NOT NULL,
    PasswordHash BINARY (64) NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Create Patients Address Details Table
CREATE TABLE PatientsAddressDetails (
    AddressID INT IDENTITY,
	PatientID INT PRIMARY KEY,
    AddressLine1 NVARCHAR(100) NOT NULL,
    AddressLine2 NVARCHAR(100),
    PostCode NVARCHAR(20) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    County NVARCHAR(50),
    Country NVARCHAR(50) NOT NULL,
	FOREIGN KEY (PatientID) REFERENCES Patients (PatientID)
);
-- Create Doctors Address Details Table
CREATE TABLE DoctorsAddressDetails (
    AddressID INT IDENTITY,
	DoctorID INT PRIMARY KEY,
    AddressLine1 NVARCHAR(100) NOT NULL,
    AddressLine2 NVARCHAR(100),
    PostCode NVARCHAR(20) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    County NVARCHAR(50),
    Country NVARCHAR(50) NOT NULL,
	FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID)
);
-- Create Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
	AppointmentDate DATE NOT NULL,
    AppointmentStartTime TIME NOT NULL,
    AppointmentEndTime TIME,
	CancellationReason VARCHAR(255),
    CancellationDate DATETIME,
    AppointmentStatus VARCHAR(20),
    ReasonForVisit VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients (PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID)
);

-- Create Appointments Archive Table
CREATE TABLE AppointmentsArchive (
    ArchiveID INT IDENTITY(1,1),
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
	AppointmentDate DATE NOT NULL,
    AppointmentStartTime TIME NOT NULL,
    AppointmentEndTime TIME,
    CancellationReason VARCHAR(255),
    CancellationDate DATETIME,
	AppointmentStatus VARCHAR(20),
	ReasonForVisit VARCHAR(255),
);
-- Create Reviews table
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1),
    PatientID INT NOT NULL,
	DoctorID INT NOT NULL,
    AppointmentID INT PRIMARY KEY,
    ReviewText VARCHAR(1000),
    Ratings TINYINT,
    FOREIGN KEY (PatientID) REFERENCES Patients (PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES AppointmentsArchive (AppointmentID),
	CONSTRAINT CHK_Ratings CHECK (Ratings BETWEEN 1 AND 5) -- Ratings should be between 1 and 5
);
-- Create Diagnoses Table
CREATE TABLE Diagnoses (
    DiagnosisID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
	AppointmentID INT NOT NULL,
    DiagnosisDate DATE NOT NULL,
    DiagnosisDescription VARCHAR(255) NOT NULL,
	CONSTRAINT UC_Diagnoses_DiagnosisID UNIQUE (DiagnosisID),
    FOREIGN KEY (PatientID) REFERENCES Patients (PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID),
	FOREIGN KEY (AppointmentID) REFERENCES AppointmentsArchive (AppointmentID)
);

-- Create Prescriptions table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    MedicineID INT NOT NULL,
	DiagnosisID INT NOT NULL,
    PrescriptionDate DATE NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patients (PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID),
    FOREIGN KEY (MedicineID) REFERENCES Medicines (MedicineID),
	FOREIGN KEY (DiagnosisID) REFERENCES Diagnoses (DiagnosisID)
);

-- Create Allergies Table
CREATE TABLE Allergies (
    AllergyID INT PRIMARY KEY IDENTITY(1,1),
    AllergyName VARCHAR(100) NOT NULL,
    Reaction VARCHAR(255),
);


--Create Patients Allergies Table
CREATE TABLE PatientsAllergies (
	PatientsAllergyID INT IDENTITY(1,1),
	PatientID INT NOT NULL,
	AllergyID INT NOT NULL,
	PRIMARY KEY (PatientID, AllergyID),
	FOREIGN KEY (PatientID) REFERENCES Patients (PatientID),
	FOREIGN KEY (AllergyID) REFERENCES Allergies (AllergyID)
);

 INSERT INTO Departments (DepartmentName, DepartmentLocation, DepartmentEmailAddress, DepartmentPhoneLine)
VALUES
    ('Endocrinology', 'Main Building, Floor 2', 'endocrinology@elyonhospitals.com', '+44 161-456-7891'),
    ('Radiology', 'West Wing, Floor 1', 'radiology@elyonhospitals.com', '+44 161-567-8902'),
    ('Oncology', 'West Wing, Floor 2', 'oncology@elyonhospitals.com', '+44 161-567-8901'),
    ('Hematology', 'Main Building, Floor 7', 'hematology@elyonhospitals.com', '+44 161-789-0124'),
    ('Rheumatology', 'West Wing, Floor 2', 'rheumatology@elyonhospitals.com', '+44 161-890-1235'),
    ('Gastroenterology', 'East Wing, Floor 2', 'gastroenterology@elyonhospitals.com', '+44 161-901-2345'),
    ('Ophthalmology', 'Main Building, Floor 8', 'ophthalmology@elyonhospitals.com', '+44 161-012-3457'),
    ('Gynecology', 'West Wing, Floor 3', 'gynecology@elyonhospitals.com', '+44 161-123-4568'),
    ('Dentistry', 'East Wing, Floor 6', 'dentistry@elyonhospitals.com', '+44 161-234-5679'),
    ('Geriatrics', 'Main Building, Floor 9', 'geriatrics@elyonhospitals.com', '+44 161-345-6790');

INSERT INTO Medicines (MedicineName, DateOfPurchase, ExpiryDate)
VALUES
    ('Paclitaxel', '2024-09-10', '2025-09-10'),
    ('Omeprazole', '2024-09-15', '2025-09-15'),
    ('Metformin', '2024-10-05', '2025-10-05'),
    ('Warfarin', '2024-10-20', '2025-10-20'),
    ('Lisinopril', '2024-11-08', '2025-11-08'),
    ('Simvastatin', '2024-11-25', '2025-11-25'),
    ('Metoprolol', '2024-12-12', '2025-12-12'),
    ('Losartan', '2024-12-30', '2025-12-30'),
    ('Amlodipine', '2025-01-10', '2026-01-10'),
    ('Hydrochlorothiazide', '2025-01-25', '2026-01-25');


	-- Insert data into Patients table
INSERT INTO Patients (FirstName, MiddleName, LastName, Gender, DateOfBirth, Occupation, EmailAddress, TelephoneNumber, HashedInsuranceNumber, RegistrationDate, ExitDate)
VALUES
('Yaw', NULL, 'Acheampong', 'M', '1987-03-15', 'Teacher', 'yaw.acheampong@yahoo.com', '+442834638921', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS345678')), '2022-10-10', NULL),
('Kwame', NULL, 'Adebisi', 'M', '1990-09-20', 'Engineer', 'kwame.adebisi@gmail.com', '+442822940789', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS567890')), '2022-11-05', NULL),
('Nia', NULL, 'Afia', 'F', '1985-06-12', 'Nurse', 'nia.afia@hotmail.com', '+442816749778', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS234567')), '2021-12-18', NULL),
('Amina', NULL, 'Achebe', 'F', '1963-02-28', 'Doctor', 'amina.achebe@yahoo.com', '+442837394090', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS678901')), '2022-01-25', NULL),
('Kofi', NULL, 'Agu', 'M', '1982-11-08', 'Artist', 'kofi.agu@gmail.com', '+4428435589789', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS901234')), '2022-02-15', NULL),
('Zara', NULL, 'Alioune', 'F', '1998-07-05', 'Student', 'zara.alioune@hotmail.com', '+442813453278', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS012345')), '2022-03-20', NULL),
('Malik', NULL, 'Akpabio', 'M', '1989-04-22', 'Software Developer', 'malik.akpabio@yahoo.com', '+442835736590', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS789012')), '2022-04-30', NULL),
('Sade', NULL, 'Bankole', 'F', '1954-01-10', 'Lawyer', 'sade.bankole@gmail.com', '+442823542389', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS456789')), '2022-05-10', NULL),
('Jabari', NULL, 'Agwuegbo', 'M', '1991-08-18', 'Accountant', 'jabari.agwuegbo@hotmail.com', '+442814867378', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS890123')), '2022-06-05', NULL),
('Ayana', NULL, 'Alioune', 'F', '1996-12-02', 'Chef', 'ayana.alioune@yahoo.com', '+4428322436490', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'INS235567')), '2022-07-15', NULL);

-- Insert data into PatientsCredentials table
INSERT INTO PatientsCredentials (PatientID, Username, PasswordHash)
VALUES
(1, 'kwame123', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'password123'))),
(2, 'niaAdebisi', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'adebisi2021'))),
(3, 'aminaAfia', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'afia@123'))),
(4, 'kofiAchebe', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'kofi1234'))),
(5, 'zaraAgu', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'aguZara'))),
(6, 'malikAlioune', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'alioune12'))),
(7, 'sadeBankole', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'bankoleJ'))),
(8, 'jabariAgwuegbo', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'agwuegboAyana'))),
(9, 'yawAlioune', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'yaw12345'))),
(10, 'yawAlioune', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'yaw12345')));

-- Insert data into Doctors table
INSERT INTO Doctors (DepartmentID, FirstName, MiddleName, LastName, Gender, DateOfBirth, DoctorType, HashedMedicalLicenseNumber, Specialization, EmailAddress, AvailabilityStatus, EmploymentDate, TerminationDate)
VALUES
    (1, 'John', 'Robert', 'Smith', 'M', '1980-05-15', 'General Physician', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'EU123455')), 'Endocrinology', 'john.smith@gmail.com', 'Available', '2010-01-01', NULL),
    (2, 'Emma', 'Mary', 'Johnson', 'F', '1985-09-20', 'Surgeon', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'UK65321')), 'Radiology', 'emma.johnson@gmail.com', 'Available', '2012-03-10', NULL),
    (3, 'David', 'Michael', 'Brown', 'M', '1978-06-12', 'Oncologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'EU789612')), 'Oncology', 'david.brown@gmail.com', 'Available', '2005-08-15', NULL),
    (4, 'Sophia', 'Elizabeth', 'Taylor', 'F', '1982-02-28', 'Cardiologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'UK986654')), 'Hematology', 'sophia.taylor@gmail.com', 'Available', '2008-06-20', NULL),
    (5, 'Oliver', 'James', 'Wilson', 'M', '1975-11-08', 'Rheumatologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'EU375678')), 'Rheumatology', 'oliver.wilson@gmail.com', 'Available', '2015-02-01', NULL),
    (6, 'Amelia', 'Grace', 'Anderson', 'F', '1990-07-05', 'Ophthalmologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'UK018345')), 'Ophthalmology', 'amelia.anderson@gmail.com', 'Available', '2017-09-10', NULL),
    (7, 'William', 'Daniel', 'Miller', 'M', '1987-04-22', 'Gastroenterologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'EU909234')), 'Gastroenterology', 'william.miller@gmail.com', 'Available', '2013-07-15', NULL),
    (8, 'Mia', 'Charlotte', 'Wilson', 'F', '1983-01-10', 'Gynecologist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'UK789512')), 'Gynecology', 'mia.wilson@gmail.com', 'Available', '2011-04-30', NULL),
    (9, 'Alexander', 'George', 'Harris', 'M', '1986-08-18', 'Dentist', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'EU234507')), 'Dentistry', 'alexander.harris@gmail.com', 'Available', '2007-11-05', NULL),
    (10, 'Ella', 'Sophie', 'Thompson', 'F', '1989-12-02', 'Geriatrician', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'UK456389')), 'Geriatrics', 'ella.thompson@gmail.com', 'Available', '2014-05-15', NULL);

-- Insert data into DoctorsCredentials table
INSERT INTO DoctorCredentials (DoctorID, Username, PasswordHash)
VALUES
    (1, 'johnsmith876', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'a1b2c3d4e5'))),
    (2, 'emmajohnson66', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'k1l2m3n4o5'))),
    (3, 'davidbrown749', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'u1v2w3x4y5'))),
    (4, 'sophiataylor62', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'e1f2g3h4i5'))),
    (5, 'oliverwilson94', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'o1p2q3r4s5'))),
    (6, 'ameliaanderson26', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'y1z2a3b4c5'))),
    (7, 'williammiller70', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'i1j2k3l4m5'))),
    (8, 'miawilson99', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 's1t2u3v4w5'))),
    (9, 'alexanderharris22', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'c1d2e3f4g5'))),
    (10, 'ellathompson94', CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', 'm1n2o3p4q5')));



INSERT INTO PatientsAddressDetails (PatientID, AddressLine1, AddressLine2, PostCode, City, County, Country)
VALUES
    (1, '10 Belfast Road', 'Apartment 2A', 'BT1 1AA', 'Belfast', 'Antrim', 'Northern Ireland'),
    (2, '25 Derry Street', 'Flat 3B', 'BT2 2BB', 'Londonderry', 'Londonderry', 'Northern Ireland'),
    (3, '45 Newry Road', NULL, 'BT3 3CC', 'Newry', 'Down', 'Northern Ireland'),
    (4, '77 Armagh Avenue', 'Suite 201', 'BT4 4DD', 'Armagh', 'Armagh', 'Northern Ireland'),
    (5, '5 Enniskillen Lane', 'Unit 5', 'BT5 5EE', 'Enniskillen', 'Fermanagh', 'Northern Ireland'),
    (6, '30 Lisburn Street', NULL, 'BT6 6FF', 'Lisburn', 'Antrim', 'Northern Ireland'),
    (7, '12 Omagh Court', 'Apartment 3C', 'BT7 7GG', 'Omagh', 'Tyrone', 'Northern Ireland'),
    (8, '15 Coleraine Drive', 'Suite 401', 'BT8 8HH', 'Coleraine', 'Londonderry', 'Northern Ireland'),
    (9, '50 Ballymena Lane', NULL, 'BT9 9II', 'Ballymena', 'Antrim', 'Northern Ireland'),
    (10, '100 Portadown Street', 'Unit 7D', 'BT10 10JJ', 'Portadown', 'Armagh', 'Northern Ireland');

INSERT INTO DoctorsAddressDetails (DoctorID, AddressLine1, AddressLine2, PostCode, City, County, Country) 
VALUES 
 (1, '233 Tyrone Road', 'Apt 5B', 'BT79 9AA', 'Omagh', 'Tyrone', 'Northern Ireland'),
 (2, '255 Londonderry Street', NULL, 'BT55 4BB', 'Limavady', 'Londonderry', 'Northern Ireland'),
 (3, '277 Antrim Avenue', 'Suite 3D', 'BT41 8CC', 'Antrim', 'Antrim', 'Northern Ireland'),
 (4, '299 Armagh Lane', NULL, 'BT71 7DD', 'Dungannon', 'Armagh', 'Northern Ireland'),
 (5, '321 Fermanagh Drive', 'Unit 8A', 'BT92 6EE', 'Lisnaskea', 'Fermanagh', 'Northern Ireland'), 
 (6, '343 Down Court', 'Suite 601', 'BT31 9FF', 'Banbridge', 'Down', 'Northern Ireland'), 
 (7, '365 Londonderry Road', NULL, 'BT49 0GG', 'Magherafelt', 'Londonderry', 'Northern Ireland'), 
 (8, '387 Antrim Boulevard', 'Apt 4C', 'BT44 7HH', 'Ballymoney', 'Antrim', 'Northern Ireland'), 
 (9, '409 Armagh Street', 'Suite 5D', 'BT65 8II', 'Craigavon', 'Armagh', 'Northern Ireland'),
 (10, '431 Down Avenue', NULL, 'BT32 3JJ', 'Dromore', 'Down', 'Northern Ireland');

SET IDENTITY_INSERT Appointments ON;
INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, AppointmentStatus, ReasonForVisit)
VALUES
    (11, 1, 2, '2022-06-15', '10:00:00', '10:30:00', 'Cancelled', 'Annual check-up'),
    (12, 2, 5, '2022-06-15', '14:30:00', '15:15:00', 'Cancelled', 'Lab test results'),
    (14, 4, 2, '2022-06-16', '09:30:00', '10:00:00', 'Pending', 'X-ray test results'),
    (15, 5, 5, GETDATE(), '11:15:00', '12:00:00', 'Pending', 'Physical examination'),
    (16, 6, 8, GETDATE(), '14:00:00', '14:45:00', 'Pending', 'HPV Vaccination'),
    (17, 7, 5, GETDATE(), '13:30:00', '14:00:00', 'Pending', 'Medication refill'),
    (18, 8, 9, '2022-06-17', '15:30:00', '16:15:00', 'Pending', 'Follow-up for Dental surgery'),
    (19, 9, 4, '2022-06-18', '09:00:00', '09:30:00', 'Pending', 'Heart Palpitation'),
    (20, 10, 9, '2022-06-18', '11:30:00', '12:15:00', 'Pending', 'Dental check-up');

SET IDENTITY_INSERT Appointments OFF;

INSERT INTO AppointmentsArchive (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, CancellationReason, CancellationDate, AppointmentStatus)
VALUES
    (1, 3, 7, '2022-06-08', '10:00:00', '10:30:00', NULL, NULL, 'Completed'),
    (2, 4, 9, '2022-06-08',  '14:30:00', '15:15:00', NULL, NULL, 'Completed'),
    (3, 5, 3, '2022-06-08', '16:00:00', '16:30:00', 'Doctor unavailable', '2022-06-08 16:30:00', 'Cancelled'),
    (4, 6, 10, '2022-06-09', '09:30:00', '10:00:00', NULL, NULL, 'Completed'),
    (5, 7, 7, '2022-06-09', '11:15:00', '12:00:00', 'Patient no-show', '2022-06-09 12:00:00', 'Cancelled'),
    (6, 8, 3, '2022-06-09', '14:00:00', '14:45:00', NULL, NULL, 'Completed'),
    (7, 9, 10, '2022-06-10', '13:30:00', '14:00:00', 'Patient illness', '2022-06-10 14:00:00', 'Cancelled'),
    (8, 10, 7, '2022-06-10', '15:30:00', '16:15:00', NULL, NULL, 'Completed'),
    (9, 1, 9, '2022-06-11', '09:00:00', '09:30:00', NULL, '2022-06-11 09:30:00', 'Completed'),
    (10, 2, 10, '2022-06-11', '11:30:00', '12:15:00', NULL, NULL, 'Completed');

 INSERT INTO Reviews (PatientID, DoctorID, AppointmentID, ReviewText, Ratings)
VALUES
    (3, 7, 1, 'Great experience with the doctor. Highly recommended!', 5),
    (4, 9, 2, 'The doctor was very knowledgeable and helpful.', 4),
    (6, 10, 4, 'Excellent service and care provided by the doctor.', 5),
    (8, 3, 6, 'I had a positive experience with the doctor.', 4),
    (10, 7, 8, 'The doctor was attentive and addressed all my concerns.', 4),
    (1, 9, 9, 'The doctor was friendly and explained everything clearly.', 5),
    (2, 10, 10, 'I had a great experience with the doctor. Very satisfied.', 5);

INSERT INTO Diagnoses (PatientID, DoctorID, AppointmentID, DiagnosisDate, DiagnosisDescription)
VALUES
    (3, 7, 1, '2022-06-08', 'The patient has a mild case of flu.'),
    (4, 3, 2, '2022-06-08', 'The patient is diagnosed with a throat cancer.'),
    (6, 10, 4, '2022-06-09', 'The patient has a sprained ankle.'),
    (8, 3, 6, '2022-06-09', 'The patient is diagnosed with pancreatic cancer.'),
    (10, 7, 8, '2022-06-10', 'The patient is diagnosed with hypertension.'),
    (1, 9, 9, '2022-06-10', 'The patient is diagnosed with a mouth ulcer.'),
    (2, 10, 10, '2022-06-11', 'The patient has a minor ear infection.');

INSERT INTO Prescriptions (PatientID, DoctorID, MedicineID, DiagnosisID, PrescriptionDate, Dosage)
VALUES
    (3, 7, 4, 1, '2022-06-08', 'Take 2 tablets daily with food.'),
    (4, 9, 5, 2, '2022-06-08', 'Take 1 tablet every 8 hours.'),
    (6, 10, 2, 3, '2022-06-09', 'Apply the ointment twice daily.'),
    (8, 3, 2, 4, '2022-06-09', 'Take 1 tablet daily in the morning.'),
    (10, 7, 6, 5, '2022-06-10', 'Take 2 tablets daily with water.'),
    (1, 9, 2, 6, '2022-06-10', 'Take 1 tablet before meals.'),
    (2, 10, 8, 7, '2022-06-11', 'Apply 2 drops to the affected area twice a day.');

INSERT INTO Allergies (AllergyName, Reaction)
VALUES
    ('Peanuts', 'Swelling and difficulty breathing'),
    ('Penicillin', 'Rash and itching'),
    ('Shellfish', 'Hives and nausea'),
    ('Dust mites', 'Sneezing and wheezing'),
    ('Latex', 'Skin irritation and itching'),
    ('Eggs', 'Stomach cramps and vomiting'),
    ('Milk', 'Digestive upset and diarrhea'),
    ('Soy', 'Allergic rhinitis and skin rash'),
    ('Tree nuts', 'Anaphylaxis and throat swelling'),
    ('Wheat', 'Itchy skin and digestive discomfort');

INSERT INTO PatientsAllergies (PatientID, AllergyID)
VALUES
    (1, 1),
    (1, 3),
    (2, 2),
	(2, 3),
    (3, 5),
	(5, 3),
    (6, 6),
    (7, 8);

ALTER TABLE Appointments
WITH NOCHECK
ADD CONSTRAINT chk_appointmentdatenotinpast
CHECK (AppointmentDate >= GETDATE());

SELECT p.FirstName +' ' + p.LastName as FullName, p.Gender, 
DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) as Age, d.DiagnosisDescription, d.DiagnosisDate,
r.ReviewText
FROM Patients AS p
INNER JOIN Diagnoses AS d ON p.PatientID = d.PatientID
inner join Reviews as R ON r.PatientID = p.PatientID
WHERE DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) > 40 AND d.DiagnosisDescription LIKE '%Cancer%';

CREATE PROCEDURE SearchMedicineByName
    @MedicineName VARCHAR(100)
AS
BEGIN
    SELECT P.FirstName, P.LastName, M.MedicineName, P.DateOfBirth, PR.PrescriptionDate
    FROM Patients AS P
    INNER JOIN Prescriptions AS PR ON P.PatientID = PR.PatientID
    INNER JOIN Medicines AS M ON PR.MedicineID = M.MedicineID
    WHERE M.MedicineName LIKE '%' + @MedicineName + '%'
    ORDER BY PR.PrescriptionDate DESC;
END;

EXEC SearchMedicineByName 'Omeprazole';

CREATE PROCEDURE GetDiagnosesAndAllergiesForPatientToday
    @PatientID INT
AS
BEGIN
    DECLARE @AppointmentDate DATE = CONVERT(DATE, GETDATE());

    SELECT P.PatientID, P.FirstName, P.LastName, D.DiagnosisDescription, AL.AllergyName, AL.Reaction
    FROM Patients AS P
	INNER JOIN Appointments AS A ON P.PatientID = A.PatientID
    INNER JOIN AppointmentsArchive AS Ap ON P.PatientID = Ap.PatientID
    INNER JOIN Diagnoses AS D ON Ap.AppointmentID = D.AppointmentID
    INNER JOIN PatientsAllergies AS PA ON P.PatientID = PA.PatientID
    INNER JOIN Allergies AS AL ON PA.AllergyID = AL.AllergyID
    WHERE P.PatientID = @PatientID
        AND A.AppointmentDate = @AppointmentDate;
END;

EXEC GetDiagnosesAndAllergiesForPatientToday @PatientID = 6;

CREATE PROCEDURE UpdateDoctorDetails
    @DoctorID INT,
    @FirstName NVARCHAR(50) = NULL,
    @MiddleName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @Gender CHAR(1) = NULL,
    @DateOfBirth DATE = NULL,
    @DoctorType VARCHAR(50) = NULL,
    @HashedMedicalLicenseNumber VARCHAR(50) = NULL,
    @Specialization VARCHAR(100) = NULL,
    @EmailAddress VARCHAR(100) = NULL,
    @AvailabilityStatus VARCHAR(20) = NULL,
    @EmploymentDate DATE = NULL,
    @TerminationDate DATE = NULL,
    @AddressLine1 NVARCHAR(100) = NULL,
    @AddressLine2 NVARCHAR(100) = NULL,
    @PostCode NVARCHAR(20) = NULL,
    @City NVARCHAR(50) = NULL,
    @County NVARCHAR(50) = NULL,
    @Country NVARCHAR(50) = NULL,
    @Username VARCHAR(30) = NULL,
    @PasswordHash VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Doctors
    SET
        FirstName = ISNULL(@FirstName, FirstName),
        MiddleName = ISNULL(@MiddleName, MiddleName),
        LastName = ISNULL(@LastName, LastName),
        Gender = ISNULL(@Gender, Gender),
        DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth),
        DoctorType = ISNULL(@DoctorType, DoctorType),
        HashedMedicalLicenseNumber = ISNULL(CONVERT(VARBINARY(100),@HashedMedicalLicenseNumber), HashedMedicalLicenseNumber),
        Specialization = ISNULL(@Specialization, Specialization),
        EmailAddress = ISNULL(@EmailAddress, EmailAddress),
        AvailabilityStatus = ISNULL(@AvailabilityStatus, AvailabilityStatus),
        EmploymentDate = ISNULL(@EmploymentDate, EmploymentDate),
        TerminationDate = ISNULL(@TerminationDate, TerminationDate)
    WHERE DoctorID = @DoctorID;

    UPDATE DoctorsAddressDetails
    SET
        AddressLine1 = ISNULL(@AddressLine1, AddressLine1),
        AddressLine2 = ISNULL(@AddressLine2, AddressLine2),
        PostCode = ISNULL(@PostCode, PostCode),
        City = ISNULL(@City, City),
        County = ISNULL(@County, County),
        Country = ISNULL(@Country, Country)
    WHERE DoctorID = @DoctorID;

    UPDATE DoctorCredentials
    SET
        Username = ISNULL(@Username, Username),
        PasswordHash = ISNULL(CONVERT(VARBINARY(100), @PasswordHash), PasswordHash)
    WHERE DoctorID = @DoctorID;
END;


BEGIN TRANSACTION;
EXEC UpdateDoctorDetails @DoctorID = 9, @AvailabilityStatus = 'Unavailable'
COMMIT


CREATE TRIGGER MoveCompletedAppointmentToArchiveTrigger
ON Appointments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(AppointmentStatus)
    BEGIN
        -- Insert completed appointments into the AppointmentsArchive table
        INSERT INTO AppointmentsArchive (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, CancellationReason, CancellationDate, AppointmentStatus, ReasonForVisit)
        SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, CancellationReason, CancellationDate, AppointmentStatus, ReasonForVisit
        FROM inserted
        WHERE AppointmentStatus = 'Completed';

        -- Delete completed appointments from the Appointments table
        DELETE FROM Appointments WHERE AppointmentStatus = 'Completed';
    END
END;

UPDATE Appointments
SET AppointmentStatus = 'Completed'
WHERE AppointmentID = 18;


CREATE VIEW DoctorsAppointmentDetails AS
SELECT 
    D.DoctorID,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    D.Specialization,
    DP.DepartmentName,
	A.AppointmentID,
    A.AppointmentDate,
    A.AppointmentStartTime,
    A.AppointmentEndTime,
	A.AppointmentStatus,
	A.ReasonForVisit,
    R.ReviewText,
    R.Ratings
FROM 
    Appointments A
JOIN 
    Doctors D ON A.DoctorID = D.DoctorID
JOIN 
    Departments DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN 
    Reviews R ON A.PatientID = R.PatientID AND A.DoctorID = R.DoctorID AND A.AppointmentID = R.AppointmentID
UNION ALL
SELECT 
    D.DoctorID,
    D.FirstName + D.LastName AS DoctorName,
    D.Specialization AS DoctorSpecialty,
    DP.DepartmentName,
	AA.AppointmentID,
    AA.AppointmentDate,
    AA.AppointmentStartTime,
    AA.AppointmentEndTime,
	AA.AppointmentStatus,
	AA.ReasonForVisit,
    R.ReviewText,
    R.Ratings
FROM 
    AppointmentsArchive AA
JOIN 
    Doctors D ON AA.DoctorID = D.DoctorID
JOIN 
    Departments DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN 
    Reviews R ON AA.PatientID = R.PatientID AND AA.DoctorID = R.DoctorID AND AA.AppointmentID = R.AppointmentID;


SELECT *
FROM DoctorsAppointmentDetails
ORDER BY DoctorID


CREATE TRIGGER MoveCancelledAppointmentToArchiveTrigger
ON Appointments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(AppointmentStatus)
    BEGIN
        -- Insert completed appointments into the AppointmentsArchive table
        INSERT INTO AppointmentsArchive (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, CancellationReason, CancellationDate, AppointmentStatus, ReasonForVisit)
        SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, CancellationReason, CancellationDate, AppointmentStatus, ReasonForVisit
        FROM inserted
        WHERE AppointmentStatus = 'Cancelled';

        -- Delete completed appointments from the Appointments table
        DELETE FROM Appointments WHERE AppointmentStatus = 'Cancelled';
    END
END;


UPDATE Appointments
SET AppointmentStatus = 'Cancelled'
WHERE AppointmentID = 11;

SELECT COUNT (*) AS CompletedAppointments
FROM AppointmentsArchive AS A
INNER JOIN Doctors AS D
ON A.DoctorID = D.DoctorID
WHERE A.AppointmentStatus =  'Completed' AND D.DoctorType = 'Gastroenterologist'

--Additional Functionalities
--Function to get the average rating of a doctor
CREATE FUNCTION GetAverageRatingForDoctor(@DoctorID INT)
RETURNS DECIMAL(3, 2)
AS
BEGIN
    DECLARE @AverageRating DECIMAL(3, 2);
    SELECT @AverageRating = AVG(Ratings)
    FROM Reviews
    WHERE DoctorID = @DoctorID;
    RETURN @AverageRating;
END;

DECLARE @DoctorID INT = 7;
SELECT dbo.GetAverageRatingForDoctor(@DoctorID) AS AverageRating;

--A function to get the Number of appointments a department has had
CREATE FUNCTION GetAppointmentCountByDepartment(@DepartmentID INT)
RETURNS INT
AS
BEGIN
    DECLARE @AppointmentCount INT;
    SELECT @AppointmentCount = COUNT(*)
    FROM Appointments A
    INNER JOIN Doctors D ON A.DoctorID = D.DoctorID
    WHERE D.DepartmentID = @DepartmentID;
    
    RETURN @AppointmentCount;
END;

DECLARE @DepartmentID INT = 5;
SELECT dbo.GetAppointmentCountByDepartment(@DepartmentID) AS AppointmentCount;

-- A procedure to cancel appointment
CREATE PROCEDURE CancelAppointment
    @AppointmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Update the AppointmentStatus to 'Cancelled' and set CancellationDate
        UPDATE Appointments
        SET AppointmentStatus = 'Cancelled',
            CancellationDate = GETDATE()
        WHERE AppointmentID = @AppointmentID;

        -- Commit the transaction if the update is successful
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;

EXEC CancelAppointment @AppointmentID = 16;

-- A procedure to Schedure an Appointment
CREATE PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATE,
    @AppointmentStartTime TIME,
    @AppointmentEndTime TIME = NULL,
    @ReasonForVisit VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; 

        -- Inserting appointment details into Appointments table
        INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentStartTime, AppointmentEndTime, ReasonForVisit, AppointmentStatus)
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @AppointmentStartTime, @AppointmentEndTime, @ReasonForVisit, 'Pending');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

EXEC ScheduleAppointment 
    @PatientID = 1, 
    @DoctorID = 4, 
    @AppointmentDate = '2024-10-01', 
    @AppointmentStartTime = '09:00', 
    @ReasonForVisit = 'Follow-up checkup';



-- A procedure to Add a New Doctor
	CREATE PROCEDURE AddNewDoctor
    @DepartmentID INT,
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50),
    @Gender CHAR(1),
    @DateOfBirth DATE,
    @DoctorType VARCHAR(50),
    @HashedMedicalLicenseNumber BINARY(64),
    @Specialization VARCHAR(100),
    @EmailAddress VARCHAR(100),
    @AvailabilityStatus VARCHAR(20),
    @Username VARCHAR(30),
    @PasswordHash BINARY(64),
    @EmploymentDate DATE,
    @AddressLine1 NVARCHAR(100),
    @AddressLine2 NVARCHAR(100) = NULL,
    @PostCode NVARCHAR(20),
    @City NVARCHAR(50),
    @County NVARCHAR(50) = NULL,
    @Country NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @DoctorID INT;

    -- Inserting doctor details into Doctors table
    INSERT INTO Doctors (DepartmentID, FirstName, MiddleName, LastName, Gender, DateOfBirth, DoctorType, HashedMedicalLicenseNumber, Specialization, EmailAddress, AvailabilityStatus, EmploymentDate)
    VALUES (@DepartmentID, @FirstName, @MiddleName, @LastName, @Gender, @DateOfBirth, @DoctorType, @HashedMedicalLicenseNumber, @Specialization, @EmailAddress, @AvailabilityStatus, @EmploymentDate);

-- Retrieving the DoctorID of the newly inserted doctor
    SET @DoctorID = SCOPE_IDENTITY();

-- Inserting doctor's credentials into DoctorCredentials table
    INSERT INTO DoctorCredentials (DoctorID, Username, PasswordHash)
    VALUES (@DoctorID, @Username, @PasswordHash);

-- Inserting doctor's address details into DoctorsAddressDetails table
    INSERT INTO DoctorsAddressDetails (DoctorID, AddressLine1, AddressLine2, PostCode, City, County, Country)
    VALUES (@DoctorID, @AddressLine1, @AddressLine2, @PostCode, @City, @County, @Country);
END;

EXEC AddNewDoctor
    @DepartmentID = 1,
    @FirstName = 'Zainab',
    @MiddleName = 'Damola',
    @LastName = 'Okusaga',
    @Gender = 'F',
    @DateOfBirth = '1980-05-15',
    @DoctorType = 'General Practitioner',
    @HashedMedicalLicenseNumber = 0x1234567890ABCDEF,
    @Specialization = 'Internal Medicine',
    @EmailAddress = 'zainab.smith@gmail.com',
    @AvailabilityStatus = 'Available',
    @Username = 'ZainabOkusaga',
    @PasswordHash = 0x0987654321FEDCBA,
    @EmploymentDate = '2024-04-25',
    @AddressLine1 = '123 Downing Street',
    @AddressLine2 = NULL,
    @PostCode = '10001',
    @City = 'New York',
	@County = 'Manhattan',
    @Country = 'USA';

select *
from Appointments