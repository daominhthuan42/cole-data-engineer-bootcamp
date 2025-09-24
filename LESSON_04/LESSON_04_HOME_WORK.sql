-- Thiết kế CSDL quản lý Nhà thuốc mở rộng --

DROP DATABASE IF EXISTS [07_TRAINING_CENTER_MANAGEMENT]
CREATE DATABASE [07_TRAINING_CENTER_MANAGEMENT]
ON
(
	NAME = 'TRAINING_CENTER_MANAGEMENT',
	FILENAME = 'C:\00_DATA\04_DE_CODE\LESSON_04\TRAINING_CENTER_MANAGEMENT_DB.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB)
LOG ON
(
	NAME = 'TRAINING_CENTER_MANAGEMENT_LOG',
	FILENAME = 'C:\00_DATA\04_DE_CODE\LESSON_04\TRAINING_CENTER_MANAGEMENT_LOG.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE [07_TRAINING_CENTER_MANAGEMENT]
GO 

-- =========================================
-- Core schemas
-- =========================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Academic')   EXEC('CREATE SCHEMA Academic');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Person')     EXEC('CREATE SCHEMA Person');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Schedule')   EXEC('CREATE SCHEMA Schedule');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Enrollment') EXEC('CREATE SCHEMA Enrollment');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Billing')    EXEC('CREATE SCHEMA Billing');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Enrollment') EXEC('CREATE SCHEMA Enrollment');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Assessment') EXEC('CREATE SCHEMA Assessment');

--Person: Student, Instructor
--academic: Department, Course, Prerequisite, CourseOffering
--schedule: Room, TimeSlot, OfferingSchedule
--enrollment: Enrollment, Attendance
--assessment: Assessment, AssessmentScore
--billing: Invoice, InvoiceItem


--1. **Student (Học viên)**
DROP TABLE IF EXISTS Person.Student
CREATE TABLE Person.Student
(
	StudentId VARCHAR(10) NOT NULL PRIMARY KEY,
	FullName NVARCHAR(100) NOT NULL,
	Email VARCHAR(100) NOT NULL CONSTRAINT CK_Student_Email CHECK(
																	Email LIKE '%_@__%.__%'
																	AND Email NOT LIKE '% %'
																	AND LEN(Email) - LEN(REPLACE(Email,'@','')) = 1
																),
	DateOfBirth DATE NOT NULL CONSTRAINT CK_Student_DateOfBirth CHECK(DateOfBirth < (CAST(GETDATE() AS DATE))),
	Gender VARCHAR(10) NULL CONSTRAINT CK_Student_Gender CHECK(Gender in ('Male', 'Female')),
	StudentAddress NVARCHAR(200) NOT NULL,
	JoinDate DATE NOT NULL,
	-- Table-level CHECK: được phép tham chiếu nhiều cột
	CONSTRAINT CK_Student_JoinDate CHECK(
											JoinDate <= (CAST(GETDATE() AS DATE))
											AND JoinDate > DateOfBirth
										),
	-- Tránh trùng email
    CONSTRAINT UQ_StudentEmail UNIQUE (Email)
);

--2. **Instructor (Giảng viên)**
DROP TABLE IF EXISTS Person.Instructor
CREATE TABLE Person.Instructor
(
	InstructorId NVARCHAR(10) NOT NULL PRIMARY KEY,
	FullName NVARCHAR(100) NOT NULL,
	NationalID VARCHAR(12) NOT NULL CONSTRAINT CK_Instructor_NationalID CHECK(
																				LEN(NationalID) = 12
																				AND NationalID NOT LIKE '%[^0-9]%'
																		     ),
	PhoneNumber VARCHAR(10) NOT NULL CONSTRAINT CK_Instructor_PhoneNumber CHECK(
																				LEN(PhoneNumber) = 10
																				AND PhoneNumber NOT LIKE '%[^0-9]%'
																		     ),
	Email VARCHAR(100) NOT NULL CONSTRAINT CK_Instructor_Email CHECK(
																	Email LIKE '%_@__%.__%'
																	AND Email NOT LIKE '% %'
																	AND LEN(Email) - LEN(REPLACE(Email,'@','')) = 1
																),
	HireDate DATE NOT NULL CONSTRAINT CK_Instructor_HireDate CHECK(HireDate <= (CAST(GETDATE() AS DATE))),
	Specialty VARCHAR(100) NOT NULL,
    -- Tránh trùng NationalID
    CONSTRAINT UQ_Instructor_NationalID UNIQUE (NationalID)
);

