-- TẠO DATABSE
-- TẠO BẢNG

DROP DATABASE IF EXISTS [05_STUDENT_DB]
CREATE DATABASE [05_STUDENT_DB]
ON
(
	NAME = 'STUDENT_DB',
	FILENAME = 'C:\00_DATA\04_DE_CODE\LESSON_04\STUDENT_DB.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB)
LOG ON
(
	NAME = 'STUDENT_DB_LOG',
	FILENAME = 'C:\00_DATA\04_DE_CODE\LESSON_04\STUDENT_DB.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE [05_STUDENT_DB]
GO

-- CREATE SCHEMAS
CREATE SCHEMA Academic;
GO

CREATE SCHEMA People;
GO

CREATE SCHEMA Records;
GO


DROP TABLE IF EXISTS  Academic.Class
CREATE TABLE Academic.Class
(
	Class_Id  INT IDENTITY (1, 1) PRIMARY KEY,
	Created_Date DATE NOT NULL,
	Created_By NVARCHAR(50) NOT NULL,
	Modified_Date DATE NULL,
	Modified_By NVARCHAR(50) NULL,
	Code NVARCHAR(50) NOT NULL UNIQUE,
	Class_Name NVARCHAR(500) NOT NULL
)

DROP TABLE IF EXISTS People.Student
CREATE TABLE People.Student
(
	Student_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Created_Date DATE NOT NULL,
	Created_By NVARCHAR(50) NOT NULL,
	Modified_Date DATE NULL,
	Modified_By NVARCHAR(50) NULL,
	Code NVARCHAR(50) NOT NULL UNIQUE,
	Student_Name NVARCHAR(500) NOT NULL,
	Date_Of_Birth DATE NULL,
	Gender NVARCHAR(50) NULL,
	Phone_Number NVARCHAR(50) NULL,
	Student_Address NVARCHAR(500) NULL,
	Hobbies NVARCHAR(500) NULL,
	Skills NVARCHAR(500) NULL,
	Notes NVARCHAR(500) NULL,
	Class_Id INT NOT NULL,
	FOREIGN KEY (Class_Id) REFERENCES Academic.Class (Class_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CK_Student_Gender CHECK(Gender IN ('Male', 'Female', 'Orther'))
);

DROP TABLE IF EXISTS Academic.Subject
CREATE TABLE Academic.Subject
(
	Subject_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Subjec_Name VARCHAR(50) NOT NULL,
	Credits TINYINT NOT NULL CONSTRAINT CK_Subject_Credits CHECK(Credits BETWEEN 1 AND 6), -- QUY ĐỊNH SỐ TÍN CHỈ TỪ 1 ĐẾN 6.
	CONSTRAINT UQ_Code UNIQUE(Code)
);

DROP TABLE IF EXISTS People.Teacher
CREATE TABLE People.Teacher
(
	Teacher_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Teacher_Name NVARCHAR(100) NOT NULL,
	Specialization NVARCHAR(100) NOT NULL,
	Email VARCHAR(100) NULL,
	Phone VARCHAR(10) NULL,
	CONSTRAINT UQ_Code UNIQUE(Code)
)

DROP TABLE IF EXISTS Academic.Teaching_Assignment
CREATE TABLE Academic.Teaching_Assignment
(
	Teaching_Assignment_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Student_Id INT NOT NULL,
	Subject_Id INT NOT NULL,
	Teacher_Id INT NOT NULL,
	Semester VARCHAR(100) NOT NULL,
	Academic_Year NVARCHAR(9)  NOT NULL,
	CONSTRAINT UQ_TeachingAssignment_Student_Subject_Teacher UNIQUE(Student_Id, Subject_Id, Teacher_Id),
	CONSTRAINT FK_TeachingAssignment_Student FOREIGN KEY (Student_Id) REFERENCES People.Student (Student_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_TeachingAssignment_Subject FOREIGN KEY (Subject_Id) REFERENCES Academic.Subject (Subject_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_TeachingAssignment_Teacher FOREIGN KEY (Teacher_Id) REFERENCES People.Teacher (Teacher_Id) ON DELETE NO ACTION ON UPDATE CASCADE,
)


DROP TABLE IF EXISTS Records.Enrollment
CREATE TABLE Records.Enrollment
(
	Enrollment_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Student_Id INT NOT NULL,
	Class_Id INT NOT NULL,
	Created_Date DATE NOT NULL CONSTRAINT DF_Enrollment_CreatedDate DEFAULT CAST(GETDATE() AS DATE),
	Enrollment_Status NVARCHAR(50) NOT NULL CONSTRAINT DF_Enrollment_EnrollmentStatus DEFAULT N'Đang học', -- Đang học / Bảo lưu
	CONSTRAINT UQ_Enrollment UNIQUE(Student_Id, Class_Id),
	CONSTRAINT FK_Enrollment_Student FOREIGN KEY (Student_Id) REFERENCES People.Student (Student_Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT FK_Enrollment_Class FOREIGN KEY (Class_Id) REFERENCES Academic.Class (Class_Id) ON DELETE NO ACTION ON UPDATE NO ACTION
)

-- Manage student grades for each subject (through assignment).
DROP TABLE IF EXISTS Academic.Grades;
CREATE TABLE Academic.Grades
(
	Grades_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Student_Id INT NOT NULL,
	Teaching_Assignment_Id INT NOT NULL,
	Midterm_Score DECIMAL(5,2) NOT NULL CONSTRAINT CK_Grades_MidtermScore CHECK(Midterm_score BETWEEN 0 AND 10),
	Final_Score DECIMAL(5,2) NOT NULL CONSTRAINT CK_Grades_FinalScore CHECK(Final_Score BETWEEN 0 AND 10),
	Other_Score DECIMAL(5,2) NOT NULL CONSTRAINT CK_Grades_OtherScore CHECK(Other_Score BETWEEN 0 AND 10),
	Total_Score AS ROUND(Midterm_Score * 0.4 + final_Score * 0.5 + Other_Score * 0.1, 2) PERSISTED,
	CONSTRAINT UQ_Grades_Student_TeachingAssignment UNIQUE(Student_Id, Teaching_Assignment_Id),
	CONSTRAINT FK_Grades_Student FOREIGN KEY (Student_Id) REFERENCES People.Student (Student_Id),
	CONSTRAINT FK_Grades_TeachingAssignment FOREIGN KEY (Teaching_Assignment_Id) REFERENCES Academic.Teaching_Assignment (Teaching_Assignment_Id) ON DELETE CASCADE ON UPDATE CASCADE,
)

DROP TABLE IF EXISTS Academic.Schedule;
CREATE TABLE Academic.Schedule
(
	Schedule_Id INT IDENTITY (1, 1) PRIMARY KEY,
	Teaching_Assignment_Id INT NOT NULL,
	Week_day TINYINT NOT NULL CONSTRAINT CK_Schedule_WeekDay CHECK(Week_day BETWEEN 2 AND 8), -- 2..CN (8 = CN)
	Start_Period TINYINT NOT NULL CONSTRAINT CK_Schedule_StartPeriod CHECK(Start_Period BETWEEN 1 AND 12),
	Numer_Of_Period TINYINT NOT NULL CONSTRAINT CK_Schedule_NumerOfPeriod CHECK(Numer_Of_Period BETWEEN 1 AND 6),
	Classroom VARCHAR(10) NULL,
	-- Không dùng UNIQUE cho Teaching_Assignment_Id
	-- Một Phân công giảng dạy (một lớp học một môn với một giáo viên trong một học kỳ)
	-- có thể có nhiều buổi học trong tuần.
	-- Ví dụ: lớp 10A học Toán với thầy A, có thể có:
	-- Thứ 2, tiết 1–3
	-- Thứ 5, tiết 4–6
	CONSTRAINT FK_Schedule_TeachingAssignment FOREIGN KEY (Teaching_Assignment_Id) REFERENCES Academic.Teaching_Assignment (Teaching_Assignment_Id) ON DELETE CASCADE ON UPDATE CASCADE
)


-- Xóa dữ liệu bảng con trước, rồi đến cha
--DELETE FROM Academic.Schedule;
--DELETE FROM Academic.Grades;
--DELETE FROM Academic.Teaching_Assignment;
--DELETE FROM Records.Enrollment;
--DELETE FROM People.Student;
--DELETE FROM People.Teacher;
--DELETE FROM Academic.Subject;
--DELETE FROM Academic.Class;

---------------------------------------------------------------------------------------INSERT DATA-----------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET DATEFORMAT ymd;

------------------------------------------------------------
-- 1) Academic.Class
------------------------------------------------------------
INSERT INTO Academic.Class(Created_Date, Created_By, Modified_Date, Modified_By, Code, Class_Name)
VALUES
('2025-09-01', N'admin', NULL, NULL, N'10A',  N'Lớp 10A'),
('2025-09-01', N'admin', NULL, NULL, N'10B',  N'Lớp 10B'),
('2025-09-01', N'admin', NULL, NULL, N'11A',  N'Lớp 11A'),
('2025-09-01', N'admin', NULL, NULL, N'11B',  N'Lớp 11B'),
('2025-09-01', N'admin', NULL, NULL, N'12A',  N'Lớp 12A'),
('2025-09-01', N'admin', NULL, NULL, N'12B',  N'Lớp 12B'),
('2025-09-01', N'admin', NULL, NULL, N'12C',  N'Lớp 12C');

------------------------------------------------------------
-- 2) People.Student  (ghi rõ Class_Id bằng tra Code lớp)
------------------------------------------------------------
INSERT INTO People.Student(Created_Date, Created_By, Modified_Date, Modified_By, Code, Student_Name, Date_Of_Birth, Gender, Phone_Number, Student_Address, Hobbies, Skills, Notes, Class_Id)
VALUES
('2025-09-02', N'admin', NULL, NULL, N'S001', N'Nguyễn Văn A', '2009-05-12', 'Male',   '0911111111', N'Hà Nội',    N'Đọc sách',      N'Tin học',    NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'10A')),
('2025-09-02', N'admin', NULL, NULL, N'S002', N'Trần Thị B',   '2009-11-03', 'Female', '0912222222', N'Hải Phòng', N'Bóng rổ',       N'Tiếng Anh',  NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'10A')),
('2025-09-02', N'admin', NULL, NULL, N'S003', N'Lê Quang C',   '2009-07-21', 'Male',   '0913333333', N'Đà Nẵng',   N'Âm nhạc',       N'Toán',       NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'10B')),
('2025-09-02', N'admin', NULL, NULL, N'S004', N'Phạm Thu D',   '2008-02-08', 'Female', '0914444444', N'HCM',       N'Vẽ',            N'Vật lý',     NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'11A')),
('2025-09-02', N'admin', NULL, NULL, N'S005', N'Hoàng Mạnh E', '2008-09-30', 'Male',   '0915555555', N'Bình Dương',N'Bơi lội',       N'Ngữ văn',    NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'11A')),
('2025-09-02', N'admin', NULL, NULL, N'S006', N'Đỗ Mai F',     '2009-01-18', 'Female', '0916666666', N'Cần Thơ',   N'Cắm hoa',       N'Hóa học',    NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'10B')),
('2025-09-02', N'admin', NULL, NULL, N'S007', N'Đào Minh Thuấn', '2009-01-18', 'Male', '0394839208', N'Phú yên',   N'Lập trình',     N'Lập trình',  NULL, (SELECT Class_Id FROM Academic.Class WHERE Code=N'12B'));