--3. **Department (Bộ môn)**
DROP TABLE IF EXISTS Academic.Department
CREATE TABLE Academic.Department
(
	DepartmentId NVARCHAR(20) NOT NULL PRIMARY KEY,
	DepartmentName NVARCHAR(100) NOT NULL,
	DepartmentDescription NVARCHAR(500) NULL,
	-- Tránh trùng DepartmentName
    CONSTRAINT UQ_Department_Name UNIQUE (DepartmentName)
);

--4. **Course (Học phần)**
DROP TABLE IF EXISTS Academic.Course
CREATE TABLE Academic.Course
(
	CourseId VARCHAR(10) NOT NULL PRIMARY KEY,
	CourseName NVARCHAR(100) NOT NULL,
	Credits TINYINT NOT NULL CHECK(Credits BETWEEN 1 AND 6),
	DepartmentId NVARCHAR(20) NOT NULL,
	CourseStatus VARCHAR(10) NOT NULL CONSTRAINT CK_Course_CourseStatus CHECK(CourseStatus IN ('Active', 'Inactive')),
	CONSTRAINT FK_Course_DepartmentId FOREIGN KEY(DepartmentId) REFERENCES Academic.Department(DepartmentId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--5. **Prerequisite (Tiên quyết)**
DROP TABLE IF EXISTS Academic.Prerequisite
CREATE TABLE Academic.Prerequisite
(
	CourseId VARCHAR(10) NOT NULL,
	PrereqCourseId VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Prerequisite PRIMARY KEY (CourseId, PrereqCourseId),
	CONSTRAINT FK_Prerequisite_CourseId FOREIGN KEY(CourseId) REFERENCES Academic.Course(CourseId) ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY (PrereqCourseId) REFERENCES Academic.Course(CourseId) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Prerequisite_NoSelf CHECK (CourseId <> PrereqCourseId)
);

--6. **Room (Phòng học)**
DROP TABLE IF EXISTS Schedule.Room
CREATE TABLE Schedule.Room
(
	RoomId VARCHAR(10) NOT NULL PRIMARY KEY,
	Capacity TINYINT NOT NULL CONSTRAINT CK_Room_Capacity CHECK(Capacity >= 1),
	LocationRoom VARCHAR(100) NOT NULL
);

--7. **TimeSlot (Khung giờ)**
DROP TABLE IF EXISTS Schedule.TimeSlot
CREATE TABLE Schedule.TimeSlot
(
	TimeSlotId VARCHAR(10) NOT NULL PRIMARY KEY,
	DayInWeek TINYINT NOT NULL CONSTRAINT CK_TimeSlot_Day CHECK (DayInWeek BETWEEN 1 AND 7),
	StartTime TIME NOT NULL,
	EndTime TIME NOT NULL,
	CONSTRAINT CK_TimeSlot_EndTime CHECK(EndTime > StartTime),
	CONSTRAINT UQ_TimeSlot UNIQUE(TimeSlotId, StartTime, EndTime)
);

--8. **CourseOffering (Lớp mở theo kỳ)**
DROP TABLE IF EXISTS Academic.CourseOffering
CREATE TABLE Academic.CourseOffering
(
	OfferingId VARCHAR(10) NOT NULL PRIMARY KEY,
	CourseId  VARCHAR(10) NOT NULL,
	InstructorId NVARCHAR(10) NOT NULL,
	Term VARCHAR(10) NOT NULL,
	RoomId VARCHAR(10) NOT NULL,
	Capacity TINYINT NOT NULL CONSTRAINT CK_CourseOffering_Capacity CHECK(Capacity >= 1),
	CONSTRAINT FK_CourseOffering_CourseId FOREIGN KEY(CourseId) REFERENCES Academic.Course(CourseId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_CourseOffering_InstructorId FOREIGN KEY(InstructorId) REFERENCES Person.Instructor(InstructorId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_CourseOffering_RoomId FOREIGN KEY(RoomId) REFERENCES Schedule.Room(RoomId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--9. **OfferingSchedule (Lịch học của lớp)**
DROP TABLE IF EXISTS Schedule.OfferingSchedule
CREATE TABLE Schedule.OfferingSchedule
(
	OfferingScheduleId VARCHAR(10) NOT NULL PRIMARY KEY,
	OfferingId VARCHAR(10) NOT NULL,
	TimeSlotId VARCHAR(10) NOT NULL,
	CONSTRAINT UQ_OfferingSchedule UNIQUE(OfferingId, TimeSlotId),
	CONSTRAINT FK_OfferingSchedule_OfferingId FOREIGN KEY(OfferingId) REFERENCES Academic.CourseOffering(OfferingId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_OfferingSchedule_TimeSlotId FOREIGN KEY(TimeSlotId) REFERENCES Schedule.TimeSlot(TimeSlotId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--10. **Enrollment (Đăng ký học)**
DROP TABLE IF EXISTS Enrollment.Enrollment
CREATE TABLE Enrollment.Enrollment
(
	EnrollmentId VARCHAR(10) NOT NULL PRIMARY KEY,
	StudentId VARCHAR(10) NOT NULL,
	OfferingId VARCHAR(10) NOT NULL,
	EnrollDate DATE NOT NULL CONSTRAINT CK_Enrollment_EnrollDate CHECK(EnrollDate < (CAST(GETDATE() AS DATE))),
	EnrollmentStatus VARCHAR(20) NOT NULL CONSTRAINT CK_Enrollment_EnrollmentStatus CHECK(EnrollmentStatus IN ('Enrolled', 'Withdrawn')),
	CONSTRAINT UQ_Enrollment UNIQUE (OfferingId, StudentId),
	CONSTRAINT FK_Enrollment_StudentId FOREIGN KEY(StudentId) REFERENCES Person.Student(StudentId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_Enrollment_OfferingId FOREIGN KEY(OfferingId) REFERENCES Academic.CourseOffering(OfferingId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--11. **Attendance (Điểm danh)**
DROP TABLE IF EXISTS Enrollment.Attendance
CREATE TABLE Enrollment.Attendance
(
	AttendanceId VARCHAR(10) NOT NULL PRIMARY KEY,
	OfferingId VARCHAR(10) NOT NULL,
	StudentId VARCHAR(10) NOT NULL,
	SessionDate DATE CONSTRAINT CK_Attendance_SessionDate CHECK(SessionDate < (CAST(GETDATE() AS DATE))),
	Present CHAR(1) NOT NULL CONSTRAINT CK_Attendance_Present CHECK(Present IN ('Y', 'N')),
	CONSTRAINT UQ_Attendance UNIQUE (OfferingId, StudentId, SessionDate),
	CONSTRAINT FK_Attendance_StudentId FOREIGN KEY(StudentId) REFERENCES Person.Student(StudentId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_Attendance_OfferingId FOREIGN KEY(OfferingId) REFERENCES Academic.CourseOffering(OfferingId) ON DELETE NO ACTION ON UPDATE CASCADE
);

SELECT name FROM sys.schemas
WHERE name IN ('Person','Academic','Schedule','Enrollment','Billing','Assessment');

--12. **Assessment (Đánh giá/Điểm thành phần)**
DROP TABLE IF EXISTS Assessment.Assessment
CREATE TABLE Assessment.Assessment
(
	AssessmentId VARCHAR(10) NOT NULL PRIMARY KEY,
	OfferingId VARCHAR(10) NOT NULL,
	Title VARCHAR(50) NOT NULL,
	WeightPercent DECIMAL(5, 2) NOT NULL CONSTRAINT CK_Assessment_WeightPercent CHECK(WeightPercent BETWEEN 0 AND 100),
	DueDate DATE NOT NULL,
	CONSTRAINT FK_Assessment_OfferingId FOREIGN KEY(OfferingId) REFERENCES Academic.CourseOffering(OfferingId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT UQ_Assessment UNIQUE (OfferingId, Title)
);

--13. **AssessmentScore (Điểm học viên)**
DROP TABLE IF EXISTS Assessment.AssessmentScore
CREATE TABLE Assessment.AssessmentScore
(
	AssessmentId VARCHAR(10) NOT NULL,
	StudentId VARCHAR(10) NOT NULL,
	Score DECIMAL(4, 2) NOT NULL CONSTRAINT CK_AssessmentScore_Score CHECK(Score BETWEEN 0 AND 10),
	CONSTRAINT PK_AssessmentScore PRIMARY KEY (AssessmentId, StudentId),
	CONSTRAINT FK_AssessmentScore_StudentId FOREIGN KEY(StudentId) REFERENCES Person.Student(StudentId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_AssessmentScore_OfferingId FOREIGN KEY(AssessmentId) REFERENCES Assessment.Assessment(AssessmentId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--14. **Invoice (Hóa đơn học phí)**
DROP TABLE IF EXISTS Billing.Invoice
CREATE TABLE Billing.Invoice
(
	InvoiceId VARCHAR(10) NOT NULL PRIMARY KEY,
	StudentId VARCHAR(10) NOT NULL,
	InvoiceDate DATE NOT NULL CONSTRAINT CK_Invoice_InvoiceDate CHECK(InvoiceDate < (CAST(GETDATE() AS DATE))),
	TotalAmount INT NOT NULL CONSTRAINT CK_Invoice_TotalAmount CHECK(TotalAmount >= 0),
	PaymentStatus VARCHAR(20) NOT NULL CONSTRAINT CK_Invoice_PaymentStatus CHECK(PaymentStatus IN ('Unpaid', 'Paid', 'Partial')),
	CONSTRAINT FK_Invoice_StudentId FOREIGN KEY(StudentId) REFERENCES Person.Student(StudentId) ON DELETE NO ACTION ON UPDATE CASCADE
);

--15. **InvoiceItem (Chi tiết hóa đơn)**
DROP TABLE IF EXISTS Billing.InvoiceItem
CREATE TABLE Billing.InvoiceItem
(
	InvoiceItemId VARCHAR(10) NOT NULL PRIMARY KEY,
	InvoiceId VARCHAR(10) NOT NULL,
	OfferingId VARCHAR(10) NOT NULL,
	UnitPrice DECIMAL(19,4) CONSTRAINT CK_InvoiceItem_UnitPrice CHECK(UnitPrice > 0),
	Quantity INT CONSTRAINT CK_InvoiceItem_Quantity CHECK(Quantity > 0),
	DiscountPercent DECIMAL(5, 2) CONSTRAINT CK_InvoiceItem_DiscountPercent CHECK(DiscountPercent BETWEEN 0 AND 100),
	TotalAmount AS ROUND(UnitPrice * Quantity * (1 - DiscountPercent / 100), 2) PERSISTED,
	CONSTRAINT UQ_InvoiceItem UNIQUE (InvoiceId, OfferingId),
	CONSTRAINT FK_InvoiceItem_StudentId FOREIGN KEY(InvoiceId) REFERENCES Billing.Invoice(InvoiceId) ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT FK_InvoiceItem_OfferingId FOREIGN KEY(OfferingId) REFERENCES Academic.CourseOffering(OfferingId) ON DELETE NO ACTION ON UPDATE CASCADE
);