------------------------------------------------------------
-- 3) Academic.Subject  (lưu ý Subjec_Name là tên cột đúng theo DDL)
------------------------------------------------------------
INSERT INTO Academic.Subject (Code, Subjec_Name, Credits)
VALUES
('MATH101', N'Toán 10',         4),
('PHY101',  N'Vật lý 10',       3),
('ENG101',  N'Tiếng Anh 10',    3),
('CS101',   N'Tin học 10',      2);

------------------------------------------------------------
-- 4) People.Teacher
------------------------------------------------------------
INSERT INTO People.Teacher (Code, Teacher_Name, Specialization, Email, Phone)
VALUES
('T001', N'Thầy An',   N'Toán',      'an@school.edu',   '0900000001'),
('T002', N'Cô Bình',   N'Vật lý',    'binh@school.edu', '0900000002'),
('T003', N'Thầy Cường',N'Tiếng Anh', 'cuong@school.edu','0900000003');

------------------------------------------------------------
-- 5) Records.Enrollment  (mỗi học sinh gắn với lớp của mình)
--    Dùng Code học sinh để tra Student_Id; Class_Id lấy từ bảng Class theo Code.
------------------------------------------------------------
INSERT INTO Records.Enrollment (Student_Id, Class_Id)
SELECT s.Student_Id, c.Class_Id
FROM People.Student s
JOIN Academic.Class c ON c.Class_Id = s.Class_Id
WHERE s.Code IN (N'S001', N'S002', N'S003', N'S004', N'S005', N'S006', N'S007');

------------------------------------------------------------
-- 6) Academic.Teaching_Assignment
--    (Student_Code, Subject_Code, Teacher_Code, Semester, Academic_Year)
--    UNIQUE(Student_Id, Subject_Id, Teacher_Id) nên mỗi bộ ba phải khác nhau.
------------------------------------------------------------
;WITH base AS (
    SELECT 
        s.Student_Id,
        sj.Subject_Id,
        t.Teacher_Id
    FROM People.Student s
    CROSS JOIN Academic.Subject sj
    CROSS JOIN People.Teacher t
    WHERE 1=0 -- placeholder
)
-- Tạo từng assignment cụ thể:
INSERT INTO Academic.Teaching_Assignment (Student_Id, Subject_Id, Teacher_Id, Semester, Academic_Year)
VALUES
( (SELECT Student_Id FROM People.Student   WHERE Code=N'S001'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T001'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S001'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T003'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S002'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T001'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S002'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T002'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S003'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T003'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S004'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T002'),
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S005'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='CS101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T001'), -- giả sử thầy Toán dạy Tin cơ bản
  'Fall', N'2024-2025'),

( (SELECT Student_Id FROM People.Student   WHERE Code=N'S006'),
  (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101'),
  (SELECT Teacher_Id FROM People.Teacher   WHERE Code='T001'),
  'Fall', N'2024-2025');

------------------------------------------------------------
-- 7) Academic.Grades  (điểm cho từng Teaching_Assignment + Student)
--    Total_Score là cột computed PERSISTED, không cần insert.
------------------------------------------------------------
-- Lấy Teaching_Assignment_Id theo bộ (S, Subject, Teacher)
INSERT INTO Academic.Grades (Student_Id, Teaching_Assignment_Id, Midterm_Score, Final_Score, Other_Score)
VALUES
( (SELECT Student_Id FROM People.Student WHERE Code=N'S001'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S001')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T001')),
  7.50, 8.00, 9.00),

( (SELECT Student_Id FROM People.Student WHERE Code=N'S001'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S001')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T003')),
  8.25, 8.00, 7.50),

( (SELECT Student_Id FROM People.Student WHERE Code=N'S002'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S002')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T001')),
  6.50, 7.00, 7.50),

( (SELECT Student_Id FROM People.Student WHERE Code=N'S002'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S002')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T002')),
  7.00, 7.50, 8.00),

( (SELECT Student_Id FROM People.Student WHERE Code=N'S003'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S003')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T003')),
  8.00, 8.50, 8.00),

( (SELECT Student_Id FROM People.Student WHERE Code=N'S004'),
  (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S004')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T002')),
  8.50, 9.00, 8.00);

------------------------------------------------------------
-- 8) Academic.Schedule  (mỗi Teaching_Assignment có thể nhiều lịch)
------------------------------------------------------------
-- Ví dụ: S001-MATH101-T001 học thứ 2 (2) tiết 1–3 và thứ 5 (5) tiết 4–6
INSERT INTO Academic.Schedule (Teaching_Assignment_Id, Week_day, Start_Period, Numer_Of_Period, Classroom)
VALUES
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S001')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T001')),
  2, 1, 3, 'A101'),
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S001')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T001')),
  5, 4, 3, 'A101'),

-- S001-ENG101-T003
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S001')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T003')),
  3, 2, 2, 'B201'),

-- S002-MATH101-T001
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S002')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='MATH101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T001')),
  2, 4, 2, 'A102'),

-- S002-PHY101-T002
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S002')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T002')),
  4, 3, 2, 'C301'),

-- S003-ENG101-T003
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S003')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='ENG101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T003')),
  6, 1, 3, 'B203'),

-- S004-PHY101-T002
( (SELECT Teaching_Assignment_Id FROM Academic.Teaching_Assignment
   WHERE Student_Id = (SELECT Student_Id FROM People.Student WHERE Code=N'S004')
     AND Subject_Id = (SELECT Subject_Id FROM Academic.Subject WHERE Code='PHY101')
     AND Teacher_Id = (SELECT Teacher_Id FROM People.Teacher WHERE Code='T002')),
  3, 5, 2, 'C101');
