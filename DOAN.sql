-- Topic: TinyCollege

-- Tables - Data - Indexes
DROP DATABASE IF EXISTS TinyCollege;
CREATE DATABASE TinyCollege
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE TinyCollege;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Tables

CREATE TABLE SCHOOL (
    SCHOOL_CODE VARCHAR(20) PRIMARY KEY,
    SCHOOL_NAME VARCHAR(100) NOT NULL UNIQUE,
    PROF_NUM INT NULL
);

CREATE TABLE DEPARTMENT (
    DEPT_CODE VARCHAR(20) PRIMARY KEY,
    DEPT_NAME VARCHAR(100) NOT NULL UNIQUE,
    SCHOOL_CODE VARCHAR(20) NOT NULL,
    DEAN_PROF_NUM INT NULL
);

CREATE TABLE PROFESSOR (
    PROF_NUM INT PRIMARY KEY,
    DEPT_CODE VARCHAR(20) NOT NULL,
    PROF_SPECIALTY VARCHAR(100) NULL,
    PROF_RANK VARCHAR(50) NULL
        CHECK (PROF_RANK IN (
            'Instructor',
            'Asst Prof',
            'Asso Prof',
            'Prof'
        )),
    PROF_LNAME VARCHAR(50) NOT NULL,
    PROF_FNAME VARCHAR(50) NOT NULL,
    PROF_INITIAL VARCHAR(10) NULL,
    PROF_EMAIL VARCHAR(100) NULL UNIQUE
);

CREATE TABLE COURSE (
    CRS_CODE VARCHAR(20) PRIMARY KEY,
    DEPT_CODE VARCHAR(20) NOT NULL,
    CRS_TITLE VARCHAR(150) NOT NULL,
    CRS_DESCRIPTION TEXT NULL,
    CRS_CREDIT INT NOT NULL
        CHECK (CRS_CREDIT > 0)
);

CREATE TABLE SEMESTER (
    SEMESTER_CODE VARCHAR(20) PRIMARY KEY,
    SEMESTER_YEAR INT NOT NULL
        CHECK (SEMESTER_YEAR >= 2000),
    SEMESTER_TERM VARCHAR(20) NOT NULL
        CHECK (SEMESTER_TERM IN (
            'Spring',
            'Summer',
            'Fall'
        )),
    SEMESTER_START_DATE DATE NULL,
    SEMESTER_END_DATE DATE NULL,
    CHECK (SEMESTER_END_DATE > SEMESTER_START_DATE)
);

CREATE TABLE BUILDING (
    BLDG_CODE VARCHAR(20) PRIMARY KEY,
    BLDG_NAME VARCHAR(100) NOT NULL UNIQUE,
    BLDG_LOCATION VARCHAR(255) NULL
);

CREATE TABLE ROOM (
    ROOM_CODE VARCHAR(20) PRIMARY KEY,
    BLDG_CODE VARCHAR(20) NOT NULL,
    ROOM_TYPE VARCHAR(50) NULL
);

CREATE TABLE CLASS_MEETING (
    CLASS_CODE VARCHAR(20),
    DAY_OF_WEEK ENUM('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'),
    START_TIME TIME NOT NULL,
    END_TIME TIME NOT NULL,
    PRIMARY KEY (CLASS_CODE, DAY_OF_WEEK, START_TIME),
    CHECK (END_TIME > START_TIME)
);

CREATE TABLE CLASS (
    CLASS_CODE VARCHAR(20) PRIMARY KEY,
    CRS_CODE VARCHAR(20) NOT NULL,
    PROF_NUM INT NULL,
    ROOM_CODE VARCHAR(20) NULL,
    SEMESTER_CODE VARCHAR(20) NOT NULL,
    CLASS_SECTION VARCHAR(10) NULL,
    CLASS_TIME VARCHAR(100) NULL,
    CONSTRAINT CHK_CLASS_INSTRUCTOR_OR_ROOM CHECK (PROF_NUM IS NOT NULL OR ROOM_CODE IS NOT NULL)
);

CREATE TABLE STUDENT (
    STU_NUM INT PRIMARY KEY,
    DEPT_CODE VARCHAR(20) NOT NULL,
    ADVISOR_PROF_NUM INT NULL,
    STU_LNAME VARCHAR(50) NOT NULL,
    STU_FNAME VARCHAR(50) NOT NULL,
    STU_INITIAL VARCHAR(10) NULL,
    STU_EMAIL VARCHAR(100) NULL UNIQUE
);

CREATE TABLE ENROLL (
    CLASS_CODE VARCHAR(20),
    STU_NUM INT,
    ENROLL_DATE DATE NOT NULL,
    ENROLL_GRADE VARCHAR(10) NULL
        CHECK (
            ENROLL_GRADE IS NULL OR
            ENROLL_GRADE IN (
                'A','A-',
                'B+','B','B-',
                'C+','C','C-',
                'D+','D',
                'F'
            )
        ),
    PRIMARY KEY (CLASS_CODE, STU_NUM)
);
-- PK, FK
ALTER TABLE SCHOOL ADD CONSTRAINT FK_SCH_PROF FOREIGN KEY (PROF_NUM) REFERENCES PROFESSOR(PROF_NUM);
ALTER TABLE DEPARTMENT ADD CONSTRAINT FK_DEP_SCH FOREIGN KEY (SCHOOL_CODE) REFERENCES SCHOOL(SCHOOL_CODE);
ALTER TABLE DEPARTMENT ADD CONSTRAINT FK_DEP_PROF FOREIGN KEY (DEAN_PROF_NUM) REFERENCES PROFESSOR(PROF_NUM);
ALTER TABLE PROFESSOR ADD CONSTRAINT FK_PROF_DEP FOREIGN KEY (DEPT_CODE) REFERENCES DEPARTMENT(DEPT_CODE);
ALTER TABLE COURSE ADD CONSTRAINT FK_CRS_DEP FOREIGN KEY (DEPT_CODE) REFERENCES DEPARTMENT(DEPT_CODE);
ALTER TABLE ROOM ADD CONSTRAINT FK_RM_BLDG FOREIGN KEY (BLDG_CODE) REFERENCES BUILDING(BLDG_CODE);
ALTER TABLE CLASS ADD CONSTRAINT FK_CL_CRS FOREIGN KEY (CRS_CODE) REFERENCES COURSE(CRS_CODE);
ALTER TABLE CLASS ADD CONSTRAINT FK_CL_PROF FOREIGN KEY (PROF_NUM) REFERENCES PROFESSOR(PROF_NUM);
ALTER TABLE CLASS ADD CONSTRAINT FK_CL_RM FOREIGN KEY (ROOM_CODE) REFERENCES ROOM(ROOM_CODE);
ALTER TABLE CLASS ADD CONSTRAINT FK_CL_SEM FOREIGN KEY (SEMESTER_CODE) REFERENCES SEMESTER(SEMESTER_CODE);
ALTER TABLE STUDENT ADD CONSTRAINT FK_STU_DEP FOREIGN KEY (DEPT_CODE) REFERENCES DEPARTMENT(DEPT_CODE);
ALTER TABLE STUDENT ADD CONSTRAINT FK_STU_PROF FOREIGN KEY (ADVISOR_PROF_NUM) REFERENCES PROFESSOR(PROF_NUM);
ALTER TABLE CLASS_MEETING ADD CONSTRAINT FK_CM_CL FOREIGN KEY (CLASS_CODE) REFERENCES CLASS(CLASS_CODE);
ALTER TABLE ENROLL ADD CONSTRAINT FK_EN_CL FOREIGN KEY (CLASS_CODE) REFERENCES CLASS(CLASS_CODE);
ALTER TABLE ENROLL ADD CONSTRAINT FK_EN_STU FOREIGN KEY (STU_NUM) REFERENCES STUDENT(STU_NUM);


-- 2. Insert Data
INSERT INTO SCHOOL (SCHOOL_CODE, SCHOOL_NAME, PROF_NUM) VALUES
('BUS', 'School of Business', 101),
('AS', 'School of Arts and Sciences', 105),
('ED', 'School of Education', 110),
('ENG', 'School of Engineering', 114),
('MED', 'School of Medicine', 116),
('LAW', 'School of Law', 119);


INSERT INTO DEPARTMENT (DEPT_CODE, DEPT_NAME, SCHOOL_CODE, DEAN_PROF_NUM) VALUES
('ACCT', 'Accounting Department', 'BUS', 102),
('MGT', 'Management Department', 'BUS', 101),
('CIS', 'Computer Information Systems', 'BUS', 103),
('BIOL', 'Biology Department', 'AS', 105),
('CHEM', 'Chemistry Department', 'AS', 106),
('ENG', 'English Department', 'AS', 108),
('MATH', 'Mathematics Department', 'AS', 109),
('CIED', 'Curriculum and Instruction', 'ED', 110),
('PHAR', 'Pharmacy Department', 'MED', 116),
('NURS', 'Nursing Department', 'MED', 117),
('CLAW', 'Commercial Law Department', 'LAW', 119);

INSERT INTO PROFESSOR (PROF_NUM, DEPT_CODE, PROF_SPECIALTY, PROF_RANK, PROF_LNAME, PROF_FNAME, PROF_INITIAL, PROF_EMAIL) VALUES
(101, 'MGT', 'Strategic Management', 'Prof', 'Barrett', 'John', 'M', 'jbarrett@tiny.edu'),
(102, 'ACCT', 'Financial Accounting', 'Asso Prof', 'Cruiz', 'Maria', 'L', 'mcruiz@tiny.edu'),
(103, 'CIS', 'Database Systems', 'Prof', 'Robby', 'William', 'D', 'wrobby@tiny.edu'),
(104, 'CIS', 'Software Engineering', 'Asst Prof', 'Austin', 'David', 'G', 'daustin@tiny.edu'),
(105, 'BIOL', 'Molecular Biology', 'Prof', 'Grastone', 'Robert', 'T', 'rgrastone@tiny.edu'),
(106, 'CHEM', 'Organic Chemistry', 'Prof', 'Williamson', 'Emily', 'K', 'ewilliamson@tiny.edu'),
(107, 'CHEM', 'Analytical Chem', 'Asst Prof', 'Jones', 'Arthur', 'F', 'ajones@tiny.edu'),
(108, 'ENG', 'Modern Literature', 'Asso Prof', 'Smith', 'Sarah', 'J', 'ssmith@tiny.edu'),
(109, 'MATH', 'Discrete Mathematics', 'Prof', 'Aniston', 'Jennifer', 'A', 'janiston@tiny.edu'),
(110, 'CIED', 'Early Childhood Ed', 'Prof', 'Thomas', 'Andrew', 'E', 'athomas@tiny.edu'),
(111, 'MGT', 'Human Resources', 'Asst Prof', 'Washington', 'George', 'W', 'gwashington@tiny.edu'),
(112, 'ACCT', 'Taxation Accounting', 'Instructor', 'Lee', 'Bruce', 'X', 'blee@tiny.edu'),
(113, 'CIS', 'Data Networks', 'Asso Prof', 'Gates', 'Bill', 'H', 'bgates@tiny.edu'),
(114, 'MATH', 'Applied Statistics', 'Prof', 'Newton', 'Isaac', 'I', 'inewton@tiny.edu'),
(115, 'BIOL', 'Genetics', 'Instructor', 'Darwin', 'Charles', 'R', 'cdarwin@tiny.edu'),
(116, 'PHAR', 'Clinical Pharmacy', 'Prof', 'Fleming', 'Alexander', 'A', 'afleming@tiny.edu'),
(117, 'NURS', 'Pediatric Nursing', 'Asso Prof', 'Nightingale', 'Florence', 'F', 'fnightingale@tiny.edu'),
(118, 'CIS', 'Artificial Intelligence', 'Asst Prof', 'Turing', 'Alan', 'M', 'aturing@tiny.edu'),
(119, 'CLAW', 'Corporate Law', 'Prof', 'Lincoln', 'Abraham', 'A', 'alincoln@tiny.edu'),
(120, 'MATH', 'Topology', 'Instructor', 'Euler', 'Leonhard', 'P', 'leuler@tiny.edu');

INSERT INTO COURSE (CRS_CODE, DEPT_CODE, CRS_TITLE, CRS_DESCRIPTION, CRS_CREDIT) VALUES
('ACCT-211', 'ACCT', 'Principles of Acct I', 'Introduction to financial accounting', 3),
('ACCT-212', 'ACCT', 'Principles of Acct II', 'Introduction to managerial accounting', 3),
('CIS-220', 'CIS', 'Fundamentals of Databases', 'Relational database design and SQL', 4),
('CIS-420', 'CIS', 'Database Systems Systems', 'Advanced database implementation', 4),
('CIS-310', 'CIS', 'Network Server Admin', 'Managing enterprise servers', 3),
('MGT-301', 'MGT', 'Principles of Management', 'Basic concepts of management', 3),
('BIOL-101', 'BIOL', 'General Biology I', 'Cell structure and genetics', 4),
('CHEM-201', 'CHEM', 'General Chemistry I', 'Inorganic chemistry foundations', 4),
('ENG-110', 'ENG', 'English Composition', 'College level writing skills', 3),
('MATH-241', 'MATH', 'Calculus I', 'Limits, derivatives, and integrals', 4),
('MATH-115', 'MATH', 'College Algebra', 'Basic algebraic equations', 3),
('CIS-330', 'CIS', 'Artificial Intelligence Intro', 'Concepts of AI and Machine Learning', 3),
('PHAR-101', 'PHAR', 'Intro to Pharmacology', 'Fundamentals of drug actions', 4),
('CLAW-201', 'CLAW', 'Business Law I', 'Legal environment of business organizations', 3),
('MATH-302', 'MATH', 'Linear Algebra', 'Vector spaces and matrices', 3);

INSERT INTO SEMESTER (SEMESTER_CODE, SEMESTER_YEAR, SEMESTER_TERM, SEMESTER_START_DATE, SEMESTER_END_DATE) VALUES
('2025-FALL', 2025, 'Fall', '2025-08-20', '2025-12-15'),
('2026-SPRING', 2026, 'Spring', '2026-01-10', '2026-05-12'),
('2026-SUMMER', 2026, 'Summer', '2026-06-01', '2026-07-28'),
('2026-FALL', 2026, 'Fall', '2026-08-22', '2026-12-18'),
('2027-SPRING', 2027, 'Spring', '2027-01-12', '2027-05-18');

INSERT INTO BUILDING (BLDG_CODE, BLDG_NAME, BLDG_LOCATION) VALUES
('KNL', 'Knowledge Hall', 'North Campus'),
('SCI', 'Science Complex', 'East Campus'),
('HUM', 'Humanities Building', 'South Campus'),
('BA', 'Business Administration', 'West Campus'),
('MED-BLDG', 'Medical Sciences Building', 'South Campus'),
('LAW-HALL', 'Justice Hall', 'West Campus');

INSERT INTO ROOM (ROOM_CODE, BLDG_CODE, ROOM_TYPE) VALUES
('KNL-101', 'KNL', 'Lecture Hall'),
('KNL-202', 'KNL', 'Computer Lab'),
('SCI-105', 'SCI', 'Chemistry Lab'),
('SCI-301', 'SCI', 'Auditorium'),
('HUM-101', 'HUM', 'Seminar Room'),
('BA-110', 'BA', 'Standard Classroom'),
('BA-220', 'BA', 'Advanced Lab'),
('BA-305', 'BA', 'Conference Hall'),
('MED-101', 'MED-BLDG', 'Anatomy Lab'),
('MED-202', 'MED-BLDG', 'Standard Classroom'),
('LAW-301', 'LAW-HALL', 'Mock Courtroom');

INSERT INTO CLASS (CLASS_CODE, CRS_CODE, PROF_NUM, ROOM_CODE, SEMESTER_CODE, CLASS_SECTION, CLASS_TIME) VALUES
('1001', 'CIS-220', 103, 'KNL-202', '2026-SPRING', 'SEC-01', 'MWF 09:00-09:50'),
('1002', 'CIS-220', 104, 'BA-220', '2026-SPRING', 'SEC-02', 'TTH 10:30-11:45'),
('1003', 'ACCT-211', 102, 'BA-110', '2026-SPRING', 'SEC-01', 'MWF 08:00-08:50'),
('1004', 'MGT-301', 101, 'BA-305', '2026-SPRING', 'SEC-01', 'TTH 14:00-15:15'),
('1005', 'BIOL-101', 105, 'SCI-301', '2026-SPRING', 'SEC-01', 'MWF 11:00-11:50'),
('1006', 'CHEM-201', 106, 'SCI-105', '2026-SPRING', 'SEC-01', 'TTH 08:00-10:15'),
('1007', 'MATH-241', 109, 'KNL-101', '2026-SPRING', 'SEC-01', 'MWF 13:00-13:50'),
('1008', 'ENG-110', 108, 'HUM-101', '2026-SPRING', 'SEC-03', 'MWF 10:00-10:50'),
('1009', 'CIS-420', 103, 'KNL-202', '2026-FALL', 'SEC-01', 'TTH 13:00-14:15'),
('1010', 'ACCT-212', 112, 'BA-110', '2026-FALL', 'SEC-01', 'MWF 09:00-09:50'),
('1011', 'MATH-115', 114, 'KNL-101', '2026-SPRING', 'SEC-02', 'TTH 16:00-17:15'),
('1012', 'CIS-330', 118, 'KNL-202', '2026-SPRING', 'SEC-01', 'TTH 09:00-10:15'),
('1013', 'PHAR-101', 116, 'MED-101', '2026-SPRING', 'SEC-01', 'MWF 14:00-15:30'),
('1014', 'CLAW-201', 119, 'LAW-301', '2026-FALL', 'SEC-01', 'MWF 10:00-10:50'),
('1015', 'MATH-302', 120, 'KNL-101', '2026-SPRING', 'SEC-01', 'TTH 13:00-14:15'),
('1016', 'CIS-310', 113, 'KNL-202', '2026-SPRING', 'SEC-02', 'MWF 09:00-09:50'),
('1017', 'MGT-301', 111, 'BA-110', '2026-SPRING', 'SEC-02', 'MWF 08:00-08:50'),
('1018', 'MATH-115', 114, 'KNL-101', '2026-SPRING', 'SEC-03', 'MWF 13:00-13:50'),
('1019', 'BIOL-101', 115, 'SCI-301', '2026-SPRING', 'SEC-02', 'MWF 11:00-11:50'),
('1020', 'ENG-110', 108, 'HUM-101', '2026-SPRING', 'SEC-04', 'MWF 10:00-10:50');

INSERT INTO STUDENT (STU_NUM, DEPT_CODE, ADVISOR_PROF_NUM, STU_LNAME, STU_FNAME, STU_INITIAL, STU_EMAIL) VALUES
(321452, 'CIS', 103, 'Ortega', 'Ramon', 'G', 'rortega@tiny.edu'),
(324561, 'CIS', 103, 'Smith', 'John', 'B', 'jsmith@tiny.edu'),
(452312, 'ACCT', 102, 'Washington', 'Martha', 'A', 'mwashington@tiny.edu'),
(541256, 'MGT', 101, 'Jones', 'David', 'K', 'djones@tiny.edu'),
(621458, 'BIOL', 105, 'Boudreaux', 'Amy', 'E', 'aboudreaux@tiny.edu'),
(712453, 'CHEM', 106, 'Chen', 'Zack', 'Y', 'zchen@tiny.edu'),
(812456, 'MATH', 109, 'Taylor', 'Robert', 'S', 'rtaylor@tiny.edu'),
(912452, 'ENG', 108, 'Miller', 'Emily', 'M', 'emiller@tiny.edu'),
(112233, 'CIS', 104, 'Nguyen', 'An', 'V', 'an.nguyen@tiny.edu'),
(445566, 'ACCT', 112, 'Tran', 'Binh', 'M', 'binh.tran@tiny.edu'),
(778899, 'MGT', 111, 'Le', 'Chi', 'T', 'chi.le@tiny.edu'),
(990011, 'BIOL', 115, 'Pham', 'Dung', 'H', 'dung.pham@tiny.edu'),
(223344, 'CIS', 113, 'Hoang', 'Duc', 'A', 'duc.hoang@tiny.edu'),
(556677, 'MATH', 114, 'Vu', 'Hai', 'N', 'hai.vu@tiny.edu'),
(889900, 'CHEM', 107, 'Dinh', 'Huong', 'P', 'huong.dinh@tiny.edu'),
(112244, 'PHAR', 116, 'Ly', 'Thuong', 'K', 'thuong.ly@tiny.edu'),
(445577, 'NURS', 117, 'Phan', 'An', 'B', 'an.phan@tiny.edu'),
(778800, 'CLAW', 119, 'Vuong', 'Linh', 'P', 'linh.vuong@tiny.edu'),
(334455, 'CIS', 118, 'Dang', 'Minh', 'K', 'minh.dang@tiny.edu'),
(201001, 'CIS', NULL, 'Jackson', 'Michael', 'J', 'mjackson@tiny.edu'),
(201002, 'CIS', NULL, 'Brown', 'Chris', 'C', 'cbrown@tiny.edu'),
(202001, 'ACCT', NULL, 'Davis', 'Jennifer', 'L', 'jdavis@tiny.edu'),
(202002, 'ACCT', NULL, 'Wilson', 'Richard', 'R', 'rwilson@tiny.edu'),
(203001, 'MGT', NULL, 'Moore', 'Elizabeth', 'E', 'emoore@tiny.edu'),
(203002, 'MGT', NULL, 'Taylor', 'James', 'J', 'jtaylor@tiny.edu'),
(204001, 'BIOL', NULL, 'Anderson', 'Sarah', 'S', 'sanderson@tiny.edu'),
(204002, 'BIOL', NULL, 'Thomas', 'Daniel', 'D', 'dthomas@tiny.edu'),
(205001, 'CHEM', NULL, 'Jackson', 'Patricia', 'P', 'pjackson@tiny.edu'),
(205002, 'CHEM', NULL, 'White', 'Timothy', 'T', 'twhite@tiny.edu'),
(206001, 'ENG', NULL, 'Harris', 'Jessica', 'J', 'jharris@tiny.edu'),
(206002, 'ENG', NULL, 'Martin', 'Mark', 'M', 'mmartin@tiny.edu'),
(207001, 'MATH', NULL, 'Thompson', 'Lisa', 'L', 'lthompson@tiny.edu'),
(207002, 'MATH', NULL, 'Garcia', 'David', 'D', 'dgarcia@tiny.edu'),
(208001, 'CIED', NULL, 'Martinez', 'Sandra', 'S', 'smartinez@tiny.edu'),
(208002, 'CIED', NULL, 'Robinson', 'Paul', 'P', 'probinson@tiny.edu'),
(209001, 'PHAR', NULL, 'Clark', 'Nancy', 'N', 'nclark@tiny.edu'),
(209002, 'PHAR', NULL, 'Rodriguez', 'Kevin', 'K', 'krodriguez@tiny.edu'),
(210001, 'NURS', NULL, 'Lewis', 'Karen', 'K', 'klewis@tiny.edu'),
(210002, 'NURS', NULL, 'Lee', 'Steven', 'S', 'slee@tiny.edu'),
(211001, 'CLAW', NULL, 'Walker', 'Barbara', 'B', 'bwalker@tiny.edu'),
(211002, 'CLAW', NULL, 'Hall', 'Edward', 'E', 'ehall@tiny.edu');

INSERT INTO ENROLL (CLASS_CODE, STU_NUM, ENROLL_DATE, ENROLL_GRADE) VALUES
('1001', 321452, '2026-01-11', 'A'),
('1001', 324561, '2026-01-11', 'B+'),
('1001', 112233, '2026-01-12', 'B'),
('1001', 223344, '2026-01-12', 'C+'),
('1002', 321452, '2026-01-11', 'A'),
('1002', 223344, '2026-01-14', 'B'),
('1003', 452312, '2026-01-10', 'A'),
('1003', 445566, '2026-01-12', 'F'),
('1004', 541256, '2026-01-11', 'B'),
('1004', 778899, '2026-01-13', 'A'),
('1005', 621458, '2026-01-10', 'A'),
('1005', 990011, '2026-01-12', 'B+'),
('1006', 712453, '2026-01-11', 'C'),
('1006', 889900, '2026-01-15', 'A-'),
('1007', 812456, '2026-01-11', 'B'),
('1007', 556677, '2026-01-12', 'B+'),
('1008', 912452, '2026-01-10', 'A'),
('1011', 812456, '2026-01-11', 'A'),
('1011', 556677, '2026-01-12', 'B'),
('1012', 334455, '2026-01-12', 'A-'),
('1012', 321452, '2026-01-13', 'B+'),
('1013', 112244, '2026-01-10', 'A'),
('1013', 445577, '2026-01-11', 'B'),
('1015', 334455, '2026-01-14', 'A'),
('1007', 207001, '2026-01-11', 'A'),
('1011', 207001, '2026-01-11', 'A-'),
('1015', 207002, '2026-01-14', 'B+'),
('1007', 207002, '2026-01-11', 'B'),
('1013', 209002, '2026-01-10', 'A-'),
('1012', 209002, '2026-01-12', 'B+'),
('1013', 209001, '2026-01-10', 'B'),
('1006', 209001, '2026-01-11', 'A'),
('1008', 210001, '2026-01-10', 'A-'),
('1001', 210001, '2026-01-11', 'B+'),
('1002', 210002, '2026-01-11', 'A'),
('1004', 210002, '2026-01-11', 'B'),
('1001', 211001, '2026-01-11', 'B'),
('1003', 211001, '2026-01-10', 'A-'),
('1004', 211002, '2026-01-11', 'A'),
('1005', 211002, '2026-01-10', 'B+'),
('1006', 205001, '2026-01-11', 'A-'),
('1007', 205001, '2026-01-11', 'B'),
('1006', 205002, '2026-01-11', 'B+'),
('1001', 205002, '2026-01-11', 'A'),
('1008', 206001, '2026-01-10', 'A'),
('1002', 206001, '2026-01-11', 'B+'),
('1008', 206002, '2026-01-10', 'B'),
('1003', 206002, '2026-01-10', 'A-'),
('1001', 208001, '2026-01-11', 'B+'),
('1004', 208001, '2026-01-11', 'A-'),
('1003', 208002, '2026-01-10', 'A'),
('1005', 208002, '2026-01-10', 'B'),
('1005', 204001, '2026-01-10', 'A-'),
('1019', 204001, '2026-01-11', 'B+'),
('1005', 204002, '2026-01-10', 'B'),
('1001', 204002, '2026-01-11', 'A'),
('1001', 201001, '2026-01-11', 'A'),
('1002', 201001, '2026-01-11', 'B+'),
('1002', 201002, '2026-01-11', 'B'),
('1012', 201002, '2026-01-12', 'A-'),
('1003', 202001, '2026-01-10', 'A-'),
('1004', 202001, '2026-01-11', 'B+'),
('1003', 202002, '2026-01-10', 'B'),
('1011', 202002, '2026-01-11', 'A'),
('1004', 203001, '2026-01-11', 'A'),
('1017', 203001, '2026-01-11', 'B+'),
('1004', 203002, '2026-01-11', 'B-'),
('1001', 203002, '2026-01-11', 'C+');

-- 3. Create INDEXES

-- SCHOOL
CREATE INDEX IDX_SCHOOL_PROF
ON SCHOOL(PROF_NUM);

-- DEPARTMENT
CREATE INDEX IDX_DEPARTMENT_SCHOOL
ON DEPARTMENT(SCHOOL_CODE);

CREATE INDEX IDX_DEPARTMENT_DEAN
ON DEPARTMENT(DEAN_PROF_NUM);

-- PROFESSOR
CREATE INDEX IDX_PROFESSOR_DEPT
ON PROFESSOR(DEPT_CODE);

CREATE INDEX IDX_PROFESSOR_LNAME
ON PROFESSOR(PROF_LNAME);

CREATE INDEX IDX_PROFESSOR_RANK
ON PROFESSOR(PROF_RANK);

-- COURSE
CREATE INDEX IDX_COURSE_DEPT
ON COURSE(DEPT_CODE);

CREATE INDEX IDX_COURSE_TITLE
ON COURSE(CRS_TITLE);

CREATE INDEX IDX_COURSE_CREDIT_DEPT 
ON COURSE(CRS_CREDIT, DEPT_CODE);

-- ROOM
CREATE INDEX IDX_ROOM_BUILDING
ON ROOM(BLDG_CODE);

-- CLASS
CREATE INDEX IDX_CLASS_COURSE
ON CLASS(CRS_CODE);

CREATE INDEX IDX_CLASS_PROF
ON CLASS(PROF_NUM);

CREATE INDEX IDX_CLASS_ROOM
ON CLASS(ROOM_CODE);

CREATE INDEX IDX_CLASS_SEMESTER
ON CLASS(SEMESTER_CODE);

-- STUDENT
CREATE INDEX IDX_STUDENT_DEPT
ON STUDENT(DEPT_CODE);

CREATE INDEX IDX_STUDENT_ADVISOR
ON STUDENT(ADVISOR_PROF_NUM);

CREATE INDEX IDX_STUDENT_LNAME
ON STUDENT(STU_LNAME);

-- ENROLL
CREATE INDEX IDX_ENROLL_CLASS
ON ENROLL(CLASS_CODE);

CREATE INDEX IDX_ENROLL_STUDENT
ON ENROLL(STU_NUM);

CREATE INDEX IDX_ENROLL_GRADE
ON ENROLL(ENROLL_GRADE);

-- Truyvan - Views

-- 1. Liệt kê tất cả khoá học
SELECT `CRS_CODE`, `CRS_TITLE`, `CRS_CREDIT`, `DEPT_CODE`
FROM `COURSE`
ORDER BY `DEPT_CODE`, `CRS_CODE`;

-- 2. Liệt kê tất cả giáo sư và chuyên môn của họ
SELECT `PROF_EMAIL`,
       CONCAT(`PROF_FNAME`, ' ', `PROF_LNAME`) AS `PROFESSOR_NAME`,
       `PROF_SPECIALTY`,
       `PROF_RANK`
FROM `PROFESSOR`
ORDER BY `PROF_LNAME`, `PROF_FNAME`
limit 5;

-- 3. Liệt kê tất cả sinh viên theo phòng ban
SELECT `STU_NUM`,
       CONCAT(`STU_FNAME`, ' ', `STU_LNAME`) AS `STUDENT_NAME`,
       `DEPT_CODE`,
       `STU_EMAIL`
FROM `STUDENT`
ORDER BY `DEPT_CODE`, `STU_LNAME`;

-- 4. Hiển thị tất cả các lớp học trong kỳ Spring 2026
SELECT
    c.`CLASS_CODE`,
    c.`CRS_CODE`,
    c.`CLASS_SECTION`,
    c.`CLASS_TIME`,
    c.`ROOM_CODE`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS `PROFESSOR_NAME`
FROM `CLASS` c
LEFT JOIN `PROFESSOR` p ON c.`PROF_NUM` = p.`PROF_NUM`
WHERE c.`SEMESTER_CODE` = '2026-SPRING'
ORDER BY c.`CLASS_CODE`;


-- 5. Danh sách lớp học cùng với thông tin khóa học, giáo sư và phòng học
CREATE VIEW CLASS_INFO AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    c.`CLASS_SECTION`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS `PROFESSOR_NAME`,
    r.`ROOM_CODE`,
    b.`BLDG_NAME`,
    c.`CLASS_TIME`,
    c.`SEMESTER_CODE`
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
JOIN `PROFESSOR` p ON c.`PROF_NUM` = p.`PROF_NUM`
JOIN `ROOM` r ON c.`ROOM_CODE` = r.`ROOM_CODE`
JOIN `BUILDING` b ON r.`BLDG_CODE` = b.`BLDG_CODE`
ORDER BY c.`SEMESTER_CODE`, c.`CLASS_CODE`;

-- View:
SELECT * FROM `CLASS_INFO`;

-- 6. Sinh viên đã đăng ký lớp học và điểm của họ
CREATE VIEW REGISTERED_CLASS AS
SELECT
    e.`CLASS_CODE`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS `STUDENT_NAME`,
    crs.`CRS_TITLE`,
    e.`ENROLL_GRADE`,
    e.`ENROLL_DATE`
FROM `ENROLL` e
INNER JOIN `STUDENT` s ON e.`STU_NUM` = s.`STU_NUM`
INNER JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
INNER JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
ORDER BY e.`CLASS_CODE`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM REGISTERED_CLASS;

-- 7. Các khoá học được dạy bởi một giáo sư cụ thể
CREATE VIEW SPECIFIC_PROF_COURSE AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS `PROFESSOR_NAME`,
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    c.`CLASS_CODE`,
    c.`SEMESTER_CODE`
FROM `PROFESSOR` p
JOIN `CLASS` c ON p.`PROF_NUM` = c.`PROF_NUM`
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
ORDER BY c.`SEMESTER_CODE`;

-- VIEW:
SELECT * FROM `SPECIFIC_PROF_COURSE`;

-- 8. Đếm số sinh viên đăng ký từng lớp học
CREATE VIEW STUDENT_REGISTERED_CLASS AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    c.`CLASS_SECTION`,
    COUNT(e.`STU_NUM`) AS `STUDENT_COUNT`
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
LEFT JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`, c.`CLASS_SECTION`
ORDER BY `STUDENT_COUNT` DESC;

-- VIEW:
SELECT * FROM `STUDENT_REGISTERED_CLASS`;

-- 9. Danh sách sinh viên cùng với tên cố vấn của họ
CREATE VIEW STUDENT_ADVISOR AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS `STUDENT_NAME`,
    d.`DEPT_NAME`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS `PROFESSOR_NAME`,
    p.`PROF_EMAIL`
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
LEFT JOIN `PROFESSOR` p ON s.`ADVISOR_PROF_NUM` = p.`PROF_NUM`
ORDER BY d.`DEPT_NAME`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM `STUDENT_ADVISOR`;

-- 10. Sinh viên điểm cao nhất trong từng lớp
CREATE VIEW STUDENT_HIGHEST_GRADE AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    GROUP_CONCAT(CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) SEPARATOR ', ') AS TOP_STUDENTS,
    e.`ENROLL_GRADE`
FROM `ENROLL` e
JOIN `STUDENT` s ON e.`STU_NUM` = s.`STU_NUM`
JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
WHERE e.`ENROLL_GRADE` = (
    SELECT e2.`ENROLL_GRADE`
    FROM `ENROLL` e2
    WHERE e2.`CLASS_CODE` = e.`CLASS_CODE`
    ORDER BY 
        CASE 
            WHEN e2.`ENROLL_GRADE` = 'A' THEN 4.0
            WHEN e2.`ENROLL_GRADE` = 'A-' THEN 3.7
            WHEN e2.`ENROLL_GRADE` = 'B+' THEN 3.3
            WHEN e2.`ENROLL_GRADE` = 'B' THEN 3.0
            WHEN e2.`ENROLL_GRADE` = 'B-' THEN 2.7
            WHEN e2.`ENROLL_GRADE` = 'C+' THEN 2.3
            WHEN e2.`ENROLL_GRADE` = 'C' THEN 2.0
            WHEN e2.`ENROLL_GRADE` = 'C-' THEN 1.7
            WHEN e2.`ENROLL_GRADE` = 'D+' THEN 1.3
            WHEN e2.`ENROLL_GRADE` = 'D' THEN 1.0
            WHEN e2.`ENROLL_GRADE` = 'F' THEN 0.0
        END DESC
    LIMIT 1
)
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`, e.`ENROLL_GRADE`
ORDER BY c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `STUDENT_HIGHEST_GRADE`;

-- 11. Giáo sư dạy nhiều lớp nhất
CREATE VIEW PROF_MOST_CLASS AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    p.`PROF_SPECIALTY`,
    count(DISTINCT c.`CLASS_CODE`) AS NUM_CLASSES
FROM `PROFESSOR` p
JOIN `CLASS` c ON p.`PROF_NUM` = c.`PROF_NUM`
WHERE c.`CLASS_CODE` IS NOT NULL
GROUP BY p.`PROF_NUM`, p.`PROF_FNAME`, p.`PROF_LNAME`, p.`PROF_SPECIALTY`
HAVING COUNT(DISTINCT c.`CLASS_CODE`) > 0
ORDER BY NUM_CLASSES DESC, p.`PROF_LNAME`
LIMIT 1;

-- VIEW:
SELECT * FROM `PROF_MOST_CLASS`;

-- 12. Sinh viên chưa có cố vấn
CREATE VIEW STUDENT_WITHOUT_ADVISOR AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`,
    s.`STU_EMAIL`
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
WHERE s.`ADVISOR_PROF_NUM` IS NULL
ORDER BY d.`DEPT_NAME`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM `STUDENT_WITHOUT_ADVISOR`;

-- 13. Thống kê sinh viên có ít nhất một điểm A hoặc A- và tỷ lệ điểm A/A- trong các lớp đã tham gia
CREATE VIEW STUDENT_A_GRADE_PERFORMANCE AS
SELECT
    s.STU_NUM,
    CONCAT(s.STU_FNAME, ' ', s.STU_LNAME) AS STUDENT_NAME,
    d.DEPT_NAME,
    COUNT(e.CLASS_CODE) AS TOTAL_CLASSES,
    SUM(CASE WHEN e.ENROLL_GRADE IN ('A', 'A-') THEN 1 ELSE 0 END) AS A_CLASSES,
    ROUND(
        SUM(CASE WHEN e.ENROLL_GRADE IN ('A', 'A-') THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(e.CLASS_CODE), 0),
        2
    ) AS PERCENTAGE_A
FROM STUDENT s
JOIN DEPARTMENT d ON s.DEPT_CODE = d.DEPT_CODE
JOIN ENROLL e ON s.STU_NUM = e.STU_NUM
WHERE e.ENROLL_GRADE IS NOT NULL
GROUP BY
    s.STU_NUM,
    s.STU_FNAME,
    s.STU_LNAME,
    d.DEPT_NAME
HAVING A_CLASSES > 0
ORDER BY PERCENTAGE_A DESC, A_CLASSES DESC;
-- VIEW:
SELECT * FROM `STUDENT_A_GRADE_PERFORMANCE`;


-- 14. Tìm lớp có tỉ lệ sinh viên đạt dưới C cao nhất
CREATE VIEW CLASS_STUDENT_BELOW_C AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    COUNT(e.`STU_NUM`) AS TOTAL_STUDENTS,
    SUM(CASE WHEN e.`ENROLL_GRADE` IN ('C', 'C-', 'D+', 'D', 'F') THEN 1 ELSE 0 END) AS BELOW_GRADE_COUNT,
    ROUND(
        SUM(CASE WHEN e.`ENROLL_GRADE` IN ('C', 'C-', 'D+', 'D', 'F') THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(e.`STU_NUM`), 0),
        2
    ) AS PERCENTAGE_BELOW_C
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
JOIN `PROFESSOR` p ON c.`PROF_NUM` = p.`PROF_NUM`
JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
WHERE e.`ENROLL_GRADE` IS NOT NULL
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`,
         p.`PROF_NUM`, p.`PROF_FNAME`, p.`PROF_LNAME`
ORDER BY PERCENTAGE_BELOW_C DESC;

-- VIEW:
SELECT * FROM `CLASS_STUDENT_BELOW_C`;

-- 15. Tìm phòng học bị trùng lịch (2 lớp học cùng thời gian)
CREATE VIEW CLASS_DUPLICATED AS
SELECT
    c1.`ROOM_CODE`,
    c1.`CLASS_CODE` AS CLASS_1,
    c2.`CLASS_CODE` AS CLASS_2,
    crs1.`CRS_TITLE` AS COURSE_1,
    crs2.`CRS_TITLE` AS COURSE_2,
    c1.`CLASS_TIME`,
    c1.`SEMESTER_CODE`
FROM `CLASS` c1
JOIN `CLASS` c2 ON c1.`ROOM_CODE` = c2.`ROOM_CODE`
AND c1.`CLASS_TIME` = c2.`CLASS_TIME`
AND c1.`SEMESTER_CODE` = c2.`SEMESTER_CODE`
AND c1.`CLASS_CODE` < c2.`CLASS_CODE`
JOIN `COURSE` crs1 ON c1.`CRS_CODE` = crs1.`CRS_CODE`
JOIN `COURSE` crs2 ON c2.`CRS_CODE` = crs2.`CRS_CODE`
ORDER BY c1.`ROOM_CODE`, c1.`CLASS_TIME`;

-- VIEW:
SELECT * FROM `CLASS_DUPLICATED`;

-- 16. Tìm sinh viên đạt số đơn vị tín chỉ cao nhất
CREATE VIEW STUDENT_TOTAL_CREDIT AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`,
    SUM(crs.`CRS_CREDIT`) AS TOTAL_CREDIT,
    MAX(SUM(crs.`CRS_CREDIT`)) OVER () AS MAX_TOTAL_CREDIT
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
WHERE e.`ENROLL_GRADE` IS NOT NULL
GROUP BY s.`STU_NUM`, s.`STU_FNAME`, s.`STU_LNAME`, d.`DEPT_NAME`
ORDER BY TOTAL_CREDIT DESC;

-- VIEW:
SELECT * FROM `STUDENT_TOTAL_CREDIT`;

-- 17. Liệt kê tất cả các lớp học không có sinh viên
CREATE VIEW EMPTY_CLASS AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    c.`SEMESTER_CODE`,
    c.`CLASS_SECTION`
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
LEFT JOIN `PROFESSOR` p ON c.`PROF_NUM` = p.`PROF_NUM`
WHERE c.`CLASS_CODE` NOT IN (
    SELECT DISTINCT `CLASS_CODE`
    FROM `ENROLL`
)
ORDER BY c.`SEMESTER_CODE`, c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `EMPTY_CLASS`;

-- 18. Tìm các phòng học được sử dụng nhiều nhất
CREATE VIEW ROOM_USAGE_STATS AS
SELECT
    r.`ROOM_CODE`,
    b.`BLDG_NAME`,
    COUNT(DISTINCT c.`CLASS_CODE`) AS NUM_CLASSES,
    COUNT(DISTINCT c.`SEMESTER_CODE`) AS NUM_SEMESTERS
FROM `ROOM` r
LEFT JOIN `BUILDING` b ON r.`BLDG_CODE` = b.`BLDG_CODE`
LEFT JOIN `CLASS` c ON r.`ROOM_CODE` = c.`ROOM_CODE`
GROUP BY r.`ROOM_CODE`, b.`BLDG_CODE`, b.`BLDG_NAME`
ORDER BY NUM_CLASSES DESC, r.`ROOM_CODE`;

-- VIEW:
SELECT * FROM `ROOM_USAGE_STATS`;

-- 19. Tìm các phòng học có thể được tối ưu hoá (ít được sử dụng)
CREATE VIEW UNDERUTILIZED_ROOMS AS
SELECT
    r.`ROOM_CODE`,
    b.`BLDG_NAME`,
    r.`ROOM_TYPE`,
    COUNT(DISTINCT c.`CLASS_CODE`) AS NUM_CLASSES
FROM `ROOM` r
LEFT JOIN `BUILDING` b ON r.`BLDG_CODE` = b.`BLDG_CODE`
LEFT JOIN `CLASS` c ON r.`ROOM_CODE` = c.`ROOM_CODE`
GROUP BY r.`ROOM_CODE`, b.`BLDG_NAME`, r.`ROOM_TYPE`
HAVING COUNT(DISTINCT c.`CLASS_CODE`) BETWEEN 1 AND 2
ORDER BY NUM_CLASSES ASC;

-- VIEW:
SELECT * FROM `UNDERUTILIZED_ROOMS`;

-- 20. Tính điểm trung bình của mỗi sinh viên
CREATE VIEW STUDENT_GPA AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`,
    ROUND(AVG(
        CASE
            WHEN e.`ENROLL_GRADE` = 'A' THEN 4.0
            WHEN e.`ENROLL_GRADE` = 'A-' THEN 3.7
            WHEN e.`ENROLL_GRADE` = 'B+' THEN 3.3
            WHEN e.`ENROLL_GRADE` = 'B' THEN 3.0
            WHEN e.`ENROLL_GRADE` = 'B-' THEN 2.7
            WHEN e.`ENROLL_GRADE` = 'C+' THEN 2.3
            WHEN e.`ENROLL_GRADE` = 'C' THEN 2.0
            WHEN e.`ENROLL_GRADE` = 'C-' THEN 1.7
            WHEN e.`ENROLL_GRADE` = 'D+' THEN 1.3
            WHEN e.`ENROLL_GRADE` = 'D' THEN 1.0
            WHEN e.`ENROLL_GRADE` = 'F' THEN 0.0
            ELSE NULL
        END
    ), 2) AS GPA
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
LEFT JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
GROUP BY s.`STU_NUM`, s.`STU_FNAME`, s.`STU_LNAME`, d.`DEPT_NAME`
ORDER BY GPA DESC;

-- VIEW:
SELECT * FROM `STUDENT_GPA`;

-- 21. Tìm sinh viên có điểm trung bình trên 3.5 (Giỏi)
CREATE VIEW EXCELLENT_STUDENT_GPA AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`,
    ROUND(AVG(
        CASE
            WHEN e.`ENROLL_GRADE` = 'A' THEN 4.0
            WHEN e.`ENROLL_GRADE` = 'A-' THEN 3.7
            WHEN e.`ENROLL_GRADE` = 'B+' THEN 3.3
            WHEN e.`ENROLL_GRADE` = 'B' THEN 3.0
            WHEN e.`ENROLL_GRADE` = 'B-' THEN 2.7
            WHEN e.`ENROLL_GRADE` = 'C+' THEN 2.3
            WHEN e.`ENROLL_GRADE` = 'C' THEN 2.0
            WHEN e.`ENROLL_GRADE` = 'C-' THEN 1.7
            WHEN e.`ENROLL_GRADE` = 'D+' THEN 1.3
            WHEN e.`ENROLL_GRADE` = 'D' THEN 1.0
            WHEN e.`ENROLL_GRADE` = 'F' THEN 0.0
            ELSE NULL
        END
    ), 2) AS GPA
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
LEFT JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
GROUP BY s.`STU_NUM`, s.`STU_FNAME`, s.`STU_LNAME`, d.`DEPT_NAME`
HAVING GPA >= 3.5
ORDER BY GPA DESC;

-- VIEW:
SELECT * FROM `EXCELLENT_STUDENT_GPA`;

-- 22. Tìm các khoá học không được dạy trong kì SPRING
CREATE VIEW INACTIVE_COURSES AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    d.`DEPT_NAME`,
    crs.`CRS_CREDIT`
FROM `COURSE` crs
JOIN `DEPARTMENT` d ON crs.`DEPT_CODE` = d.`DEPT_CODE`
WHERE crs.`CRS_CODE` NOT IN (
    SELECT DISTINCT c.`CRS_CODE`
    FROM `CLASS` c
    WHERE c.`SEMESTER_CODE` = '2026-SPRING'
)
ORDER BY d.`DEPT_NAME`, crs.`CRS_CODE`;

-- VIEW:
SELECT * FROM `INACTIVE_COURSES`;

-- 23. liệt kê giáo sư theo chuyên môn và xếp loại của họ
CREATE VIEW PROFESSOR_RANK_SPECIALTY AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    p.`PROF_SPECIALTY`,
    p.`PROF_RANK`,
    d.`DEPT_NAME`,
    COUNT(DISTINCT c.`CLASS_CODE`) AS NUM_CLASSES_TAUGHT
FROM `PROFESSOR` p
JOIN `DEPARTMENT` d ON p.`DEPT_CODE` = d.`DEPT_CODE`
LEFT JOIN `CLASS` c ON p.`PROF_NUM` = c.`PROF_NUM`
GROUP BY p.`PROF_NUM`, p.`PROF_FNAME`, p.`PROF_LNAME`, p.`PROF_SPECIALTY`, p.`PROF_RANK`, d.`DEPT_NAME`
ORDER BY p.`PROF_RANK`, d.`DEPT_NAME`, p.`PROF_LNAME`;

-- VIEW:
SELECT * FROM `PROFESSOR_RANK_SPECIALTY`;

-- 24. Tìm sinh viên dưới điểm trung bình của lớp
CREATE VIEW BELOW_CLASS_AVERAGE AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    e.`ENROLL_GRADE`,
    CASE 
        WHEN e.`ENROLL_GRADE` = 'A' THEN 4.0
        WHEN e.`ENROLL_GRADE` = 'A-' THEN 3.7
        WHEN e.`ENROLL_GRADE` = 'B+' THEN 3.3
        WHEN e.`ENROLL_GRADE` = 'B' THEN 3.0
        WHEN e.`ENROLL_GRADE` = 'B-' THEN 2.7
        WHEN e.`ENROLL_GRADE` = 'C+' THEN 2.3
        WHEN e.`ENROLL_GRADE` = 'C' THEN 2.0
        WHEN e.`ENROLL_GRADE` = 'C-' THEN 1.7
        WHEN e.`ENROLL_GRADE` = 'D+' THEN 1.3
        WHEN e.`ENROLL_GRADE` = 'D' THEN 1.0
        WHEN e.`ENROLL_GRADE` = 'F' THEN 0.0
    END AS STUDENT_GPA,
    ROUND((SELECT AVG(
        CASE 
            WHEN e2.`ENROLL_GRADE` = 'A' THEN 4.0
            WHEN e2.`ENROLL_GRADE` = 'A-' THEN 3.7
            WHEN e2.`ENROLL_GRADE` = 'B+' THEN 3.3
            WHEN e2.`ENROLL_GRADE` = 'B' THEN 3.0
            WHEN e2.`ENROLL_GRADE` = 'B-' THEN 2.7
            WHEN e2.`ENROLL_GRADE` = 'C+' THEN 2.3
            WHEN e2.`ENROLL_GRADE` = 'C' THEN 2.0
            WHEN e2.`ENROLL_GRADE` = 'C-' THEN 1.7
            WHEN e2.`ENROLL_GRADE` = 'D+' THEN 1.3
            WHEN e2.`ENROLL_GRADE` = 'D' THEN 1.0
            WHEN e2.`ENROLL_GRADE` = 'F' THEN 0.0
        END)
    FROM `ENROLL` e2
    WHERE e2.`CLASS_CODE` = c.`CLASS_CODE`), 2) AS CLASS_AVERAGE
FROM `STUDENT` s
JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
WHERE e.`ENROLL_GRADE` IS NOT NULL
HAVING STUDENT_GPA < CLASS_AVERAGE
ORDER BY c.`CLASS_CODE`, STUDENT_GPA ASC;

-- VIEW:
SELECT * FROM `BELOW_CLASS_AVERAGE`;

-- 25. Tìm khóa học có lịch giao được cân bằng nhất
CREATE VIEW BALANCED_COURSE_SCHEDULE AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    COUNT(DISTINCT c.`CLASS_CODE`) AS NUM_SECTIONS,
    COUNT(DISTINCT c.`SEMESTER_CODE`) AS NUM_SEMESTERS,
    COUNT(DISTINCT c.`PROF_NUM`) AS NUM_PROFESSORS,
    COUNT(DISTINCT c.`ROOM_CODE`) AS NUM_ROOMS
FROM `COURSE` crs
LEFT JOIN `CLASS` c ON crs.`CRS_CODE` = c.`CRS_CODE`
GROUP BY crs.`CRS_CODE`, crs.`CRS_TITLE`
ORDER BY NUM_SECTIONS DESC;

-- VIEW:
SELECT * FROM `BALANCED_COURSE_SCHEDULE`;

-- 26. Liệt kê các trường và số khoa trực thuộc
CREATE VIEW SCHOOL_DEPARTMENT_COUNT AS
SELECT
    sch.`SCHOOL_CODE`,
    sch.`SCHOOL_NAME`,
    COUNT(d.`DEPT_CODE`) AS DEPARTMENT_COUNT
FROM `SCHOOL` sch
LEFT JOIN `DEPARTMENT` d ON sch.`SCHOOL_CODE` = d.`SCHOOL_CODE`
GROUP BY sch.`SCHOOL_CODE`, sch.`SCHOOL_NAME`
ORDER BY DEPARTMENT_COUNT DESC, sch.`SCHOOL_NAME`;

-- VIEW:
SELECT * FROM `SCHOOL_DEPARTMENT_COUNT`;

-- 27. Liệt kê khoa cùng tên trường quản lý
CREATE VIEW DEPARTMENT_SCHOOL_INFO AS
SELECT
    d.`DEPT_CODE`,
    d.`DEPT_NAME`,
    sch.`SCHOOL_NAME`
FROM `DEPARTMENT` d
JOIN `SCHOOL` sch ON d.`SCHOOL_CODE` = sch.`SCHOOL_CODE`
ORDER BY sch.`SCHOOL_NAME`, d.`DEPT_NAME`;

-- VIEW:
SELECT * FROM `DEPARTMENT_SCHOOL_INFO`;

-- 28. Liệt kê các giáo sư thuộc khoa CIS
CREATE VIEW CIS_PROFESSORS AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    p.`PROF_SPECIALTY`,
    p.`PROF_RANK`,
    p.`PROF_EMAIL`
FROM `PROFESSOR` p
WHERE p.`DEPT_CODE` = 'CIS'
ORDER BY p.`PROF_LNAME`, p.`PROF_FNAME`;

-- VIEW:
SELECT * FROM `CIS_PROFESSORS`;

-- 29. Liệt kê các khóa học có 4 tín chỉ
CREATE VIEW FOUR_CREDIT_COURSES AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    crs.`CRS_CREDIT`,
    d.`DEPT_NAME`
FROM `COURSE` crs
JOIN `DEPARTMENT` d ON crs.`DEPT_CODE` = d.`DEPT_CODE`
WHERE crs.`CRS_CREDIT` = 4
ORDER BY d.`DEPT_NAME`, crs.`CRS_TITLE`;

-- VIEW:
SELECT * FROM `FOUR_CREDIT_COURSES`;

-- 30. Liệt kê sinh viên có email thuộc tiny.edu
CREATE VIEW STUDENT_TINY_EMAIL AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    s.`DEPT_CODE`,
    s.`STU_EMAIL`
FROM `STUDENT` s
WHERE s.`STU_EMAIL` LIKE '%@tiny.edu'
ORDER BY s.`STU_LNAME`, s.`STU_FNAME`;

-- VIEW:
SELECT * FROM `STUDENT_TINY_EMAIL`;

-- 31. Liệt kê lớp học kèm tên học kỳ
CREATE VIEW CLASS_SEMESTER_INFO AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    c.`CLASS_SECTION`,
    sem.`SEMESTER_TERM`,
    sem.`SEMESTER_YEAR`,
    c.`CLASS_TIME`
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
JOIN `SEMESTER` sem ON c.`SEMESTER_CODE` = sem.`SEMESTER_CODE`
ORDER BY sem.`SEMESTER_YEAR`, sem.`SEMESTER_TERM`, c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `CLASS_SEMESTER_INFO`;

-- 32. Đếm số giáo sư theo từng học hàm
CREATE VIEW PROFESSOR_COUNT_BY_RANK AS
SELECT
    p.`PROF_RANK`,
    COUNT(*) AS PROFESSOR_COUNT
FROM `PROFESSOR` p
GROUP BY p.`PROF_RANK`
ORDER BY PROFESSOR_COUNT DESC, p.`PROF_RANK`;

-- VIEW:
SELECT * FROM `PROFESSOR_COUNT_BY_RANK`;

-- 33. Đếm số sinh viên theo từng khoa
CREATE VIEW STUDENT_COUNT_BY_DEPARTMENT AS
SELECT
    d.`DEPT_CODE`,
    d.`DEPT_NAME`,
    COUNT(s.`STU_NUM`) AS STUDENT_COUNT
FROM `DEPARTMENT` d
LEFT JOIN `STUDENT` s ON d.`DEPT_CODE` = s.`DEPT_CODE`
GROUP BY d.`DEPT_CODE`, d.`DEPT_NAME`
ORDER BY STUDENT_COUNT DESC, d.`DEPT_NAME`;

-- VIEW:
SELECT * FROM `STUDENT_COUNT_BY_DEPARTMENT`;

-- 34. Liệt kê phòng học cùng tên tòa nhà
CREATE VIEW ROOM_BUILDING_INFO AS
SELECT
    r.`ROOM_CODE`,
    r.`ROOM_TYPE`,
    b.`BLDG_NAME`,
    b.`BLDG_LOCATION`
FROM `ROOM` r
JOIN `BUILDING` b ON r.`BLDG_CODE` = b.`BLDG_CODE`
ORDER BY b.`BLDG_NAME`, r.`ROOM_CODE`;

-- VIEW:
SELECT * FROM `ROOM_BUILDING_INFO`;

-- 35. Liệt kê sinh viên đã đăng ký ít nhất một lớp
CREATE VIEW STUDENT_WITH_ENROLLMENT AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
WHERE EXISTS (
    SELECT 1
    FROM `ENROLL` e
    WHERE e.`STU_NUM` = s.`STU_NUM`
)
ORDER BY d.`DEPT_NAME`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM `STUDENT_WITH_ENROLLMENT`;

-- 36. Liệt kê sinh viên chưa đăng ký lớp nào
CREATE VIEW STUDENT_WITHOUT_ENROLLMENT AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    d.`DEPT_NAME`,
    s.`STU_EMAIL`
FROM `STUDENT` s
JOIN `DEPARTMENT` d ON s.`DEPT_CODE` = d.`DEPT_CODE`
WHERE s.`STU_NUM` NOT IN (
    SELECT e.`STU_NUM`
    FROM `ENROLL` e
)
ORDER BY d.`DEPT_NAME`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM `STUDENT_WITHOUT_ENROLLMENT`;

-- 37. Liệt kê khóa học có số tín chỉ cao hơn trung bình
CREATE VIEW COURSE_ABOVE_AVG_CREDIT AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    crs.`CRS_CREDIT`,
    d.`DEPT_NAME`
FROM `COURSE` crs
JOIN `DEPARTMENT` d ON crs.`DEPT_CODE` = d.`DEPT_CODE`
WHERE crs.`CRS_CREDIT` > (
    SELECT AVG(`CRS_CREDIT`)
    FROM `COURSE`
)
ORDER BY crs.`CRS_CREDIT` DESC, crs.`CRS_TITLE`;

-- VIEW:
SELECT * FROM `COURSE_ABOVE_AVG_CREDIT`;

-- 38. Liệt kê khoa có nhiều sinh viên hơn mức trung bình của các khoa
CREATE VIEW DEPARTMENT_ABOVE_AVG_STUDENT_COUNT AS
SELECT
    d.`DEPT_CODE`,
    d.`DEPT_NAME`,
    COUNT(s.`STU_NUM`) AS STUDENT_COUNT
FROM `DEPARTMENT` d
LEFT JOIN `STUDENT` s ON d.`DEPT_CODE` = s.`DEPT_CODE`
GROUP BY d.`DEPT_CODE`, d.`DEPT_NAME`
HAVING COUNT(s.`STU_NUM`) > (
    SELECT AVG(DEPT_STUDENT_COUNT)
    FROM (
        SELECT COUNT(s2.`STU_NUM`) AS DEPT_STUDENT_COUNT
        FROM `DEPARTMENT` d2
        LEFT JOIN `STUDENT` s2 ON d2.`DEPT_CODE` = s2.`DEPT_CODE`
        GROUP BY d2.`DEPT_CODE`
    ) dept_counts
)
ORDER BY STUDENT_COUNT DESC;

-- VIEW:
SELECT * FROM `DEPARTMENT_ABOVE_AVG_STUDENT_COUNT`;

-- 39. Liệt kê giáo sư chưa từng dạy lớp nào
CREATE VIEW PROFESSOR_WITHOUT_CLASS AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    d.`DEPT_NAME`,
    p.`PROF_RANK`
FROM `PROFESSOR` p
JOIN `DEPARTMENT` d ON p.`DEPT_CODE` = d.`DEPT_CODE`
WHERE p.`PROF_NUM` NOT IN (
    SELECT DISTINCT c.`PROF_NUM`
    FROM `CLASS` c
    WHERE c.`PROF_NUM` IS NOT NULL
)
ORDER BY d.`DEPT_NAME`, p.`PROF_LNAME`;

-- VIEW:
SELECT * FROM `PROFESSOR_WITHOUT_CLASS`;

-- 40. Liệt kê khóa học chưa có lớp mở
CREATE VIEW COURSE_WITHOUT_CLASS AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    d.`DEPT_NAME`,
    crs.`CRS_CREDIT`
FROM `COURSE` crs
JOIN `DEPARTMENT` d ON crs.`DEPT_CODE` = d.`DEPT_CODE`
WHERE NOT EXISTS (
    SELECT 1
    FROM `CLASS` c
    WHERE c.`CRS_CODE` = crs.`CRS_CODE`
)
ORDER BY d.`DEPT_NAME`, crs.`CRS_TITLE`;

-- VIEW:
SELECT * FROM `COURSE_WITHOUT_CLASS`;

-- 41. Liệt kê các lớp có số sinh viên đăng ký từ 3 trở lên
CREATE VIEW CLASS_WITH_AT_LEAST_THREE_STUDENTS AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    c.`CLASS_SECTION`,
    COUNT(e.`STU_NUM`) AS STUDENT_COUNT
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
LEFT JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`, c.`CLASS_SECTION`
HAVING COUNT(e.`STU_NUM`) >= 3
ORDER BY STUDENT_COUNT DESC, c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `CLASS_WITH_AT_LEAST_THREE_STUDENTS`;

-- 42. Liệt kê giáo sư đang làm cố vấn cho nhiều hơn 1 sinh viên
CREATE VIEW PROFESSOR_ADVISES_MULTIPLE_STUDENTS AS
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    p.`DEPT_CODE`,
    COUNT(s.`STU_NUM`) AS ADVISEE_COUNT
FROM `PROFESSOR` p
JOIN `STUDENT` s ON p.`PROF_NUM` = s.`ADVISOR_PROF_NUM`
GROUP BY p.`PROF_NUM`, p.`PROF_FNAME`, p.`PROF_LNAME`, p.`DEPT_CODE`
HAVING COUNT(s.`STU_NUM`) > 1
ORDER BY ADVISEE_COUNT DESC, PROFESSOR_NAME;

-- VIEW:
SELECT * FROM `PROFESSOR_ADVISES_MULTIPLE_STUDENTS`;

-- 43. Liệt kê lớp có điểm A hoặc A- nhiều nhất
CREATE VIEW CLASS_HIGH_GRADE_COUNT AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    COUNT(e.`STU_NUM`) AS HIGH_GRADE_COUNT
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
WHERE e.`ENROLL_GRADE` IN ('A', 'A-')
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`
ORDER BY HIGH_GRADE_COUNT DESC, c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `CLASS_HIGH_GRADE_COUNT`;

-- 44. Liệt kê sinh viên học trong các lớp của khoa CIS
CREATE VIEW STUDENTS_IN_CIS_CLASSES AS
SELECT DISTINCT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    s.`DEPT_CODE`
FROM `STUDENT` s
JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
WHERE c.`CRS_CODE` IN (
    SELECT crs.`CRS_CODE`
    FROM `COURSE` crs
    WHERE crs.`DEPT_CODE` = 'CIS'
)
ORDER BY s.`DEPT_CODE`, s.`STU_LNAME`;

-- VIEW:
SELECT * FROM `STUDENTS_IN_CIS_CLASSES`;

-- 45. Liệt kê các phòng đang được dùng trong kỳ Spring 2026
CREATE VIEW ROOMS_USED_IN_SPRING_2026 AS
SELECT DISTINCT
    r.`ROOM_CODE`,
    r.`ROOM_TYPE`,
    b.`BLDG_NAME`
FROM `ROOM` r
JOIN `BUILDING` b ON r.`BLDG_CODE` = b.`BLDG_CODE`
JOIN `CLASS` c ON r.`ROOM_CODE` = c.`ROOM_CODE`
WHERE c.`SEMESTER_CODE` = '2026-SPRING'
ORDER BY b.`BLDG_NAME`, r.`ROOM_CODE`;

-- VIEW:
SELECT * FROM `ROOMS_USED_IN_SPRING_2026`;

-- 46. Liệt kê sinh viên có số lớp đăng ký nhiều hơn 1
CREATE VIEW STUDENT_MORE_THAN_ONE_CLASS AS
SELECT
    s.`STU_NUM`,
    CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
    (
        SELECT COUNT(*)
        FROM `ENROLL` e
        WHERE e.`STU_NUM` = s.`STU_NUM`
    ) AS CLASS_COUNT
FROM `STUDENT` s
WHERE (
    SELECT COUNT(*)
    FROM `ENROLL` e
    WHERE e.`STU_NUM` = s.`STU_NUM`
) > 1
ORDER BY CLASS_COUNT DESC, STUDENT_NAME;

-- VIEW:
SELECT * FROM `STUDENT_MORE_THAN_ONE_CLASS`;

-- 47. Liệt kê khóa học có lớp ở nhiều hơn một phòng
CREATE VIEW COURSE_IN_MULTIPLE_ROOMS AS
SELECT
    crs.`CRS_CODE`,
    crs.`CRS_TITLE`,
    COUNT(DISTINCT c.`ROOM_CODE`) AS ROOM_COUNT
FROM `COURSE` crs
JOIN `CLASS` c ON crs.`CRS_CODE` = c.`CRS_CODE`
GROUP BY crs.`CRS_CODE`, crs.`CRS_TITLE`
HAVING COUNT(DISTINCT c.`ROOM_CODE`) > 1
ORDER BY ROOM_COUNT DESC, crs.`CRS_CODE`;

-- VIEW:
SELECT * FROM `COURSE_IN_MULTIPLE_ROOMS`;

-- 48. Liệt kê các khoa có ít nhất một giáo sư cấp Prof
CREATE VIEW DEPARTMENT_WITH_FULL_PROF AS
SELECT
    d.`DEPT_CODE`,
    d.`DEPT_NAME`,
    sch.`SCHOOL_NAME`
FROM `DEPARTMENT` d
JOIN `SCHOOL` sch ON d.`SCHOOL_CODE` = sch.`SCHOOL_CODE`
WHERE d.`DEPT_CODE` IN (
    SELECT p.`DEPT_CODE`
    FROM `PROFESSOR` p
    WHERE p.`PROF_RANK` = 'Prof'
)
ORDER BY sch.`SCHOOL_NAME`, d.`DEPT_NAME`;

-- VIEW:
SELECT * FROM `DEPARTMENT_WITH_FULL_PROF`;

-- 49. Liệt kê lớp có ngày đăng ký sớm nhất
CREATE VIEW CLASS_EARLIEST_ENROLL_DATE AS
SELECT
    c.`CLASS_CODE`,
    crs.`CRS_TITLE`,
    MIN(e.`ENROLL_DATE`) AS EARLIEST_ENROLL_DATE
FROM `CLASS` c
JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`
ORDER BY EARLIEST_ENROLL_DATE, c.`CLASS_CODE`;

-- VIEW:
SELECT * FROM `CLASS_EARLIEST_ENROLL_DATE`;

-- 50. Tìm giáo sư có số lượng sinh viên cố vấn cao hơn mức trung bình
CREATE VIEW PROFESSOR_ABOVE_AVERAGE_ADVISEES AS
WITH ADVISEE_COUNT AS (
    SELECT
        s.`ADVISOR_PROF_NUM`,
        COUNT(*) AS TOTAL_ADVISEES
    FROM `STUDENT` s
    WHERE s.`ADVISOR_PROF_NUM` IS NOT NULL
    GROUP BY s.`ADVISOR_PROF_NUM`
)
SELECT
    p.`PROF_NUM`,
    CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
    d.`DEPT_NAME`,
    ac.`TOTAL_ADVISEES`
FROM ADVISEE_COUNT ac
JOIN `PROFESSOR` p ON ac.`ADVISOR_PROF_NUM` = p.`PROF_NUM`
JOIN `DEPARTMENT` d ON p.`DEPT_CODE` = d.`DEPT_CODE`
WHERE ac.`TOTAL_ADVISEES` >
      (SELECT AVG(TOTAL_ADVISEES)
       FROM ADVISEE_COUNT)
ORDER BY ac.`TOTAL_ADVISEES` DESC;

-- VIEW:
SELECT * FROM `PROFESSOR_ABOVE_AVERAGE_ADVISEES`;

-- 51. CTE: Tính số lớp của từng giáo sư
CREATE VIEW CTE_PROFESSOR_CLASS_COUNT AS
WITH PROFESSOR_CLASSES AS (
    SELECT
        p.`PROF_NUM`,
        CONCAT(p.`PROF_FNAME`, ' ', p.`PROF_LNAME`) AS PROFESSOR_NAME,
        COUNT(c.`CLASS_CODE`) AS CLASS_COUNT
    FROM `PROFESSOR` p
    LEFT JOIN `CLASS` c ON p.`PROF_NUM` = c.`PROF_NUM`
    GROUP BY p.`PROF_NUM`, p.`PROF_FNAME`, p.`PROF_LNAME`
)
SELECT
    `PROF_NUM`,
    PROFESSOR_NAME,
    CLASS_COUNT
FROM PROFESSOR_CLASSES
ORDER BY CLASS_COUNT DESC, PROFESSOR_NAME;

-- VIEW:
SELECT * FROM `CTE_PROFESSOR_CLASS_COUNT`;

-- 52. CTE: Tính số lớp đăng ký của từng sinh viên
CREATE VIEW CTE_STUDENT_ENROLL_COUNT AS
WITH STUDENT_ENROLL_COUNT AS (
    SELECT
        s.`STU_NUM`,
        CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
        COUNT(e.`CLASS_CODE`) AS CLASS_COUNT
    FROM `STUDENT` s
    LEFT JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
    GROUP BY s.`STU_NUM`, s.`STU_FNAME`, s.`STU_LNAME`
)
SELECT
    `STU_NUM`,
    STUDENT_NAME,
    CLASS_COUNT
FROM STUDENT_ENROLL_COUNT
WHERE CLASS_COUNT >= 2
ORDER BY CLASS_COUNT DESC, STUDENT_NAME;

-- VIEW:
SELECT * FROM `CTE_STUDENT_ENROLL_COUNT`;

-- 53. CTE: Tìm lớp có số sinh viên cao hơn trung bình
CREATE VIEW CTE_CLASS_ABOVE_AVG_ENROLLMENT AS
WITH CLASS_COUNTS AS (
    SELECT
        c.`CLASS_CODE`,
        crs.`CRS_TITLE`,
        COUNT(e.`STU_NUM`) AS STUDENT_COUNT
    FROM `CLASS` c
    JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
    LEFT JOIN `ENROLL` e ON c.`CLASS_CODE` = e.`CLASS_CODE`
    GROUP BY c.`CLASS_CODE`, crs.`CRS_TITLE`
)
SELECT
    `CLASS_CODE`,
    `CRS_TITLE`,
    STUDENT_COUNT
FROM CLASS_COUNTS
WHERE STUDENT_COUNT > (
    SELECT AVG(STUDENT_COUNT)
    FROM CLASS_COUNTS
)
ORDER BY STUDENT_COUNT DESC, `CLASS_CODE`;

-- VIEW:
SELECT * FROM `CTE_CLASS_ABOVE_AVG_ENROLLMENT`;

-- 54. CTE: Tổng số tín chỉ đã đăng ký của sinh viên
CREATE VIEW CTE_STUDENT_REGISTERED_CREDITS AS
WITH STUDENT_CREDITS AS (
    SELECT
        s.`STU_NUM`,
        CONCAT(s.`STU_FNAME`, ' ', s.`STU_LNAME`) AS STUDENT_NAME,
        SUM(crs.`CRS_CREDIT`) AS TOTAL_CREDIT
    FROM `STUDENT` s
    JOIN `ENROLL` e ON s.`STU_NUM` = e.`STU_NUM`
    JOIN `CLASS` c ON e.`CLASS_CODE` = c.`CLASS_CODE`
    JOIN `COURSE` crs ON c.`CRS_CODE` = crs.`CRS_CODE`
    GROUP BY s.`STU_NUM`, s.`STU_FNAME`, s.`STU_LNAME`
)
SELECT
    `STU_NUM`,
    STUDENT_NAME,
    TOTAL_CREDIT
FROM STUDENT_CREDITS
ORDER BY TOTAL_CREDIT DESC, STUDENT_NAME;

-- VIEW:
SELECT * FROM `CTE_STUDENT_REGISTERED_CREDITS`;

-- 55. CTE: Đếm số khóa học theo từng trường
CREATE VIEW CTE_SCHOOL_COURSE_COUNT AS
WITH SCHOOL_COURSES AS (
    SELECT
        sch.`SCHOOL_CODE`,
        sch.`SCHOOL_NAME`,
        COUNT(crs.`CRS_CODE`) AS COURSE_COUNT
    FROM `SCHOOL` sch
    JOIN `DEPARTMENT` d ON sch.`SCHOOL_CODE` = d.`SCHOOL_CODE`
    LEFT JOIN `COURSE` crs ON d.`DEPT_CODE` = crs.`DEPT_CODE`
    GROUP BY sch.`SCHOOL_CODE`, sch.`SCHOOL_NAME`
)
SELECT
    `SCHOOL_CODE`,
    `SCHOOL_NAME`,
    COURSE_COUNT
FROM SCHOOL_COURSES$
ORDER BY COURSE_COUNT DESC, `SCHOOL_NAME`;

-- VIEW:
SELECT * FROM `CTE_SCHOOL_COURSE_COUNT`;


-- 56. Liệt kê thông tin các học kỳ
CREATE VIEW SEMESTER_INFO AS
SELECT
    SEMESTER_CODE,
    SEMESTER_TERM,
    SEMESTER_YEAR
FROM SEMESTER
ORDER BY SEMESTER_YEAR DESC, SEMESTER_TERM;

-- VIEW
SELECT * FROM SEMESTER_INFO;

-- 57. Liệt kê lịch học của từng lớp theo ngày trong tuần
CREATE VIEW CLASS_MEETING_SCHEDULE AS
SELECT
    cm.CLASS_CODE,
    c.CRS_CODE,
    cm.DAY_OF_WEEK,
    cm.START_TIME,
    cm.END_TIME
FROM CLASS_MEETING cm
JOIN CLASS c ON cm.CLASS_CODE = c.CLASS_CODE
ORDER BY cm.CLASS_CODE, cm.DAY_OF_WEEK, cm.START_TIME;
-- VIEW
SELECT * FROM CLASS_MEETING_SCHEDULE;

-- 58. Thống kê lịch học của từng lớp
CREATE VIEW CTE_CLASS_MEETING_STATS AS
WITH MEETING_STATS AS (
    SELECT
        cm.CLASS_CODE,
        COUNT(*) AS TOTAL_MEETINGS,
        COUNT(DISTINCT cm.DAY_OF_WEEK) AS TOTAL_DAYS
    FROM CLASS_MEETING cm
    GROUP BY cm.CLASS_CODE
)
SELECT
    ms.CLASS_CODE,
    c.CRS_CODE,
    crs.CRS_TITLE,
    ms.TOTAL_MEETINGS,
    ms.TOTAL_DAYS
FROM MEETING_STATS ms
JOIN CLASS c
    ON ms.CLASS_CODE = c.CLASS_CODE
JOIN COURSE crs
    ON c.CRS_CODE = crs.CRS_CODE
ORDER BY ms.TOTAL_MEETINGS DESC,
         ms.TOTAL_DAYS DESC;

-- VIEW
SELECT * FROM CTE_CLASS_MEETING_STATS;


-- Topic: TransCo

-- Tables - Data - Indexes
DROP DATABASE IF EXISTS TransCo;
CREATE DATABASE TransCo
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE TransCo;

SET FOREIGN_KEY_CHECKS = 0;


-- 1. Tables

CREATE TABLE ROLE (
    ROLE_ID VARCHAR(20) PRIMARY KEY,
    ROLE_NAME VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT NULL
);

CREATE TABLE BRANCH (
    BRANCH_CODE VARCHAR(20) PRIMARY KEY,
    MANAGER_EMP_CODE VARCHAR(20) NULL,
    BRANCH_NAME VARCHAR(100) NOT NULL,
    BRANCH_ADDRESS VARCHAR(255) NOT NULL
);

CREATE TABLE EMPLOYEE (
    EMP_CODE VARCHAR(20) PRIMARY KEY,
    BRANCH_CODE VARCHAR(20) NOT NULL,
    EMP_FNAME VARCHAR(50) NOT NULL,
    EMP_LNAME VARCHAR(50) NOT NULL,
    EMP_INITIAL VARCHAR(10) NULL,
    EMP_JOB VARCHAR(100) NULL,
    SALARY DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    EMP_PHONE VARCHAR(20) NULL,

    CONSTRAINT UQ_EMP_PHONE
    UNIQUE (EMP_PHONE)
);

CREATE TABLE WAREHOUSE (
    WAREHOUSE_CODE VARCHAR(20) PRIMARY KEY,
    BRANCH_CODE VARCHAR(20) NOT NULL,
    MANAGER_EMP_CODE VARCHAR(20) NULL,
    WAREHOUSE_ADDRESS VARCHAR(255) NOT NULL,
    CAPACITY INT NOT NULL DEFAULT 0,

    CONSTRAINT CHK_WAREHOUSE_CAPACITY
    CHECK (
        CAPACITY > 0
    )
);

CREATE TABLE CUSTOMER (
    CUS_CODE VARCHAR(20) PRIMARY KEY,
    CUS_FNAME VARCHAR(50) NOT NULL,
    CUS_LNAME VARCHAR(50) NOT NULL,
    CUS_INITIAL VARCHAR(10) NULL,
    CUS_ADDRESS VARCHAR(255) NULL,
    CUS_PHONE VARCHAR(20) NULL,

    CONSTRAINT UQ_CUS_PHONE
    UNIQUE (CUS_PHONE)
);

CREATE TABLE ACCOUNT (
    ACCOUNT_ID VARCHAR(20) PRIMARY KEY,
    ROLE_ID VARCHAR(20) NOT NULL,
    EMP_CODE VARCHAR(20) NULL,
    CUS_CODE VARCHAR(20) NULL,
    USERNAME VARCHAR(100) NOT NULL UNIQUE,
    PASSWORD_HASH VARCHAR(255) NOT NULL,
    IS_ACTIVE BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT CHK_ACCOUNT_OWNER
    CHECK (
        (EMP_CODE IS NOT NULL AND CUS_CODE IS NULL)
        OR
        (EMP_CODE IS NULL AND CUS_CODE IS NOT NULL)
    )
);

CREATE TABLE `ORDER` (
    ORDER_CODE VARCHAR(20) PRIMARY KEY,
    CUS_CODE VARCHAR(20) NOT NULL,
    ORDER_DATE DATETIME NOT NULL,
    ORDER_STATUS VARCHAR(50) NOT NULL,
    ORDER_WEIGHT DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    SHIPPING_FEE DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    SURCHARGE DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    DISCOUNT DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    TOTAL_AMOUNT DECIMAL(15,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT CHK_ORDER_TOTAL
    CHECK (
        TOTAL_AMOUNT = SHIPPING_FEE + SURCHARGE - DISCOUNT
    ),

    CONSTRAINT CHK_ORDER_MONEY
    CHECK (
        SHIPPING_FEE >= 0
        AND SURCHARGE >= 0
        AND DISCOUNT >= 0
        AND TOTAL_AMOUNT >= 0
    ),

    CONSTRAINT CHK_ORDER_WEIGHT
    CHECK (
        ORDER_WEIGHT > 0
    ),

    CONSTRAINT CHK_ORDER_STATUS
    CHECK (ORDER_STATUS IN (
        'Cancelled',
        'Delivered',
        'In Transit',
        'In Warehouse',
        'Pending'
    ))
);


CREATE TABLE GOODS (
    GOODS_CODE VARCHAR(20) PRIMARY KEY,
    ORDER_CODE VARCHAR(20) NOT NULL,
    GOODS_TYPE VARCHAR(100) NULL,
    QUANTITY INT NOT NULL DEFAULT 1,
    WEIGHT DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CURRENT_STATUS VARCHAR(100),
    
    CONSTRAINT CHK_GOODS_STATUS
    CHECK (CURRENT_STATUS IN (
        'Intact',
        'Heavy load checked',
        'Stored safely',
        'Wrapped',
        'Returned to sender',
        'Wrapped securely',
        'Folded',
        'Packaged',
        'Bubble wrapped',
        'Protected',
        'Boxed'
    ))
);

CREATE TABLE TRACKING_LOG (
    TRACKING_ID VARCHAR(20) PRIMARY KEY,
    ORDER_CODE VARCHAR(20) NOT NULL,
    EMP_CODE VARCHAR(20) NOT NULL,
    TRACKING_STATUS VARCHAR(50) NOT NULL,
    LOCATION VARCHAR(255) NULL,
    LOG_TIME DATETIME NOT NULL,
    DESCRIPTION TEXT NULL,
    CONSTRAINT CHK_TRACKING_STATUS
    CHECK (TRACKING_STATUS IN (
        'Delivered',
        'In Storage',
        'In Transit',
        'Received'
    ))
);

CREATE TABLE ORDER_WAREHOUSE_LOG (
    ORDER_CODE VARCHAR(20),
    WAREHOUSE_CODE VARCHAR(20),
    STORAGE_DATE DATETIME NOT NULL,
    STORAGE_STATUS VARCHAR(50) NULL,
    PRIMARY KEY (ORDER_CODE, WAREHOUSE_CODE, STORAGE_DATE)
);

CREATE TABLE VEHICLE (
    VEHICLE_CODE VARCHAR(20) PRIMARY KEY,
    BRANCH_CODE VARCHAR(20) NOT NULL,
    VEHICLE_TYPE VARCHAR(50) NULL,
    VEHICLE_LICENSE VARCHAR(20) NOT NULL UNIQUE,
    MAINTENANCE_STATUS VARCHAR(50) NULL,
    CAPACITY DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT CHK_VEHICLE_CAPACITY
    CHECK (
        CAPACITY > 0
    )
);

CREATE TABLE ROUTE (
    ROUTE_CODE VARCHAR(20) PRIMARY KEY,
    ROUTE_START_POINT VARCHAR(150) NOT NULL,
    ROUTE_END_POINT VARCHAR(150) NOT NULL,
    ROUTE_DISTANCE DECIMAL(10,2) NOT NULL,
    ESTIMATED_TIME DECIMAL(5, 2)
);

CREATE TABLE ROUTE_VEHICLE (
    ROUTE_VEHICLE_CODE VARCHAR(20) PRIMARY KEY,
    ROUTE_CODE VARCHAR(20) NOT NULL,
    VEHICLE_CODE VARCHAR(20) NOT NULL,
    DEPARTURE_TIME DATETIME NULL,
    ARRIVAL_TIME DATETIME NULL
);

CREATE TABLE SHIPMENT (
    SHIP_CODE VARCHAR(20) PRIMARY KEY,
    ORDER_CODE VARCHAR(20) NOT NULL,
    ROUTE_VEHICLE_CODE VARCHAR(20) NOT NULL,
    EMP_CODE VARCHAR(20) NOT NULL,
    WAREHOUSE_CODE VARCHAR(20) NOT NULL,
    SHIP_DATE DATETIME NOT NULL,
    SHIP_STATUS VARCHAR(50) NOT NULL,
    CHECK (SHIP_STATUS IN (
        'Pending',
        'On the way',
        'In Transit',
        'Completed',
        'Cancelled'
    ))
);

CREATE TABLE PAYMENT (
    PAYMENT_ID VARCHAR(20) PRIMARY KEY,
    ORDER_CODE VARCHAR(20) NOT NULL,
    PAYMENT_METHOD VARCHAR(50) NOT NULL,
    PAYMENT_STATUS VARCHAR(50) NOT NULL,
    AMOUNT DECIMAL(15,2) NOT NULL,
    TRANSACTION_TIME DATETIME NOT NULL,
    CONSTRAINT CHK_PAYMENT_STATUS
    CHECK (PAYMENT_STATUS IN (
        'Success',
        'Pending',
        'Processing',
        'Cancelled'
    ))
);


-- PK, FK
ALTER TABLE BRANCH ADD CONSTRAINT FK_BR_EMP FOREIGN KEY (MANAGER_EMP_CODE) REFERENCES EMPLOYEE (EMP_CODE);
ALTER TABLE EMPLOYEE ADD CONSTRAINT FK_EMP_BR FOREIGN KEY (BRANCH_CODE) REFERENCES BRANCH (BRANCH_CODE);
ALTER TABLE WAREHOUSE ADD CONSTRAINT FK_WH_BR FOREIGN KEY (BRANCH_CODE) REFERENCES BRANCH (BRANCH_CODE);
ALTER TABLE WAREHOUSE ADD CONSTRAINT FK_WH_MANAGER_EMP FOREIGN KEY (MANAGER_EMP_CODE) REFERENCES EMPLOYEE (EMP_CODE);
ALTER TABLE ACCOUNT ADD CONSTRAINT FK_ACC_RL FOREIGN KEY (ROLE_ID) REFERENCES ROLE (ROLE_ID);
ALTER TABLE ACCOUNT ADD CONSTRAINT FK_ACC_EMP FOREIGN KEY (EMP_CODE) REFERENCES EMPLOYEE (EMP_CODE);
ALTER TABLE ACCOUNT ADD CONSTRAINT FK_ACC_CUS FOREIGN KEY (CUS_CODE) REFERENCES CUSTOMER (CUS_CODE);
ALTER TABLE `ORDER` ADD CONSTRAINT FK_ORD_CUS FOREIGN KEY (CUS_CODE) REFERENCES CUSTOMER (CUS_CODE);
ALTER TABLE GOODS ADD CONSTRAINT FK_GD_ORD FOREIGN KEY (ORDER_CODE) REFERENCES `ORDER` (ORDER_CODE);
ALTER TABLE TRACKING_LOG ADD CONSTRAINT FK_TL_ORD FOREIGN KEY (ORDER_CODE) REFERENCES `ORDER` (ORDER_CODE);
ALTER TABLE TRACKING_LOG ADD CONSTRAINT FK_TL_EMP FOREIGN KEY (EMP_CODE) REFERENCES EMPLOYEE (EMP_CODE);
ALTER TABLE ORDER_WAREHOUSE_LOG ADD CONSTRAINT FK_OWL_ORD FOREIGN KEY (ORDER_CODE) REFERENCES `ORDER` (ORDER_CODE);
ALTER TABLE ORDER_WAREHOUSE_LOG ADD CONSTRAINT FK_OWL_WH FOREIGN KEY (WAREHOUSE_CODE) REFERENCES WAREHOUSE (WAREHOUSE_CODE);
ALTER TABLE VEHICLE ADD CONSTRAINT FK_VH_BR FOREIGN KEY (BRANCH_CODE) REFERENCES BRANCH (BRANCH_CODE);
ALTER TABLE ROUTE_VEHICLE ADD CONSTRAINT FK_RV_RT FOREIGN KEY (ROUTE_CODE) REFERENCES ROUTE (ROUTE_CODE);
ALTER TABLE ROUTE_VEHICLE ADD CONSTRAINT FK_RV_VH FOREIGN KEY (VEHICLE_CODE) REFERENCES VEHICLE (VEHICLE_CODE);
ALTER TABLE SHIPMENT ADD CONSTRAINT FK_SH_ORD FOREIGN KEY (ORDER_CODE) REFERENCES `ORDER` (ORDER_CODE);
ALTER TABLE SHIPMENT ADD CONSTRAINT FK_SH_RV FOREIGN KEY (ROUTE_VEHICLE_CODE) REFERENCES ROUTE_VEHICLE (ROUTE_VEHICLE_CODE);
ALTER TABLE SHIPMENT ADD CONSTRAINT FK_SH_EMP FOREIGN KEY (EMP_CODE) REFERENCES EMPLOYEE (EMP_CODE);
ALTER TABLE SHIPMENT ADD CONSTRAINT FK_SH_WH FOREIGN KEY (WAREHOUSE_CODE) REFERENCES WAREHOUSE (WAREHOUSE_CODE);
ALTER TABLE PAYMENT ADD CONSTRAINT FK_PY_ORD FOREIGN KEY (ORDER_CODE) REFERENCES `ORDER` (ORDER_CODE);


-- 2. Insert Data

INSERT INTO ROLE (ROLE_ID, ROLE_NAME, DESCRIPTION)
VALUES
('R001','ADMIN','System administrator'),
('R002','MANAGER','Branch manager'),
('R003','STAFF','Company staff'),
('R004','CUSTOMER','Customer account');

INSERT INTO BRANCH (BRANCH_CODE, MANAGER_EMP_CODE, BRANCH_NAME, BRANCH_ADDRESS) VALUES
('BR_HN', NULL, 'Chi nhánh Hà Nội', '12 Cầu Giấy, Hà Nội'),
('BR_DN', NULL, 'Chi nhánh Đà Nẵng', '45 Nguyễn Văn Linh, Đà Nẵng'),
('BR_HCM', NULL, 'Chi nhánh TP.HCM', '78 Lê Lợi, Quận 1, TP.HCM'),
('BR_HP', NULL, 'Chi nhánh Hải Phòng', '102 Lạch Tray, Hải Phòng');

INSERT INTO EMPLOYEE (EMP_CODE, BRANCH_CODE, EMP_FNAME, EMP_LNAME, EMP_INITIAL, EMP_JOB, SALARY, EMP_PHONE) VALUES
('EMP001', 'BR_HN',  'Anh',   'Nguyễn', 'V', 'Branch Manager',  25000000.00, '0901234567'),
('EMP002', 'BR_DN',  'Bảo',   'Trần',   'Q', 'Branch Manager',  22000000.00, '0902345678'),
('EMP003', 'BR_HCM', 'Cường', 'Lê',     'M', 'Branch Manager',  27000000.00, '0903456789'),
('EMP004', 'BR_HP',  'Dũng',  'Phạm',   'H', 'Branch Manager',  20000000.00, '0904567890'),
('EMP005', 'BR_HN',  'Tuấn',  'Hoàng',  'A', 'Driver',          15000000.00, '0912345671'),
('EMP006', 'BR_HN',  'Hùng',  'Vũ',     'K', 'Warehouse Staff', 12000000.00, '0912345672'),
('EMP007', 'BR_HCM', 'Minh',  'Đặng',   'T', 'Driver',          16000000.00, '0912345673'),
('EMP008', 'BR_HCM', 'Linh',  'Ngô',    'P', 'Warehouse Staff', 13000000.00, '0912345674'),
('EMP009', 'BR_DN',  'Sơn',   'Phan',   'V', 'Driver',          14500000.00, '0912345675'),
('EMP010', 'BR_DN',  'Hải',   'Lý',     'N', 'Warehouse Staff', 11500000.00, '0912345676'),
('EMP011', 'BR_HP',  'Khánh', 'Ngô',    'B', 'Driver',          14000000.00, '0912345677'),
('EMP012', 'BR_HP',  'Hà',    'Trần',   'C', 'Warehouse Staff', 11000000.00, '0912345678'),
('EMP013', 'BR_HN',  'Quân',  'Đỗ',     'D', 'Driver',          15500000.00, '0912345679'),
('EMP014', 'BR_HCM', 'Nhân',  'Võ',     'E', 'Driver',          16500000.00, '0912345680'),
('EMP015', 'BR_DN',  'Tâm',   'Cao',    'F', 'Warehouse Staff', 12000000.00, '0912345681');

-- Update Data BRANCH để set MANAGER_EMP_CODE
UPDATE BRANCH SET MANAGER_EMP_CODE = 'EMP001' WHERE BRANCH_CODE = 'BR_HN';
UPDATE BRANCH SET MANAGER_EMP_CODE = 'EMP002' WHERE BRANCH_CODE = 'BR_DN';
UPDATE BRANCH SET MANAGER_EMP_CODE = 'EMP003' WHERE BRANCH_CODE = 'BR_HCM';
UPDATE BRANCH SET MANAGER_EMP_CODE = 'EMP004' WHERE BRANCH_CODE = 'BR_HP';

INSERT INTO WAREHOUSE (WAREHOUSE_CODE, BRANCH_CODE, MANAGER_EMP_CODE, WAREHOUSE_ADDRESS, CAPACITY) VALUES
('WH_HN_01', 'BR_HN', 'EMP006', 'Kho số 1 Bắc Từ Liêm, Hà Nội', 5000),
('WH_DN_01', 'BR_DN', 'EMP010', 'Kho trung chuyển Hòa Cầm, Đà Nẵng', 3000),
('WH_HCM_01', 'BR_HCM', 'EMP008', 'Kho Tổng Thủ Đức, TP.HCM', 8000),
('WH_HP_01', 'BR_HP', 'EMP012', 'Kho Cảng Đình Vũ, Hải Phòng', 4000),
('WH_HN_02', 'BR_HN', 'EMP013', 'Kho số 2 Thanh Xuân, Hà Nội', 4500),
('WH_DN_02', 'BR_DN', 'EMP015', 'Kho phụ Hòa Khánh, Đà Nẵng', 2500),
('WH_HCM_02', 'BR_HCM', 'EMP014', 'Kho Quận 12, TP.HCM', 6000),
('WH_HP_02', 'BR_HP', 'EMP011', 'Kho Cát Bà, Hải Phòng', 3500);

INSERT INTO CUSTOMER (CUS_CODE, CUS_FNAME, CUS_LNAME, CUS_INITIAL, CUS_ADDRESS, CUS_PHONE) VALUES
('CUS001', 'Thành', 'Nguyễn', 'V', 'Thanh Xuân, Hà Nội', '0981112223'),
('CUS002', 'Hương', 'Trần', 'T', 'Quận 3, TP.HCM', '0982223334'),
('CUS003', 'Sơn', 'Lê', 'H', 'Hải Châu, Đà Nẵng', '0983334445'),
('CUS004', 'Oanh', 'Phạm', 'M', 'Lê Chân, Hải Phòng', '0984445556'),
('CUS005', 'Giang', 'Đỗ', 'A', 'Cầu Giấy, Hà Nội', '0985556667'),
('CUS006', 'Dương', 'Hoàng', 'L', 'Bình Thạnh, TP.HCM', '0986667778'),
('CUS007', 'Tùng', 'Phan', 'K', 'Liên Chiểu, Đà Nẵng', '0987778889'),
('CUS008', 'Huy', 'Trịnh', 'G', 'Hoàn Kiếm, Hà Nội', '0988889990'),
('CUS009', 'Loan', 'Bùi', 'H', 'Quận 5, TP.HCM', '0989990001'),
('CUS010', 'Trang', 'Chu', 'I', 'Hải An, Hải Phòng', '0981234567'),
('CUS011', 'Mạnh', 'Tạ', 'J', 'Cầu Giấy, Hà Nội', '0982345678'),
('CUS012', 'Hồng', 'Nhan', 'K', 'Quận 7, TP.HCM', '0983456789'),
('CUS013', 'Phú', 'Gia', 'L', 'Sơn Trà, Đà Nẵng', '0984567890'),
('CUS014', 'Hoa', 'Từ', 'M', 'Đức Giang, Hải Phòng', '0985678901'),
('CUS015', 'Lan', 'Kiều', 'N', 'Bắc Từ Liêm, Hà Nội', '0986789012'),
('CUS016', 'Hải', 'Nguyễn', 'V', 'Quận Liên Chiểu, Đà Nẵng', '0987123456'),
('CUS017', 'Thúy', 'Trần', 'T', 'Quận Gò Vấp, TP.HCM', '0987234567'),
('CUS018', 'Quang', 'Lê', 'H', 'Quận Ba Đình, Hà Nội', '0987345678'),
('CUS019', 'Nga', 'Phạm', 'M', 'Quận Ngô Quyền, Hải Phòng', '0987456789'),
('CUS020', 'Tuấn', 'Đỗ', 'A', 'Quận Long Biên, Hà Nội', '0987567890'),
('CUS021', 'Vy', 'Hoàng', 'L', 'Quận Tân Bình, TP.HCM', '0987678901'),
('CUS022', 'Hoàng', 'Phan', 'K', 'Quận Cẩm Lệ, Đà Nẵng', '0987789012'),
('CUS023', 'Đông', 'Trịnh', 'G', 'Quận Đống Đa, Hà Nội', '0987890123'),
('CUS024', 'Mai', 'Bùi', 'H', 'Quận 10, TP.HCM', '0987901234'),
('CUS025', 'Ngọc', 'Chu', 'I', 'Quận Hồng Bàng, Hải Phòng', '0987012345'),
('CUS026', 'Nam', 'Tạ', 'J', 'Quận Tây Hồ, Hà Nội', '0986123456'),
('CUS027', 'Bình', 'Nhan', 'K', 'Quận 8, TP.HCM', '0986234567'),
('CUS028', 'Kiên', 'Gia', 'L', 'Quận Sơn Trà, Đà Nẵng', '0986345678'),
('CUS029', 'Tuyết', 'Từ', 'M', 'Quận Hải An, Hải Phòng', '0986456789'),
('CUS030', 'Thảo', 'Kiều', 'N', 'Quận Hai Bà Trưng, Hà Nội', '0986567890'),
('CUS031', 'Long', 'Lý', 'A', 'Quận Thanh Xuân, Hà Nội', '0986678901'),
('CUS032', 'Vinh', 'Vương', 'B', 'Quận Phú Nhuận, TP.HCM', '0986789001'),
('CUS033', 'Hà', 'Đặng', 'C', 'Quận Hải Châu, Đà Nẵng', '0986890123'),
('CUS034', 'Nhung', 'Diệp', 'D', 'Quận Lê Chân, Hải Phòng', '0986901234'),
('CUS035', 'Phong', 'Trần', 'E', 'Quận Cầu Giấy, Hà Nội', '0986012345'),
('CUS036', 'Trúc', 'Nguyễn', 'F', 'Quận 7, TP.HCM', '0985123456'),
('CUS037', 'Trung', 'Sơn', 'G', 'Quận Ngũ Hành Sơn, Đà Nẵng', '0985234567'),
('CUS038', 'Linh', 'Thái', 'H', 'Quận Đồ Sơn, Hải Phòng', '0985345678'),
('CUS039', 'Quỳnh', 'Tô', 'I', 'Quận Hoàng Mai, Hà Nội', '0985456789'),
('CUS040', 'Ân', 'Dương', 'J', 'Quận Bình Tân, TP.HCM', '0985567890'),
('CUS041', 'Thắng', 'Bạch', 'K', 'Quận Thanh Khê, Đà Nẵng', '0985678991'),
('CUS042', 'Cúc', 'Tống', 'L', 'Quận Kiến An, Hải Phòng', '0985789012'),
('CUS043', 'Khang', 'Triệu', 'M', 'Quận Nam Từ Liêm, Hà Nội', '0985890123'),
('CUS044', 'Trâm', 'Mạc', 'N', 'Quận 4, TP.HCM', '0985901234'),
('CUS045', 'Sơn', 'Mã', 'O', 'Quận Cẩm Lệ, Đà Nẵng', '0985012345');


INSERT INTO ACCOUNT (ACCOUNT_ID, ROLE_ID, EMP_CODE, CUS_CODE, USERNAME, PASSWORD_HASH, IS_ACTIVE) VALUES
('ACC01', 'R01', 'EMP001', NULL, 'admin_hn', 'hash_pass_1', TRUE),
('ACC02', 'R02', 'EMP002', NULL, 'manager_dn', 'hash_pass_2', TRUE),
('ACC03', 'R02', 'EMP003', NULL, 'manager_hcm', 'hash_pass_3', TRUE),
('ACC04', 'R03', 'EMP005', NULL, 'driver_tuan', 'hash_pass_4', TRUE),
('ACC05', 'R04', 'EMP006', NULL, 'wh_hung', 'hash_pass_5', TRUE),
('ACC06', 'R05', NULL, 'CUS001', 'nguyenthanh', 'hash_cus_1', TRUE),
('ACC07', 'R05', NULL, 'CUS002', 'tranhuong', 'hash_cus_2', TRUE),
('ACC08', 'R05', NULL, 'CUS003', 'leson', 'hash_cus_3', TRUE),
('ACC09', 'R05', NULL, 'CUS004', 'phamoanh', 'hash_cus_4', TRUE),
('ACC10', 'R05', NULL, 'CUS005', 'dogiang', 'hash_cus_5', TRUE),
('ACC11', 'R03', 'EMP007', NULL, 'driver_minh', 'hash_pass_6', TRUE),
('ACC12', 'R03', 'EMP009', NULL, 'driver_son', 'hash_pass_7', TRUE),
('ACC13', 'R04', 'EMP008', NULL, 'wh_linh', 'hash_pass_8', TRUE),
('ACC14', 'R02', 'EMP004', NULL, 'manager_hp', 'hash_pass_9', TRUE),
('ACC15', 'R05', NULL, 'CUS010', 'chuhuong', 'hash_cus_6', TRUE),
('ACC16', 'R05', NULL, 'CUS016', 'hainguyen', 'hash_cus_16', TRUE),
('ACC17', 'R05', NULL, 'CUS017', 'thuytran', 'hash_cus_17', TRUE),
('ACC18', 'R05', NULL, 'CUS018', 'quangle', 'hash_cus_18', TRUE),
('ACC19', 'R05', NULL, 'CUS019', 'ngapham', 'hash_cus_19', TRUE),
('ACC20', 'R05', NULL, 'CUS020', 'tuando', 'hash_cus_20', TRUE),
('ACC21', 'R05', NULL, 'CUS021', 'vyhoang', 'hash_cus_21', TRUE),
('ACC22', 'R05', NULL, 'CUS022', 'hoangphan', 'hash_cus_22', TRUE),
('ACC23', 'R05', NULL, 'CUS023', 'dongtrinh', 'hash_cus_23', TRUE),
('ACC24', 'R05', NULL, 'CUS024', 'maibui', 'hash_cus_24', TRUE),
('ACC25', 'R05', NULL, 'CUS025', 'ngocchu', 'hash_cus_25', TRUE),
('ACC26', 'R05', NULL, 'CUS026', 'namta', 'hash_cus_26', TRUE),
('ACC27', 'R05', NULL, 'CUS027', 'binhnhan', 'hash_cus_27', TRUE),
('ACC28', 'R05', NULL, 'CUS028', 'kiengia', 'hash_cus_28', TRUE),
('ACC29', 'R05', NULL, 'CUS029', 'tuyettruong', 'hash_cus_29', TRUE),
('ACC30', 'R05', NULL, 'CUS030', 'thaokieu', 'hash_cus_30', TRUE),
('ACC31', 'R05', NULL, 'CUS031', 'lylong', 'hash_cus_31', TRUE),
('ACC32', 'R05', NULL, 'CUS032', 'vuongvinh', 'hash_cus_32', TRUE),
('ACC33', 'R05', NULL, 'CUS033', 'dangha', 'hash_cus_33', TRUE),
('ACC34', 'R05', NULL, 'CUS034', 'diepnhung', 'hash_cus_34', TRUE),
('ACC35', 'R05', NULL, 'CUS035', 'tranphong', 'hash_cus_35', TRUE),
('ACC36', 'R05', NULL, 'CUS036', 'nguyentruc', 'hash_cus_36', TRUE),
('ACC37', 'R05', NULL, 'CUS037', 'sontrung', 'hash_cus_37', TRUE),
('ACC38', 'R05', NULL, 'CUS038', 'thailinh', 'hash_cus_38', TRUE),
('ACC39', 'R05', NULL, 'CUS039', 'toquynh', 'hash_cus_39', TRUE),
('ACC40', 'R05', NULL, 'CUS040', 'duongan', 'hash_cus_40', TRUE),
('ACC41', 'R05', NULL, 'CUS041', 'bachthang', 'hash_cus_41', TRUE),
('ACC42', 'R05', NULL, 'CUS042', 'tongcuc', 'hash_cus_42', TRUE),
('ACC43', 'R05', NULL, 'CUS043', 'trieukhang', 'hash_cus_43', TRUE),
('ACC44', 'R05', NULL, 'CUS044', 'mactram', 'hash_cus_44', TRUE),
('ACC45', 'R05', NULL, 'CUS045', 'mason', 'hash_cus_45', TRUE);

INSERT INTO `ORDER` (ORDER_CODE, CUS_CODE, ORDER_DATE, ORDER_STATUS, ORDER_WEIGHT, SHIPPING_FEE, SURCHARGE, DISCOUNT, TOTAL_AMOUNT) VALUES
('ORD2026001', 'CUS001', '2026-05-10 08:30:00', 'Delivered', 15.50, 150000.00, 0.00, 10000.00, 140000.00),
('ORD2026002', 'CUS002', '2026-05-11 10:15:00', 'Delivered', 50.00, 450000.00, 50000.00, 0.00, 500000.00),
('ORD2026003', 'CUS003', '2026-05-12 14:00:00', 'In Transit', 120.00, 1200000.00, 100000.00, 50000.00, 1250000.00),
('ORD2026004', 'CUS004', '2026-05-13 09:00:00', 'Pending', 5.00, 70000.00, 0.00, 0.00, 70000.00),
('ORD2026005', 'CUS005', '2026-05-14 16:45:00', 'In Warehouse', 85.00, 800000.00, 0.00, 20000.00, 780000.00),
('ORD2026006', 'CUS006', '2026-05-15 11:30:00', 'In Transit', 200.00, 2500000.00, 200000.00, 100000.00, 2600000.00),
('ORD2026007', 'CUS007', '2026-05-16 15:20:00', 'Cancelled', 10.00, 100000.00, 0.00, 0.00, 100000.00),
('ORD2026008', 'CUS008', '2026-05-17 07:45:00', 'Delivered', 30.00, 280000.00, 0.00, 15000.00, 265000.00),
('ORD2026009', 'CUS009', '2026-05-18 13:20:00', 'In Transit', 45.00, 400000.00, 30000.00, 20000.00, 410000.00),
('ORD2026010', 'CUS010', '2026-05-19 09:30:00', 'In Warehouse', 75.00, 700000.00, 0.00, 25000.00, 675000.00),
('ORD2026011', 'CUS011', '2026-05-20 11:15:00', 'Pending', 20.00, 180000.00, 0.00, 10000.00, 170000.00),
('ORD2026012', 'CUS012', '2026-05-21 14:50:00', 'Delivered', 60.00, 550000.00, 40000.00, 30000.00, 560000.00),
('ORD2026013', 'CUS013', '2026-05-22 10:00:00', 'In Transit', 100.00, 950000.00, 75000.00, 40000.00, 985000.00),
('ORD2026014', 'CUS014', '2026-05-23 15:30:00', 'In Warehouse', 55.00, 520000.00, 0.00, 22000.00, 498000.00),
('ORD2026015', 'CUS015', '2026-05-24 08:45:00', 'Pending', 35.00, 320000.00, 20000.00, 15000.00, 325000.00),
('ORD2026016', 'CUS006', '2026-05-25 10:00:00', 'Delivered', 40.00, 350000.00, 0.00, 0.00, 350000.00),
('ORD2026017', 'CUS007', '2026-05-26 11:30:00', 'In Transit', 70.00, 600000.00, 50000.00, 0.00, 650000.00),
('ORD2026018', 'CUS008', '2026-05-27 09:45:00', 'Delivered', 25.00, 200000.00, 0.00, 10000.00, 190000.00),
('ORD2026019', 'CUS009', '2026-05-28 14:20:00', 'In Warehouse', 95.00, 850000.00, 0.00, 30000.00, 820000.00),
('ORD2026020', 'CUS010', '2026-05-29 08:00:00', 'Pending', 55.00, 500000.00, 25000.00, 20000.00, 505000.00),
('ORD2026021', 'CUS001', '2026-05-30 15:00:00', 'Delivered', 30.00, 280000.00, 0.00, 0.00, 280000.00),
('ORD2026022', 'CUS012', '2026-05-31 10:15:00', 'In Transit', 110.00, 1000000.00, 80000.00, 50000.00, 1030000.00),
('ORD2026023', 'CUS015', '2026-06-01 12:30:00', 'Delivered', 20.00, 150000.00, 0.00, 5000.00, 145000.00),
('ORD2026024', 'CUS018', '2026-06-02 13:45:00', 'In Transit', 65.00, 580000.00, 40000.00, 0.00, 620000.00),
('ORD2026025', 'CUS020', '2026-06-03 09:30:00', 'In Warehouse', 45.00, 400000.00, 0.00, 15000.00, 385000.00),
('ORD2026026', 'CUS022', '2026-06-04 11:00:00', 'Delivered', 80.00, 750000.00, 60000.00, 0.00, 810000.00),
('ORD2026027', 'CUS025', '2026-06-05 10:30:00', 'Pending', 35.00, 320000.00, 0.00, 10000.00, 310000.00),
('ORD2026028', 'CUS028', '2026-06-05 14:15:00', 'In Transit', 90.00, 900000.00, 70000.00, 40000.00, 930000.00);


INSERT INTO GOODS (GOODS_CODE, ORDER_CODE, GOODS_TYPE, QUANTITY, WEIGHT, CURRENT_STATUS) VALUES
('G01', 'ORD2026001', 'Electronics', 2, 5.50, 'Intact'),
('G02', 'ORD2026001', 'Books', 10, 10.00, 'Intact'),
('G03', 'ORD2026002', 'Clothes', 50, 50.00, 'Intact'),
('G04', 'ORD2026003', 'Machinery parts', 1, 120.00, 'Heavy load checked'),
('G05', 'ORD2026004', 'Documents', 1, 5.00, 'Intact'),
('G06', 'ORD2026005', 'Cosmetics', 5, 85.00, 'Stored safely'),
('G07', 'ORD2026006', 'Furniture', 4, 200.00, 'Wrapped'),
('G08', 'ORD2026007', 'Food items', 20, 10.00, 'Returned to sender'),
('G09', 'ORD2026008', 'Gifts', 15, 30.00, 'Intact'),
('G10', 'ORD2026009', 'Hardware', 30, 45.00, 'Wrapped securely'),
('G11', 'ORD2026010', 'Textiles', 8, 75.00, 'Folded'),
('G12', 'ORD2026011', 'Papers', 25, 20.00, 'Packaged'),
('G13', 'ORD2026012', 'Ceramics', 12, 60.00, 'Bubble wrapped'),
('G14', 'ORD2026013', 'Industrial goods', 2, 100.00, 'Protected'),
('G15', 'ORD2026014', 'Accessories', 40, 55.00, 'Boxed');

INSERT INTO TRACKING_LOG (TRACKING_ID, ORDER_CODE, EMP_CODE, TRACKING_STATUS, LOCATION, LOG_TIME, DESCRIPTION) VALUES
('TRK001', 'ORD2026001', 'EMP006', 'Received', 'Kho Hà Nội 01', '2026-05-10 09:00:00', 'Đã tiếp nhận hàng từ khách hàng'),
('TRK002', 'ORD2026001', 'EMP005', 'In Transit', 'Trục đường QL1A', '2026-05-10 22:00:00', 'Đang vận chuyển vào Đà Nẵng'),
('TRK003', 'ORD2026001', 'EMP009', 'Delivered', 'Hải Châu, Đà Nẵng', '2026-05-12 10:00:00', 'Giao hàng thành công người nhận nhận đủ'),
('TRK004', 'ORD2026003', 'EMP010', 'Received', 'Kho Đà Nẵng 01', '2026-05-12 15:00:00', 'Đã nhận kiện hàng máy móc'),
('TRK005', 'ORD2026003', 'EMP009', 'In Transit', 'Đèo Hải Vân', '2026-05-13 06:00:00', 'Xe chạy tuyến Đà Nẵng - Hà Nội'),
('TRK006', 'ORD2026002', 'EMP006', 'Received', 'Kho TP.HCM 01', '2026-05-11 11:00:00', 'Kiểm nhận hàng quần áo'),
('TRK007', 'ORD2026005', 'EMP006', 'In Storage', 'Kho Hà Nội 01', '2026-05-14 18:00:00', 'Lưu kho mỹ phẩm'),
('TRK008', 'ORD2026006', 'EMP008', 'In Transit', 'Trục Sài Gòn - Hà Nội', '2026-05-15 22:00:00', 'Nằm trên xe tuyến HCM'),
('TRK009', 'ORD2026008', 'EMP006', 'Received', 'Kho Hà Nội 02', '2026-05-17 08:30:00', 'Tiếp nhận quà tặng'),
('TRK010', 'ORD2026009', 'EMP010', 'In Transit', 'Đèo Cả, Nha Trang', '2026-05-18 14:30:00', 'Vận chuyển từ Đà Nẵng'),
('TRK011', 'ORD2026010', 'EMP006', 'In Storage', 'Kho Hà Nội 02', '2026-05-19 10:45:00', 'Lưu kho vải vóc'),
('TRK012', 'ORD2026011', 'EMP006', 'Received', 'Kho Hà Nội 01', '2026-05-20 12:15:00', 'Kiểm nhận giấy tờ'),
('TRK013', 'ORD2026012', 'EMP008', 'Delivered', 'Quận Bình Thạnh, TP.HCM', '2026-05-21 16:00:00', 'Giao hàng gốm sứ thành công'),
('TRK014', 'ORD2026013', 'EMP010', 'In Transit', 'Quốc lộ 1A, Quảng Nam', '2026-05-22 11:30:00', 'Vận chuyển hàng công nghiệp'),
('TRK015', 'ORD2026014', 'EMP012', 'In Storage', 'Kho Hải Phòng 02', '2026-05-23 16:45:00', 'Lưu kho phụ kiện');

INSERT INTO ORDER_WAREHOUSE_LOG (ORDER_CODE, WAREHOUSE_CODE, STORAGE_DATE, STORAGE_STATUS) VALUES
('ORD2026001', 'WH_HN_01', '2026-05-10 09:00:00', 'In'),
('ORD2026001', 'WH_HN_01', '2026-05-10 20:00:00', 'Out'),
('ORD2026003', 'WH_DN_01', '2026-05-12 15:00:00', 'In'),
('ORD2026005', 'WH_HN_01', '2026-05-14 17:00:00', 'In'),
('ORD2026006', 'WH_HCM_01', '2026-05-15 13:00:00', 'In'),
('ORD2026006', 'WH_HCM_01', '2026-05-15 23:30:00', 'Out'),
('ORD2026002', 'WH_HCM_01', '2026-05-11 11:30:00', 'In'),
('ORD2026002', 'WH_HCM_01', '2026-05-11 19:00:00', 'Out'),
('ORD2026008', 'WH_HN_02', '2026-05-17 09:00:00', 'In'),
('ORD2026008', 'WH_HN_02', '2026-05-17 18:30:00', 'Out'),
('ORD2026009', 'WH_DN_01', '2026-05-18 15:00:00', 'In'),
('ORD2026010', 'WH_HN_02', '2026-05-19 11:00:00', 'In'),
('ORD2026011', 'WH_HN_01', '2026-05-20 13:00:00', 'In'),
('ORD2026012', 'WH_HCM_02', '2026-05-21 14:30:00', 'In'),
('ORD2026013', 'WH_DN_02', '2026-05-22 12:00:00', 'In');

INSERT INTO VEHICLE (VEHICLE_CODE, BRANCH_CODE, VEHICLE_TYPE, VEHICLE_LICENSE, MAINTENANCE_STATUS, CAPACITY) VALUES
('V_TRUCK_01', 'BR_HN', 'Heavy Truck', '29C-12345', 'Good', 15.00),
('V_TRUCK_02', 'BR_HN', 'Light Truck', '29C-67890', 'Good', 3.50),
('V_TRUCK_03', 'BR_DN', 'Medium Truck', '43C-11111', 'Under Repair', 8.00),
('V_TRUCK_04', 'BR_HCM', 'Heavy Truck', '51C-22222', 'Good', 20.00),
('V_VAN_01', 'BR_HCM', 'Van', '51D-33333', 'Good', 1.50),
('V_TRUCK_05', 'BR_HP', 'Medium Truck', '34C-44444', 'Good', 7.50),
('V_TRUCK_06', 'BR_HN', 'Heavy Truck', '29C-55555', 'Good', 18.00),
('V_VAN_02', 'BR_DN', 'Van', '43D-66666', 'Maintenance', 2.00),
('V_TRUCK_07', 'BR_HCM', 'Light Truck', '51C-77777', 'Good', 4.00),
('V_TRUCK_08', 'BR_HP', 'Heavy Truck', '34C-88888', 'Good', 16.00),
('V_TRUCK_09', 'BR_HN', 'Medium Truck', '29C-99999', 'Good', 9.00),
('V_VAN_03', 'BR_HCM', 'Van', '51D-10101', 'Good', 2.50),
('V_TRUCK_10', 'BR_DN', 'Light Truck', '43C-11121', 'Good', 5.00),
('V_TRUCK_11', 'BR_HP', 'Van', '34D-12121', 'Good', 3.00),
('V_TRUCK_12', 'BR_HN', 'Heavy Truck', '29C-13131', 'Under Repair', 15.50);

INSERT INTO ROUTE (ROUTE_CODE, ROUTE_START_POINT, ROUTE_END_POINT, ROUTE_DISTANCE, ESTIMATED_TIME) VALUES
('RT_HN_HCM', 'Hà Nội', 'TP.Hồ Chí Minh', 1720.00, 36.00),
('RT_HN_DN', 'Hà Nội', 'Đà Nẵng', 760.00, 16.00),
('RT_DN_HCM', 'Đà Nẵng', 'TP.Hồ Chí Minh', 960.00, 20.00),
('RT_HN_HP', 'Hà Nội', 'Hải Phòng', 120.00, 2.50),
('RT_HN_CT', 'Hà Nội', 'Cần Thơ', 1890.00, 40.00),
('RT_HP_DN', 'Hải Phòng', 'Đà Nẵng', 880.00, 18.00),
('RT_HP_HCM', 'Hải Phòng', 'TP.Hồ Chí Minh', 1840.00, 38.00),
('RT_DN_HP', 'Đà Nẵng', 'Hải Phòng', 880.00, 18.50),
('RT_HCM_CT', 'TP.Hồ Chí Minh', 'Cần Thơ', 160.00, 3.00),
('RT_HN_VT', 'Hà Nội', 'Vũng Tàu', 1680.00, 34.00),
('RT_DN_CT', 'Đà Nẵng', 'Cần Thơ', 1200.00, 25.00),
('RT_HCM_VT', 'TP.Hồ Chí Minh', 'Vũng Tàu', 120.00, 2.00),
('RT_HN_QN', 'Hà Nội', 'Quảng Ninh', 180.00, 3.50),
('RT_HCM_NT', 'TP.Hồ Chí Minh', 'Nha Trang', 450.00, 8.00),
('RT_HN_NT', 'Hà Nội', 'Nha Trang', 1290.00, 27.00);

INSERT INTO ROUTE_VEHICLE (ROUTE_VEHICLE_CODE, ROUTE_CODE, VEHICLE_CODE, DEPARTURE_TIME, ARRIVAL_TIME) VALUES
('RV001', 'RT_HN_DN', 'V_TRUCK_01', '2026-05-10 20:00:00', '2026-05-11 12:00:00'),
('RV002', 'RT_DN_HCM', 'V_TRUCK_03', '2026-05-12 05:00:00', '2026-05-13 01:00:00'),
('RV003', 'RT_HN_HP', 'V_TRUCK_02', '2026-05-13 08:00:00', '2026-05-13 10:30:00'),
('RV004', 'RT_HN_HCM', 'V_TRUCK_04', '2026-05-15 23:30:00', '2026-05-17 11:30:00'),
('RV005', 'RT_HN_CT', 'V_TRUCK_06', '2026-05-17 18:00:00', '2026-05-18 22:00:00'),
('RV006', 'RT_HP_DN', 'V_TRUCK_05', '2026-05-18 07:00:00', '2026-05-19 01:00:00'),
('RV007', 'RT_HN_VT', 'V_TRUCK_09', '2026-05-16 14:00:00', '2026-05-18 00:00:00'),
('RV008', 'RT_HCM_CT', 'V_VAN_01', '2026-05-19 10:00:00', '2026-05-19 13:00:00'),
('RV009', 'RT_HN_HP', 'V_TRUCK_02', '2026-05-20 08:30:00', '2026-05-20 11:00:00'),
('RV010', 'RT_DN_HCM', 'V_TRUCK_07', '2026-05-21 06:00:00', '2026-05-22 02:00:00'),
('RV011', 'RT_HN_QN', 'V_VAN_03', '2026-05-22 09:00:00', '2026-05-22 12:30:00'),
('RV012', 'RT_HCM_NT', 'V_TRUCK_10', '2026-05-23 12:00:00', '2026-05-23 20:00:00'),
('RV013', 'RT_HN_DN', 'V_TRUCK_06', '2026-05-24 19:00:00', '2026-05-25 11:00:00'),
('RV014', 'RT_HP_HCM', 'V_TRUCK_08', '2026-05-20 16:00:00', '2026-05-22 06:00:00'),
('RV015', 'RT_HN_NT', 'V_TRUCK_01', '2026-05-18 20:00:00', '2026-05-20 11:00:00');

INSERT INTO SHIPMENT (SHIP_CODE, ORDER_CODE, ROUTE_VEHICLE_CODE, EMP_CODE, WAREHOUSE_CODE, SHIP_DATE, SHIP_STATUS) VALUES
('SH001', 'ORD2026001', 'RV001', 'EMP005', 'WH_HN_01', '2026-05-10 20:00:00', 'Completed'),
('SH002', 'ORD2026003', 'RV002', 'EMP009', 'WH_DN_01', '2026-05-13 06:00:00', 'On the way'),
('SH003', 'ORD2026006', 'RV004', 'EMP007', 'WH_HCM_01', '2026-05-15 23:30:00', 'In Transit'),
('SH004', 'ORD2026002', 'RV004', 'EMP007', 'WH_HCM_01', '2026-05-11 10:30:00', 'Completed'),
('SH005', 'ORD2026005', 'RV001', 'EMP005', 'WH_HN_01', '2026-05-14 18:00:00', 'On the way'),
('SH006', 'ORD2026008', 'RV003', 'EMP005', 'WH_HN_02', '2026-05-17 09:30:00', 'Completed'),
('SH007', 'ORD2026009', 'RV002', 'EMP009', 'WH_DN_01', '2026-05-18 15:30:00', 'In Transit'),
('SH008', 'ORD2026010', 'RV005', 'EMP013', 'WH_HN_02', '2026-05-19 11:30:00', 'On the way'),
('SH009', 'ORD2026011', 'RV008', 'EMP014', 'WH_HN_01', '2026-05-20 13:30:00', 'Pending'),
('SH010', 'ORD2026012', 'RV004', 'EMP007', 'WH_HCM_02', '2026-05-21 15:00:00', 'In Transit'),
('SH011', 'ORD2026013', 'RV006', 'EMP011', 'WH_DN_02', '2026-05-22 12:30:00', 'In Transit'),
('SH014', 'ORD2026007', 'RV013', 'EMP013', 'WH_HN_02', '2026-05-16 16:00:00', 'Cancelled'),
('SH015', 'ORD2026015', 'RV015', 'EMP005', 'WH_HN_01', '2026-05-24 09:30:00', 'Pending'),
('SH016', 'ORD2026016', 'RV004', 'EMP007', 'WH_HCM_01', '2026-05-25 10:30:00', 'Completed'),
('SH017', 'ORD2026017', 'RV014', 'EMP011', 'WH_HP_01', '2026-05-26 12:00:00', 'In Transit'),
('SH018', 'ORD2026018', 'RV009', 'EMP005', 'WH_HN_01', '2026-05-27 10:15:00', 'Completed'),
('SH019', 'ORD2026019', 'RV010', 'EMP009', 'WH_DN_01', '2026-05-28 15:00:00', 'On the way'),
('SH020', 'ORD2026020', 'RV011', 'EMP013', 'WH_HN_02', '2026-05-29 08:45:00', 'Pending'),
('SH022', 'ORD2026022', 'RV004', 'EMP007', 'WH_HCM_02', '2026-05-31 11:00:00', 'In Transit'),
('SH023', 'ORD2026023', 'RV009', 'EMP013', 'WH_HN_01', '2026-06-01 13:00:00', 'Completed'),
('SH024', 'ORD2026024', 'RV006', 'EMP011', 'WH_HP_02', '2026-06-02 14:30:00', 'In Transit'),
('SH025', 'ORD2026025', 'RV007', 'EMP013', 'WH_HN_02', '2026-06-03 10:00:00', 'On the way'),
('SH026', 'ORD2026026', 'RV004', 'EMP014', 'WH_HCM_01', '2026-06-04 12:00:00', 'Completed'),
('SH027', 'ORD2026027', 'RV013', 'EMP005', 'WH_HN_02', '2026-06-05 11:15:00', 'Pending'),
('SH028', 'ORD2026028', 'RV010', 'EMP009', 'WH_DN_02', '2026-06-05 15:00:00', 'In Transit');

INSERT INTO PAYMENT (PAYMENT_ID, ORDER_CODE, PAYMENT_METHOD, PAYMENT_STATUS, AMOUNT, TRANSACTION_TIME) VALUES
('PAY001', 'ORD2026001', 'Banking', 'Success', 140000.00, '2026-05-10 08:35:00'),
('PAY002', 'ORD2026002', 'COD', 'Success', 500000.00, '2026-05-11 10:20:00'),
('PAY003', 'ORD2026003', 'Banking', 'Success', 1250000.00, '2026-05-12 14:05:00'),
('PAY004', 'ORD2026005', 'Banking', 'Success', 780000.00, '2026-05-14 16:50:00'),
('PAY005', 'ORD2026006', 'COD', 'Pending', 2600000.00, '2026-05-15 11:30:00'),
('PAY006', 'ORD2026008', 'Banking', 'Success', 265000.00, '2026-05-17 08:00:00'),
('PAY007', 'ORD2026009', 'COD', 'Pending', 410000.00, '2026-05-18 13:25:00'),
('PAY008', 'ORD2026010', 'Banking', 'Success', 675000.00, '2026-05-19 10:00:00'),
('PAY009', 'ORD2026011', 'Banking', 'Processing', 170000.00, '2026-05-20 11:20:00'),
('PAY010', 'ORD2026012', 'COD', 'Success', 560000.00, '2026-05-21 15:30:00'),
('PAY011', 'ORD2026013', 'Banking', 'Success', 985000.00, '2026-05-22 10:30:00'),
('PAY012', 'ORD2026014', 'Banking', 'Processing', 498000.00, '2026-05-23 16:00:00'),
('PAY013', 'ORD2026015', 'Banking', 'Pending', 325000.00, '2026-05-24 09:00:00'),
('PAY014', 'ORD2026004', 'COD', 'Cancelled', 70000.00, '2026-05-13 09:10:00'),
('PAY015', 'ORD2026007', 'Banking', 'Cancelled', 100000.00, '2026-05-16 15:40:00'),
('PAY016', 'ORD2026016', 'Banking', 'Success', 350000.00, '2026-05-25 10:05:00'),
('PAY017', 'ORD2026017', 'COD', 'Pending', 650000.00, '2026-05-26 11:45:00'),
('PAY018', 'ORD2026018', 'Banking', 'Success', 190000.00, '2026-05-27 10:00:00'),
('PAY019', 'ORD2026019', 'Banking', 'Processing', 820000.00, '2026-05-28 14:30:00'),
('PAY020', 'ORD2026020', 'COD', 'Pending', 505000.00, '2026-05-29 08:20:00'),
('PAY021', 'ORD2026021', 'Banking', 'Success', 280000.00, '2026-05-30 15:10:00'),
('PAY022', 'ORD2026022', 'COD', 'Success', 1030000.00, '2026-05-31 10:30:00'),
('PAY023', 'ORD2026023', 'Banking', 'Success', 145000.00, '2026-06-01 12:45:00'),
('PAY024', 'ORD2026024', 'Banking', 'Success', 620000.00, '2026-06-02 14:00:00'),
('PAY025', 'ORD2026025', 'COD', 'Pending', 385000.00, '2026-06-03 09:50:00'),
('PAY026', 'ORD2026026', 'Banking', 'Success', 810000.00, '2026-06-04 11:20:00'),
('PAY027', 'ORD2026027', 'Banking', 'Processing', 310000.00, '2026-06-05 10:45:00'),
('PAY028', 'ORD2026028', 'COD', 'Pending', 930000.00, '2026-06-05 14:30:00');


-- 3. Create INDEXES.

-- BRANCH
CREATE INDEX IDX_BRANCH_MANAGER
ON BRANCH(MANAGER_EMP_CODE);

-- EMPLOYEE
CREATE INDEX IDX_EMPLOYEE_BRANCH
ON EMPLOYEE(BRANCH_CODE);

CREATE INDEX IDX_EMPLOYEE_JOB
ON EMPLOYEE(EMP_JOB);

-- WAREHOUSE
CREATE INDEX IDX_WAREHOUSE_BRANCH
ON WAREHOUSE(BRANCH_CODE);

CREATE INDEX IDX_WAREHOUSE_MANAGER
ON WAREHOUSE(MANAGER_EMP_CODE);

-- ACCOUNT
CREATE INDEX IDX_ACCOUNT_ROLE
ON ACCOUNT(ROLE_ID);

CREATE INDEX IDX_ACCOUNT_EMP
ON ACCOUNT(EMP_CODE);

CREATE INDEX IDX_ACCOUNT_CUS
ON ACCOUNT(CUS_CODE);

-- ORDER
CREATE INDEX IDX_ORDER_CUSTOMER
ON `ORDER`(CUS_CODE);

CREATE INDEX IDX_ORDER_DATE
ON `ORDER`(ORDER_DATE);

CREATE INDEX IDX_ORDER_STATUS
ON `ORDER`(ORDER_STATUS);

CREATE INDEX IDX_ORDER_CUS_DATE
ON `ORDER`(CUS_CODE, ORDER_DATE);

-- GOODS
CREATE INDEX IDX_GOODS_ORDER
ON GOODS(ORDER_CODE);

CREATE INDEX IDX_GOODS_TYPE
ON GOODS(GOODS_TYPE);

CREATE INDEX IDX_GOODS_STATUS
ON GOODS(CURRENT_STATUS);

-- TRACKING_LOG
CREATE INDEX IDX_TRACKING_ORDER
ON TRACKING_LOG(ORDER_CODE);

CREATE INDEX IDX_TRACKING_EMPLOYEE
ON TRACKING_LOG(EMP_CODE);

CREATE INDEX IDX_TRACKING_TIME
ON TRACKING_LOG(LOG_TIME);

CREATE INDEX IDX_TRACKING_STATUS
ON TRACKING_LOG(TRACKING_STATUS);

-- ORDER_WAREHOUSE_LOG
CREATE INDEX IDX_OWL_WAREHOUSE
ON ORDER_WAREHOUSE_LOG(WAREHOUSE_CODE);

CREATE INDEX IDX_OWL_STORAGE_DATE
ON ORDER_WAREHOUSE_LOG(STORAGE_DATE);

-- VEHICLE
CREATE INDEX IDX_VEHICLE_BRANCH
ON VEHICLE(BRANCH_CODE);

CREATE INDEX IDX_VEHICLE_TYPE
ON VEHICLE(VEHICLE_TYPE);


-- ROUTE
CREATE INDEX IDX_ROUTE_START
ON ROUTE(ROUTE_START_POINT);

CREATE INDEX IDX_ROUTE_END
ON ROUTE(ROUTE_END_POINT);

-- ROUTE_VEHICLE
CREATE INDEX IDX_ROUTE_VEHICLE_ROUTE
ON ROUTE_VEHICLE(ROUTE_CODE);

CREATE INDEX IDX_ROUTE_VEHICLE_VEHICLE
ON ROUTE_VEHICLE(VEHICLE_CODE);

CREATE INDEX IDX_ROUTE_VEHICLE_DEPARTURE
ON ROUTE_VEHICLE(DEPARTURE_TIME);

-- SHIPMENT
CREATE INDEX IDX_SHIPMENT_ORDER
ON SHIPMENT(ORDER_CODE);

CREATE INDEX IDX_SHIPMENT_EMPLOYEE
ON SHIPMENT(EMP_CODE);

CREATE INDEX IDX_SHIPMENT_WAREHOUSE
ON SHIPMENT(WAREHOUSE_CODE);

CREATE INDEX IDX_SHIPMENT_DATE
ON SHIPMENT(SHIP_DATE);

CREATE INDEX IDX_SHIPMENT_STATUS
ON SHIPMENT(SHIP_STATUS);


-- PAYMENT
CREATE INDEX IDX_PAYMENT_ORDER
ON PAYMENT(ORDER_CODE);

CREATE INDEX IDX_PAYMENT_METHOD
ON PAYMENT(PAYMENT_METHOD);

CREATE INDEX IDX_PAYMENT_STATUS
ON PAYMENT(PAYMENT_STATUS);

CREATE INDEX IDX_PAYMENT_TIME
ON PAYMENT(TRANSACTION_TIME);


SET FOREIGN_KEY_CHECKS = 1;

-- TruyVan - View

-- 1. Liệt kê tất cả đơn hàng của khách hàng
SELECT `ORDER_CODE`, `CUS_CODE`, `ORDER_DATE`, `ORDER_STATUS`, `TOTAL_AMOUNT`
FROM `ORDER`
ORDER BY `ORDER_DATE` DESC;

-- 2. Liệt kê tất cả nhân viên theo chi nhánh
SELECT `EMP_CODE`,
       CONCAT(`EMP_FNAME`, ' ', `EMP_LNAME`) AS EMPLOYEE_NAME,
       `BRANCH_CODE`,
       `EMP_JOB`,
       `SALARY`,
       `EMP_PHONE`
FROM `EMPLOYEE`
ORDER BY `BRANCH_CODE`, `EMP_LNAME`;

-- 3. Liệt kê thông tin kho bãi
SELECT `WAREHOUSE_CODE`,
       `BRANCH_CODE`,
       `WAREHOUSE_ADDRESS`,
       `CAPACITY`
FROM `WAREHOUSE`
ORDER BY `BRANCH_CODE`;

-- 4. Liệt kê danh sách xe vận chuyển
SELECT `VEHICLE_CODE`,
       `BRANCH_CODE`,
       `VEHICLE_TYPE`,
       `VEHICLE_LICENSE`,
       `MAINTENANCE_STATUS`,
       `CAPACITY`
FROM `VEHICLE`
ORDER BY `MAINTENANCE_STATUS` DESC;

-- 5. Chi tiết đơn hàng với thông tin khách hàng và trạng thái thanh toán
CREATE VIEW CUSTOMER_ORDER_PAYMENT AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_ADDRESS`,
    o.`ORDER_DATE`,
    o.`ORDER_STATUS`,
    o.`TOTAL_AMOUNT`,
    p.`PAYMENT_METHOD`,
    p.`PAYMENT_STATUS`
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
LEFT JOIN `PAYMENT` p ON o.`ORDER_CODE` = p.`ORDER_CODE`
ORDER BY o.`ORDER_DATE` DESC;

-- VIEW:
SELECT * FROM CUSTOMER_ORDER_PAYMENT;

-- 6. Theo dõi hành trình vận chuyển của đơn hàng
CREATE VIEW ORDER_TRACKING AS
SELECT
    tl.`TRACKING_ID`,
    tl.`ORDER_CODE`,
    tl.`TRACKING_STATUS`,
    tl.`LOCATION`,
    tl.`LOG_TIME`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS EMPLOYEE_NAME,
    tl.`DESCRIPTION`
FROM `TRACKING_LOG` tl
JOIN `EMPLOYEE` e ON tl.`EMP_CODE` = e.`EMP_CODE`
ORDER BY tl.`ORDER_CODE`, tl.`LOG_TIME`;


-- VIEW:
SELECT * FROM ORDER_TRACKING;

-- 7. Thông tin chi tiết vận chuyển
CREATE VIEW SHIPPING_DETAILS AS
SELECT
    s.`SHIP_CODE`,
    s.`ORDER_CODE`,
    o.`TOTAL_AMOUNT`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
    v.`VEHICLE_CODE`,
    v.`VEHICLE_LICENSE`,
    v.`VEHICLE_TYPE`,
    rt.`ROUTE_START_POINT`,
    rt.`ROUTE_END_POINT`,
    rt.`ROUTE_DISTANCE`,
    s.`SHIP_STATUS`,
    s.`SHIP_DATE`
FROM `SHIPMENT` s
JOIN `ORDER` o ON s.`ORDER_CODE` = o.`ORDER_CODE`
JOIN `EMPLOYEE` e ON s.`EMP_CODE` = e.`EMP_CODE`
JOIN `ROUTE_VEHICLE` rv ON s.`ROUTE_VEHICLE_CODE` = rv.`ROUTE_VEHICLE_CODE`
JOIN `VEHICLE` v ON rv.`VEHICLE_CODE` = v.`VEHICLE_CODE`
JOIN `ROUTE` rt ON rv.`ROUTE_CODE` = rt.`ROUTE_CODE`;


-- VIEW
SELECT * FROM SHIPPING_DETAILS;

-- 8. Phân loại khách hàng
CREATE VIEW CUSTOMER_SEGMENTATION AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    COUNT(o.`ORDER_CODE`) AS TOTAL_ORDERS,
    SUM(o.`SHIPPING_FEE`) AS TOTAL_SHIPPING_FEE,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_REVENUE,
    AVG(o.`TOTAL_AMOUNT`) AS AVG_ORDER_VALUE
FROM `CUSTOMER` c
LEFT JOIN `ORDER` o ON c.`CUS_CODE` = o.`CUS_CODE`
GROUP BY c.`CUS_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`
ORDER BY TOTAL_REVENUE DESC;

-- VIEW:
SELECT * FROM `CUSTOMER_SEGMENTATION`;

-- 9. Lịch sử lưu trữ hàng tại kho
CREATE VIEW WAREHOUSE_STORAGE_HISTORY AS
SELECT
    owl.`ORDER_CODE`,
    owl.`WAREHOUSE_CODE`,
    w.`WAREHOUSE_ADDRESS`,
    owl.`STORAGE_DATE`,
    owl.`STORAGE_STATUS`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS MANAGER_NAME
FROM `ORDER_WAREHOUSE_LOG` owl
JOIN `WAREHOUSE` w ON owl.`WAREHOUSE_CODE` = w.`WAREHOUSE_CODE`
LEFT JOIN `EMPLOYEE` e ON w.`MANAGER_EMP_CODE` = e.`EMP_CODE`
ORDER BY owl.`ORDER_CODE`, owl.`STORAGE_DATE`;

-- VIEW:
SELECT * FROM `WAREHOUSE_STORAGE_HISTORY`;

-- 10. Hiệu suất tài xế - Số chuyến và doanh thu
CREATE VIEW DRIVER_PERFORMANCE AS
SELECT
    s.`EMP_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
    e.`EMP_JOB`,
    COUNT(s.`SHIP_CODE`) AS SHIPMENTS,
    SUM(o.`TOTAL_AMOUNT`) AS REVENUE,
    SUM(o.`ORDER_WEIGHT`) AS TOTAL_WEIGHT
FROM `SHIPMENT` s
JOIN `EMPLOYEE` e ON s.`EMP_CODE` = e.`EMP_CODE`
JOIN `ORDER` o ON s.`ORDER_CODE` = o.`ORDER_CODE`
GROUP BY s.`EMP_CODE`, e.`EMP_FNAME`, e.`EMP_LNAME`, e.`EMP_JOB`
ORDER BY REVENUE DESC;

-- VIEW:
SELECT * FROM `DRIVER_PERFORMANCE`;

-- 11. Doanh thu theo chi nhánh
CREATE VIEW BRANCH_REVENUE AS
SELECT
    b.`BRANCH_CODE`,
    b.`BRANCH_NAME`,
    COUNT(DISTINCT o.`ORDER_CODE`) AS TOTAL_ORDERS,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_REVENUE,
    AVG(o.`TOTAL_AMOUNT`) AS AVG_ORDER_VALUE,
    SUM(o.`SHIPPING_FEE`) AS TOTAL_SHIPPING_FEE
FROM `BRANCH` b
JOIN `EMPLOYEE` e ON b.`BRANCH_CODE` = e.`BRANCH_CODE`
JOIN `SHIPMENT` s ON e.`EMP_CODE` = s.`EMP_CODE`
JOIN `ORDER` o ON s.`ORDER_CODE` = o.`ORDER_CODE`
GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`
ORDER BY TOTAL_REVENUE DESC;

-- VIEW:
SELECT * FROM `BRANCH_REVENUE`;

-- 12. Trạng thái thanh toán theo tháng
CREATE VIEW MONTHLY_PAYMENT_STATUS AS
SELECT
    MONTH(o.`ORDER_DATE`) AS MONTH_NUM,
    YEAR(o.`ORDER_DATE`) AS YEAR_NUM,
    COUNT(o.`ORDER_CODE`) AS TOTAL_ORDERS,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_AMOUNT,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Success' THEN 1 END) AS PAID_ORDERS,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Pending' THEN 1 END) AS PENDING_ORDERS,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Cancelled' THEN 1 END) AS CANCELLED_ORDERS
FROM `ORDER`o
LEFT JOIN `PAYMENT` p ON o.`ORDER_CODE` = p.`ORDER_CODE`
GROUP BY YEAR(o.`ORDER_DATE`), MONTH(o.`ORDER_DATE`)
ORDER BY YEAR_NUM DESC, MONTH_NUM DESC;

-- VIEW:
SELECT * FROM MONTHLY_PAYMENT_STATUS;

-- 13. Loại hàng hoá phổ biến nhất
CREATE VIEW MOST_POPULAR_PRODUCT_CATEGORY AS
SELECT
    g.`GOODS_TYPE`,
    COUNT(g.`GOODS_TYPE`) AS TOTAL_ITEMS,
    SUM(g.`QUANTITY`) AS TOTAL_QUANTITY,
    SUM(g.`WEIGHT`) AS TOTAL_WEIGHT,
    COUNT(DISTINCT g.`ORDER_CODE`) AS ORDERS_CONTAIN_THIS_TYPE,
    AVG(g.`WEIGHT`) AS AVG_WEIGHT_PER_ITEM
FROM `GOODS` g
GROUP BY g.`GOODS_TYPE`
ORDER BY TOTAL_ITEMS DESC;

-- VIEW:
SELECT * FROM MOST_POPULAR_PRODUCT_CATEGORY;

-- 14. Tình trạng bảo trì xe theo chi nhánh
CREATE VIEW VEHICLE_MAINTENANCE_STATUS_BY_BRANCH AS
SELECT
    b.`BRANCH_CODE`,
    b.`BRANCH_NAME`,
    v.`VEHICLE_TYPE`,
    COUNT(v.`VEHICLE_CODE`) AS TOTAL_VEHICLES,
    COUNT(CASE WHEN v.`MAINTENANCE_STATUS` = 'Good' THEN 1 END) AS GOOD,
    COUNT(CASE WHEN v.`MAINTENANCE_STATUS` = 'Under Repair' THEN 1 END) AS UNDER_REPAIR,
    COUNT(CASE WHEN v.`MAINTENANCE_STATUS` = 'Maintenance' THEN 1 END) AS MAINTENANCE,
    SUM(v.`CAPACITY`) AS TOTAL_CAPACITY
FROM `VEHICLE` v
JOIN `BRANCH` b ON v.`BRANCH_CODE` = b.`BRANCH_CODE`
GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`, v.`VEHICLE_TYPE`
ORDER BY b.`BRANCH_CODE`, TOTAL_VEHICLES DESC;

-- VIEW:
SELECT * FROM VEHICLE_MAINTENANCE_STATUS_BY_BRANCH;

-- 15. Hiệu suất giao hàng theo tuyến đường
CREATE VIEW DELIVERY_PERFORMANCE_BY_ROUTE AS
SELECT
    r.ROUTE_CODE,
    r.ROUTE_START_POINT,
    r.ROUTE_END_POINT,
    r.ROUTE_DISTANCE,
    COUNT(rv.ROUTE_VEHICLE_CODE) AS TOTAL_ROUTE_VEHICLES,
    COUNT(s.SHIP_CODE) AS TOTAL_SHIPMENTS,
    COUNT(CASE WHEN s.SHIP_STATUS = 'Completed' THEN 1 END) AS COMPLETED,
    COUNT(CASE WHEN s.SHIP_STATUS = 'In Transit' THEN 1 END) AS IN_TRANSIT,
    COUNT(CASE WHEN s.SHIP_STATUS = 'On the way' THEN 1 END) AS ON_THE_WAY,
    COUNT(CASE WHEN s.SHIP_STATUS = 'Pending' THEN 1 END) AS PENDING,
    AVG(o.TOTAL_AMOUNT) AS AVG_ORDER_VALUE
FROM ROUTE r
LEFT JOIN ROUTE_VEHICLE rv ON r.ROUTE_CODE = rv.ROUTE_CODE
LEFT JOIN SHIPMENT s ON rv.ROUTE_VEHICLE_CODE = s.ROUTE_VEHICLE_CODE
LEFT JOIN `ORDER` o ON s.ORDER_CODE = o.ORDER_CODE
GROUP BY r.ROUTE_CODE, r.ROUTE_START_POINT, r.ROUTE_END_POINT, r.ROUTE_DISTANCE
ORDER BY TOTAL_SHIPMENTS DESC;

-- VIEW:
SELECT * FROM DELIVERY_PERFORMANCE_BY_ROUTE;


-- 16. Phương thức thanh toán được sử dụng nhiều nhất
CREATE VIEW MOST_USED_PAYMENT_METHOD AS
SELECT
    p.`PAYMENT_METHOD`,
    COUNT(p.`PAYMENT_ID`) AS TOTAL_PAYMENTS,
    SUM(p.`AMOUNT`) AS TOTAL_AMOUNT,
    AVG(p.`AMOUNT`) AS AVG_AMOUNT,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Success' THEN 1 END) AS SUCCESS_COUNT,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Pending' THEN 1 END) AS PENDING_COUNT,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Processing' THEN 1 END) AS PROCESSING_COUNT,
    COUNT(CASE WHEN p.`PAYMENT_STATUS` = 'Cancelled' THEN 1 END) AS CANCELLED_COUNT
FROM `PAYMENT` p
GROUP BY p.`PAYMENT_METHOD`
HAVING COUNT(p.`PAYMENT_ID`) > 0
ORDER BY TOTAL_PAYMENTS DESC;

-- VIEW:
SELECT * FROM MOST_USED_PAYMENT_METHOD;

-- 17. Khách hàng thường xuyên ghé (có nhiều đơn hàng)
CREATE VIEW FREQUENT_CUSTOMERS AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_PHONE`,
    c.`CUS_ADDRESS`,
    COUNT(o.`ORDER_CODE`) AS TOTAL_ORDERS,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_SPENDING,
    AVG(o.`TOTAL_AMOUNT`) AS AVG_ORDER_VALUE,
    MAX(o.`ORDER_DATE`) AS LAST_ORDER_DATE,
    MIN(o.`ORDER_DATE`) AS FIRST_ORDER_DATE
FROM `CUSTOMER` c
JOIN `ORDER` o ON c.`CUS_CODE` = o.`CUS_CODE`
GROUP BY c.`CUS_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`, c.`CUS_PHONE`, c.`CUS_ADDRESS`
HAVING COUNT(o.`ORDER_CODE`) >= 2
ORDER BY TOTAL_ORDERS DESC;

-- VIEW:
SELECT * FROM FREQUENT_CUSTOMERS;

-- 18. Hàng hoá trong mỗi đơn hàng
CREATE VIEW GOODS_BY_ORDERS AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    COUNT(g.`GOODS_CODE`) AS TOTAL_ITEMS,
    SUM(g.`QUANTITY`) AS TOTAL_QUANTITY,
    SUM(g.`WEIGHT`) AS TOTAL_WEIGHT,
    o.`ORDER_WEIGHT`,
    o.`TOTAL_AMOUNT`,
    o.`ORDER_STATUS`,
    o.`ORDER_DATE`
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
LEFT JOIN `GOODS` g ON o.`ORDER_CODE` = g.`ORDER_CODE`
GROUP BY o.`ORDER_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`, o.`ORDER_WEIGHT`, o.`TOTAL_AMOUNT`, o.`ORDER_STATUS`, o.`ORDER_DATE`
HAVING COUNT(g.`GOODS_CODE`) > 0
ORDER BY o.`ORDER_DATE` DESC;

-- VIEW:

SELECT * FROM GOODS_BY_ORDERS;

-- 19. Tài xế và số lượng đơn hàng giao được
CREATE VIEW DRIVER_DELIVERY_PERFORMANCE AS
SELECT
    e.`EMP_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
    b.`BRANCH_NAME`,
    COUNT(s.`SHIP_CODE`) AS TOTAL_DELIVERIES,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_REVENUE,
    COUNT(CASE WHEN s.`SHIP_STATUS` = 'Completed' THEN 1 END) AS COMPLETED,
    COUNT(CASE WHEN s.`SHIP_STATUS` = 'In Transit' THEN 1 END) AS IN_TRANSIT,
    COUNT(CASE WHEN s.`SHIP_STATUS` = 'On the way' THEN 1 END) AS ON_THE_WAY,
    COUNT(CASE WHEN s.`SHIP_STATUS` = 'Pending' THEN 1 END) AS PENDING,
    e.`SALARY`
FROM `EMPLOYEE` e
JOIN `BRANCH` b ON e.`BRANCH_CODE` = b.`BRANCH_CODE`
LEFT JOIN `SHIPMENT` s ON e.`EMP_CODE` = s.`EMP_CODE`
LEFT JOIN `ORDER` o ON s.`ORDER_CODE` = o.`ORDER_CODE`
WHERE e.`EMP_JOB` = 'Driver'
GROUP BY e.`EMP_CODE`, e.`EMP_FNAME`, e.`EMP_LNAME`, b.`BRANCH_NAME`, e.`SALARY`
HAVING COUNT(s.`SHIP_CODE`) > 0
ORDER BY TOTAL_DELIVERIES DESC;

-- VIEW:
SELECT * FROM DRIVER_DELIVERY_PERFORMANCE;

-- 20. Chi phí vận chuyển và phí phụ thu theo từng đơn hàng
CREATE VIEW SHIPPING_COST_BY_ORDER AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    o.`ORDER_WEIGHT`,
    o.`SHIPPING_FEE`,
    o.`SURCHARGE`,
    o.`DISCOUNT`,
    (o.`SHIPPING_FEE` + o.`SURCHARGE` - o.`DISCOUNT`) AS NET_FEE,
    o.`TOTAL_AMOUNT`,
    ROUND(o.`SHIPPING_FEE` / NULLIF(o.`ORDER_WEIGHT`, 0), 2) AS FEE_PER_KG,
    o.`ORDER_STATUS`
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
WHERE o.`ORDER_WEIGHT` > 0
GROUP BY o.`ORDER_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`, o.`ORDER_WEIGHT`, o.`SHIPPING_FEE`, o.`SURCHARGE`, o.`DISCOUNT`, o.`TOTAL_AMOUNT`, o.`ORDER_DATE`, o.`ORDER_STATUS`
HAVING o.`SHIPPING_FEE` > 0
ORDER BY NET_FEE DESC;

-- VIEW:
SELECT * FROM `SHIPPING_COST_BY_ORDER`;


-- 21. Sử dụng kho bãi theo từng chi nhánh (CTE)
CREATE VIEW WAREHOUSE_USAGE_BY_BRANCH AS
WITH warehouse_capacity AS (
    SELECT
        BRANCH_CODE,
        COUNT(*) AS TOTAL_WAREHOUSES,
        SUM(CAPACITY) AS TOTAL_CAPACITY
    FROM WAREHOUSE
    GROUP BY BRANCH_CODE
),
warehouse_activity AS (
    SELECT
        w.BRANCH_CODE,
        COUNT(owl.ORDER_CODE) AS TOTAL_ORDERS_STORED,
        COUNT(CASE WHEN owl.STORAGE_STATUS = 'In' THEN 1 END) AS ORDERS_IN,
        COUNT(CASE WHEN owl.STORAGE_STATUS = 'Out' THEN 1 END) AS ORDERS_OUT,
        COALESCE(AVG(o.ORDER_WEIGHT), 0) AS AVG_WEIGHT
    FROM WAREHOUSE w
    LEFT JOIN ORDER_WAREHOUSE_LOG owl ON w.WAREHOUSE_CODE = owl.WAREHOUSE_CODE
    LEFT JOIN `ORDER` o ON owl.ORDER_CODE = o.ORDER_CODE
    GROUP BY w.BRANCH_CODE
)
SELECT
    b.BRANCH_CODE,
    b.BRANCH_NAME,
    wc.TOTAL_WAREHOUSES,
    wc.TOTAL_CAPACITY,
    COALESCE(wa.TOTAL_ORDERS_STORED, 0) AS TOTAL_ORDERS_STORED,
    COALESCE(wa.ORDERS_IN, 0) AS ORDERS_IN,
    COALESCE(wa.ORDERS_OUT, 0) AS ORDERS_OUT,
    COALESCE(wa.AVG_WEIGHT, 0) AS AVG_WEIGHT
FROM BRANCH b
JOIN warehouse_capacity wc ON b.BRANCH_CODE = wc.BRANCH_CODE
LEFT JOIN warehouse_activity wa ON b.BRANCH_CODE = wa.BRANCH_CODE
WHERE COALESCE(wa.TOTAL_ORDERS_STORED, 0) > 0
ORDER BY TOTAL_ORDERS_STORED DESC;

-- VIEW:
SELECT * FROM `WAREHOUSE_USAGE_BY_BRANCH`;

-- 22. Trạng thái đơn hàng theo khách hàng
CREATE VIEW ORDER_STATUS_BY_CUSTOMER AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_PHONE`,
    COUNT(o.`ORDER_CODE`) AS TOTAL_ORDERS,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'Delivered' THEN 1 END) AS DELIVERED,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'In Transit' THEN 1 END) AS IN_TRANSIT,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'In Warehouse' THEN 1 END) AS IN_WAREHOUSE,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'Pending' THEN 1 END) AS PENDING,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'Cancelled' THEN 1 END) AS CANCELLED,
    COUNT(CASE WHEN o.`ORDER_STATUS` = 'Returned' THEN 1 END) AS RETURNED,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_SPENDING
FROM `CUSTOMER` c
LEFT JOIN `ORDER` o ON c.`CUS_CODE` = o.`CUS_CODE`
GROUP BY c.`CUS_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`, c.`CUS_PHONE`
HAVING COUNT(o.`ORDER_CODE`) > 0
ORDER BY TOTAL_ORDERS DESC;

-- VIEW:
SELECT * FROM ORDER_STATUS_BY_CUSTOMER;

-- 23. Nhân viên kho và số lần quản lý (CTE)
CREATE VIEW WAREHOUSE_STAFF_PERFORMANCE AS
WITH warehouse_info AS (
    SELECT
        MANAGER_EMP_CODE,
        COUNT(*) AS MANAGED_WAREHOUSES,
        SUM(CAPACITY) AS TOTAL_CAPACITY
    FROM WAREHOUSE
    GROUP BY MANAGER_EMP_CODE
),
warehouse_orders AS (
    SELECT
        w.MANAGER_EMP_CODE,
        COUNT(owl.ORDER_CODE) AS TOTAL_ORDERS_HANDLED,
        COUNT(CASE WHEN owl.STORAGE_STATUS = 'In' THEN 1 END) AS ORDERS_IN,
        COUNT(CASE WHEN owl.STORAGE_STATUS = 'Out' THEN 1 END) AS ORDERS_OUT
    FROM WAREHOUSE w
    LEFT JOIN ORDER_WAREHOUSE_LOG owl
        ON w.WAREHOUSE_CODE = owl.WAREHOUSE_CODE
    GROUP BY w.MANAGER_EMP_CODE
)
SELECT
    e.EMP_CODE,
    CONCAT(e.EMP_FNAME, ' ', e.EMP_LNAME) AS WAREHOUSE_MANAGER,
    b.BRANCH_NAME,
    COALESCE(wi.MANAGED_WAREHOUSES, 0) AS MANAGED_WAREHOUSES,
    COALESCE(wi.TOTAL_CAPACITY, 0) AS TOTAL_CAPACITY,
    COALESCE(wo.TOTAL_ORDERS_HANDLED, 0) AS TOTAL_ORDERS_HANDLED,
    COALESCE(wo.ORDERS_IN, 0) AS ORDERS_IN,
    COALESCE(wo.ORDERS_OUT, 0) AS ORDERS_OUT,
    e.SALARY,
    e.EMP_PHONE
FROM EMPLOYEE e
JOIN BRANCH b
    ON e.BRANCH_CODE = b.BRANCH_CODE
LEFT JOIN warehouse_info wi
    ON e.EMP_CODE = wi.MANAGER_EMP_CODE
LEFT JOIN warehouse_orders wo
    ON e.EMP_CODE = wo.MANAGER_EMP_CODE
WHERE e.EMP_JOB = 'Warehouse Staff'
  AND COALESCE(wo.TOTAL_ORDERS_HANDLED, 0) > 0
ORDER BY TOTAL_ORDERS_HANDLED DESC;
-- VIEW:
SELECT * FROM WAREHOUSE_STAFF_PERFORMANCE;

-- 24. Tuyến đường được sử dụng nhiều nhất
CREATE VIEW MOST_USED_ROUTE AS
SELECT
    r.ROUTE_CODE,
    r.ROUTE_START_POINT,
    r.ROUTE_END_POINT,
    r.ROUTE_DISTANCE,
    r.ESTIMATED_TIME,
    COUNT(s.SHIP_CODE) AS TOTAL_SHIPMENTS,
    COUNT(CASE WHEN s.SHIP_STATUS = 'Completed' THEN 1 END) AS COMPLETED,
    COUNT(CASE WHEN s.SHIP_STATUS = 'In Transit' THEN 1 END) AS IN_TRANSIT,
    COUNT(CASE WHEN s.SHIP_STATUS = 'On the way' THEN 1 END) AS ON_THE_WAY,
    COUNT(CASE WHEN s.SHIP_STATUS = 'Pending' THEN 1 END) AS PENDING,
    COUNT(DISTINCT rv.VEHICLE_CODE) AS TOTAL_VEHICLES_USED,
    COUNT(DISTINCT s.EMP_CODE) AS TOTAL_DRIVERS,
    AVG(o.TOTAL_AMOUNT) AS AVG_ORDER_VALUE,
    SUM(o.TOTAL_AMOUNT) AS TOTAL_REVENUE 
FROM ROUTE r
LEFT JOIN ROUTE_VEHICLE rv ON r.ROUTE_CODE = rv.ROUTE_CODE
LEFT JOIN SHIPMENT s ON rv.ROUTE_VEHICLE_CODE = s.ROUTE_VEHICLE_CODE
LEFT JOIN `ORDER` o ON s.ORDER_CODE = o.ORDER_CODE
GROUP BY r.ROUTE_CODE, r.ROUTE_START_POINT, r.ROUTE_END_POINT, r.ROUTE_DISTANCE, r.ESTIMATED_TIME
HAVING COUNT(s.SHIP_CODE) > 0
ORDER BY TOTAL_SHIPMENTS DESC;

-- VIEW:
SELECT * FROM MOST_USED_ROUTE;

-- 25. Thống kê xe the chi nhánh và tình trạng bảo trì
CREATE VIEW BRANCH_VEHICLE_STATISTICS AS
SELECT
    b.BRANCH_CODE,
    b.BRANCH_NAME,
    v.VEHICLE_TYPE,
    COUNT(v.VEHICLE_CODE) AS TOTAL_VEHICLES,
    COUNT(CASE WHEN v.MAINTENANCE_STATUS = 'Good' THEN 1 END) AS GOOD_CONDITION,
    COUNT(CASE WHEN v.MAINTENANCE_STATUS = 'Under Repair' THEN 1 END) AS UNDER_REPAIR,
    COUNT(CASE WHEN v.MAINTENANCE_STATUS = 'Maintenance' THEN 1 END) AS MAINTENANCE,
    SUM(v.CAPACITY) AS TOTAL_CAPACITY,
    AVG(v.CAPACITY) AS AVG_CAPACITY,
    COUNT(s.SHIP_CODE) AS TOTAL_TRIPS,
    COUNT(CASE WHEN s.SHIP_STATUS = 'Completed' THEN 1 END) AS COMPLETED_TRIPS,
    ROUND(COUNT(CASE WHEN s.SHIP_STATUS = 'Completed' THEN 1 END) * 100.0 / NULLIF(COUNT(s.SHIP_CODE), 0), 2) AS TRIP_SUCCESS_RATE
FROM VEHICLE v
JOIN BRANCH b ON v.BRANCH_CODE = b.BRANCH_CODE
LEFT JOIN SHIPMENT s ON v.VEHICLE_CODE = (
    SELECT VEHICLE_CODE FROM ROUTE_VEHICLE WHERE ROUTE_VEHICLE_CODE = s.ROUTE_VEHICLE_CODE
)
GROUP BY b.BRANCH_CODE, b.BRANCH_NAME, v.VEHICLE_TYPE
HAVING COUNT(v.VEHICLE_CODE) > 0
ORDER BY b.BRANCH_CODE, TOTAL_VEHICLES DESC;

-- VIEW:
SELECT * FROM BRANCH_VEHICLE_STATISTICS;

-- 26. Liệt kê thông tin chi nhánh và quản lý chi nhánh
CREATE VIEW BRANCH_MANAGER_INFO AS
SELECT
    b.`BRANCH_CODE`,
    b.`BRANCH_NAME`,
    b.`BRANCH_ADDRESS`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS MANAGER_NAME,
    e.`EMP_PHONE`
FROM `BRANCH` b
LEFT JOIN `EMPLOYEE` e ON b.`MANAGER_EMP_CODE` = e.`EMP_CODE`
ORDER BY b.`BRANCH_NAME`;

-- VIEW:
SELECT * FROM `BRANCH_MANAGER_INFO`;

-- 27. Liệt kê nhân viên có lương trên 15 triệu
CREATE VIEW EMPLOYEE_SALARY_ABOVE_15M AS
SELECT
    e.`EMP_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS EMPLOYEE_NAME,
    b.`BRANCH_NAME`,
    e.`EMP_JOB`,
    e.`SALARY`
FROM `EMPLOYEE` e
JOIN `BRANCH` b ON e.`BRANCH_CODE` = b.`BRANCH_CODE`
WHERE e.`SALARY` > 15000000
ORDER BY e.`SALARY` DESC;

-- VIEW:
SELECT * FROM `EMPLOYEE_SALARY_ABOVE_15M`;

-- 28. Liệt kê khách hàng ở Hà Nội
CREATE VIEW HANOI_CUSTOMERS AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_ADDRESS`,
    c.`CUS_PHONE`
FROM `CUSTOMER` c
WHERE c.`CUS_ADDRESS` LIKE '%Hà Nội%'
ORDER BY c.`CUS_LNAME`, c.`CUS_FNAME`;

-- VIEW:
SELECT * FROM `HANOI_CUSTOMERS`;

-- 29. Liệt kê đơn hàng đang chờ xử lý
CREATE VIEW PENDING_ORDERS AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    o.`ORDER_DATE`,
    o.`ORDER_WEIGHT`,
    o.`TOTAL_AMOUNT`
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
WHERE o.`ORDER_STATUS` = 'Pending'
ORDER BY o.`ORDER_DATE`;

-- VIEW:
SELECT * FROM `PENDING_ORDERS`;

-- 30. Liệt kê đơn hàng có khối lượng lớn hơn 100kg
CREATE VIEW HEAVY_ORDERS AS
SELECT
    o.`ORDER_CODE`,
    o.`CUS_CODE`,
    o.`ORDER_WEIGHT`,
    o.`SHIPPING_FEE`,
    o.`TOTAL_AMOUNT`,
    o.`ORDER_STATUS`
FROM `ORDER` o
WHERE o.`ORDER_WEIGHT` > 100
ORDER BY o.`ORDER_WEIGHT` DESC;

-- VIEW:
SELECT * FROM `HEAVY_ORDERS`;

-- 31. Đếm số nhân viên theo từng chi nhánh
CREATE VIEW EMPLOYEE_COUNT_BY_BRANCH AS
SELECT
    b.`BRANCH_CODE`,
    b.`BRANCH_NAME`,
    COUNT(e.`EMP_CODE`) AS EMPLOYEE_COUNT
FROM `BRANCH` b
LEFT JOIN `EMPLOYEE` e ON b.`BRANCH_CODE` = e.`BRANCH_CODE`
GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`
ORDER BY EMPLOYEE_COUNT DESC, b.`BRANCH_NAME`;

-- VIEW:
SELECT * FROM `EMPLOYEE_COUNT_BY_BRANCH`;

-- 32. Đếm số đơn hàng theo từng trạng thái
CREATE VIEW ORDER_COUNT_BY_STATUS AS
SELECT
    o.`ORDER_STATUS`,
    COUNT(o.`ORDER_CODE`) AS ORDER_COUNT,
    SUM(o.`TOTAL_AMOUNT`) AS TOTAL_AMOUNT
FROM `ORDER` o
GROUP BY o.`ORDER_STATUS`
ORDER BY ORDER_COUNT DESC;

-- VIEW:
SELECT * FROM `ORDER_COUNT_BY_STATUS`;

-- 33. Liệt kê kho cùng tên chi nhánh quản lý
CREATE VIEW WAREHOUSE_BRANCH_INFO AS
SELECT
    w.`WAREHOUSE_CODE`,
    b.`BRANCH_NAME`,
    w.`WAREHOUSE_ADDRESS`,
    w.`CAPACITY`
FROM `WAREHOUSE` w
JOIN `BRANCH` b ON w.`BRANCH_CODE` = b.`BRANCH_CODE`
ORDER BY b.`BRANCH_NAME`, w.`WAREHOUSE_CODE`;

-- VIEW:
SELECT * FROM `WAREHOUSE_BRANCH_INFO`;

-- 34. Liệt kê xe có trạng thái bảo trì tốt
CREATE VIEW VEHICLES_IN_GOOD_CONDITION AS
SELECT
    v.`VEHICLE_CODE`,
    v.`VEHICLE_TYPE`,
    v.`VEHICLE_LICENSE`,
    b.`BRANCH_NAME`,
    v.`CAPACITY`
FROM `VEHICLE` v
JOIN `BRANCH` b ON v.`BRANCH_CODE` = b.`BRANCH_CODE`
WHERE v.`MAINTENANCE_STATUS` = 'Good'
ORDER BY b.`BRANCH_NAME`, v.`VEHICLE_TYPE`;

-- VIEW:
SELECT * FROM `VEHICLES_IN_GOOD_CONDITION`;

-- 35. Liệt kê thanh toán thành công
CREATE VIEW SUCCESSFUL_PAYMENTS AS
SELECT
    p.`PAYMENT_ID`,
    p.`ORDER_CODE`,
    p.`PAYMENT_METHOD`,
    p.`AMOUNT`,
    p.`TRANSACTION_TIME`
FROM `PAYMENT` p
WHERE p.`PAYMENT_STATUS` = 'Success'
ORDER BY p.`TRANSACTION_TIME` DESC;

-- VIEW:
SELECT * FROM `SUCCESSFUL_PAYMENTS`;

-- 36. Liệt kê khách hàng đã từng đặt hàng
CREATE VIEW CUSTOMERS_WITH_ORDERS AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_PHONE`
FROM `CUSTOMER` c
WHERE EXISTS (
    SELECT 1
    FROM `ORDER` o
    WHERE o.`CUS_CODE` = c.`CUS_CODE`
)
ORDER BY c.`CUS_LNAME`, c.`CUS_FNAME`;

-- VIEW:
SELECT * FROM `CUSTOMERS_WITH_ORDERS`;

-- 37. Liệt kê khách hàng chưa có đơn hàng
CREATE VIEW CUSTOMERS_WITHOUT_ORDERS AS
SELECT
    c.`CUS_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    c.`CUS_ADDRESS`,
    c.`CUS_PHONE`
FROM `CUSTOMER` c
WHERE NOT EXISTS (
    SELECT 1
    FROM `ORDER` o
    WHERE o.`CUS_CODE` = c.`CUS_CODE`
)
ORDER BY c.`CUS_LNAME`, c.`CUS_FNAME`;

-- VIEW:
SELECT * FROM `CUSTOMERS_WITHOUT_ORDERS`;

-- 38. Liệt kê đơn hàng có tổng tiền cao hơn trung bình
CREATE VIEW ORDERS_ABOVE_AVG_AMOUNT AS
SELECT
    o.`ORDER_CODE`,
    o.`CUS_CODE`,
    o.`ORDER_DATE`,
    o.`TOTAL_AMOUNT`,
    o.`ORDER_STATUS`
FROM `ORDER` o
WHERE o.`TOTAL_AMOUNT` > (
    SELECT AVG(o2.`TOTAL_AMOUNT`)
    FROM `ORDER` o2
)
ORDER BY o.`TOTAL_AMOUNT` DESC;

-- VIEW:
SELECT * FROM `ORDERS_ABOVE_AVG_AMOUNT`;

-- 39. Liệt kê nhân viên có lương cao hơn lương trung bình của chi nhánh
CREATE VIEW EMPLOYEE_ABOVE_BRANCH_AVG_SALARY AS
SELECT
    e.`EMP_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS EMPLOYEE_NAME,
    e.`BRANCH_CODE`,
    e.`EMP_JOB`,
    e.`SALARY`
FROM `EMPLOYEE` e
WHERE e.`SALARY` > (
    SELECT AVG(e2.`SALARY`)
    FROM `EMPLOYEE` e2
    WHERE e2.`BRANCH_CODE` = e.`BRANCH_CODE`
)
ORDER BY e.`BRANCH_CODE`, e.`SALARY` DESC;

-- VIEW:
SELECT * FROM `EMPLOYEE_ABOVE_BRANCH_AVG_SALARY`;

-- 40. Liệt kê xe chưa từng được phân tuyến (đã sửa)
CREATE VIEW VEHICLES_WITHOUT_ROUTE AS
SELECT
    v.`VEHICLE_CODE`,
    v.`VEHICLE_TYPE`,
    v.`VEHICLE_LICENSE`,
    b.`BRANCH_NAME`,
    v.`MAINTENANCE_STATUS`
FROM `VEHICLE` v
JOIN `BRANCH` b ON v.`BRANCH_CODE` = b.`BRANCH_CODE`
WHERE v.`VEHICLE_CODE` NOT IN (
    SELECT rv.`VEHICLE_CODE`
    FROM `ROUTE_VEHICLE` rv
)
ORDER BY b.`BRANCH_NAME`, v.`VEHICLE_CODE`;

-- VIEW:
SELECT * FROM `VEHICLES_WITHOUT_ROUTE`;

-- 41. Liệt kê xe chưa từng được phân tuyến
CREATE VIEW VEHICLES_WITHOUT_ROUTE AS
SELECT
    v.`VEHICLE_CODE`,
    v.`VEHICLE_TYPE`,
    v.`VEHICLE_LICENSE`,
    b.`BRANCH_NAME`,
    v.`MAINTENANCE_STATUS`
FROM `VEHICLE` v
JOIN `BRANCH` b ON v.`BRANCH_CODE` = b.`BRANCH_CODE`
LEFT JOIN `ROUTE_VEHICLE` rv ON v.`VEHICLE_CODE` = rv.`VEHICLE_CODE`
WHERE rv.`VEHICLE_CODE` IS NULL
ORDER BY b.`BRANCH_NAME`, v.`VEHICLE_CODE`;

-- VIEW:
SELECT * FROM `VEHICLES_WITHOUT_ROUTE`;

-- 42. Liệt kê đơn hàng chưa có thanh toán
CREATE VIEW ORDERS_WITHOUT_PAYMENT AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    o.`ORDER_DATE`,
    o.`TOTAL_AMOUNT`,
    o.`ORDER_STATUS`
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
WHERE o.`ORDER_CODE` NOT IN (
    SELECT p.`ORDER_CODE`
    FROM `PAYMENT` p
)
ORDER BY o.`ORDER_DATE` DESC;

-- VIEW:
SELECT * FROM `ORDERS_WITHOUT_PAYMENT`;

-- 43. Liệt kê đơn hàng có nhiều hơn một loại hàng
CREATE VIEW ORDERS_WITH_MULTIPLE_GOODS AS
SELECT
    o.`ORDER_CODE`,
    CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
    COUNT(g.`GOODS_CODE`) AS GOODS_COUNT,
    SUM(g.`QUANTITY`) AS TOTAL_QUANTITY
FROM `ORDER` o
JOIN `CUSTOMER` c ON o.`CUS_CODE` = c.`CUS_CODE`
JOIN `GOODS` g ON o.`ORDER_CODE` = g.`ORDER_CODE`
GROUP BY o.`ORDER_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`
HAVING COUNT(g.`GOODS_CODE`) > 1
ORDER BY GOODS_COUNT DESC, o.`ORDER_CODE`;

-- VIEW:
SELECT * FROM `ORDERS_WITH_MULTIPLE_GOODS`;

-- 44. Liệt kê tài xế đang phụ trách chuyến hàng
CREATE VIEW DRIVERS_WITH_SHIPMENTS AS
SELECT DISTINCT
    e.`EMP_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
    b.`BRANCH_NAME`,
    e.`EMP_PHONE`
FROM `EMPLOYEE` e
JOIN `BRANCH` b ON e.`BRANCH_CODE` = b.`BRANCH_CODE`
JOIN `SHIPMENT` s ON e.`EMP_CODE` = s.`EMP_CODE`
WHERE e.`EMP_JOB` = 'Driver'
ORDER BY b.`BRANCH_NAME`, DRIVER_NAME;

-- VIEW:
SELECT * FROM `DRIVERS_WITH_SHIPMENTS`;

-- 45. Liệt kê chuyến hàng đã hoàn thành
CREATE VIEW COMPLETED_SHIPMENTS AS
SELECT
    s.`SHIP_CODE`,
    s.`ORDER_CODE`,
    CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
    s.`SHIP_DATE`,
    s.`WAREHOUSE_CODE`
FROM `SHIPMENT` s
JOIN `EMPLOYEE` e ON s.`EMP_CODE` = e.`EMP_CODE`
WHERE s.`SHIP_STATUS` = 'Completed'
ORDER BY s.`SHIP_DATE` DESC;

-- VIEW:
SELECT * FROM `COMPLETED_SHIPMENTS`;

-- 46. Liệt kê đơn hàng đã vào kho
CREATE VIEW ORDERS_STORED_IN_WAREHOUSE AS
SELECT DISTINCT
    o.`ORDER_CODE`,
    o.`ORDER_STATUS`,
    owl.`WAREHOUSE_CODE`,
    owl.`STORAGE_DATE`,
    owl.`STORAGE_STATUS`
FROM `ORDER` o
JOIN `ORDER_WAREHOUSE_LOG` owl ON o.`ORDER_CODE` = owl.`ORDER_CODE`
ORDER BY owl.`STORAGE_DATE` DESC;

-- VIEW:
SELECT * FROM `ORDERS_STORED_IN_WAREHOUSE`;

-- 47. Liệt kê loại hàng có tổng khối lượng cao hơn trung bình
CREATE VIEW GOODS_TYPE_ABOVE_AVG_WEIGHT AS
SELECT
    g.`GOODS_TYPE`,
    COUNT(g.`GOODS_CODE`) AS GOODS_COUNT,
    SUM(g.`WEIGHT`) AS TOTAL_WEIGHT
FROM `GOODS` g
GROUP BY g.`GOODS_TYPE`
HAVING SUM(g.`WEIGHT`) > (
    SELECT AVG(TYPE_WEIGHT)
    FROM (
        SELECT SUM(g2.`WEIGHT`) AS TYPE_WEIGHT
        FROM `GOODS` g2
        GROUP BY g2.`GOODS_TYPE`
    ) goods_weight
)
ORDER BY TOTAL_WEIGHT DESC;

-- VIEW:
SELECT * FROM `GOODS_TYPE_ABOVE_AVG_WEIGHT`;

-- 48. Liệt kê chi nhánh có nhiều xe hơn mức trung bình
CREATE VIEW BRANCH_ABOVE_AVG_VEHICLE_COUNT AS
SELECT
    b.`BRANCH_CODE`,
    b.`BRANCH_NAME`,
    COUNT(v.`VEHICLE_CODE`) AS VEHICLE_COUNT
FROM `BRANCH` b
LEFT JOIN `VEHICLE` v ON b.`BRANCH_CODE` = v.`BRANCH_CODE`
GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`
HAVING COUNT(v.`VEHICLE_CODE`) > (
    SELECT AVG(BRANCH_VEHICLE_COUNT)
    FROM (
        SELECT COUNT(v2.`VEHICLE_CODE`) AS BRANCH_VEHICLE_COUNT
        FROM `BRANCH` b2
        LEFT JOIN `VEHICLE` v2 ON b2.`BRANCH_CODE` = v2.`BRANCH_CODE`
        GROUP BY b2.`BRANCH_CODE`
    ) vehicle_counts
)
ORDER BY VEHICLE_COUNT DESC;

-- VIEW:
SELECT * FROM `BRANCH_ABOVE_AVG_VEHICLE_COUNT`;

-- 49. Liệt kê tài khoản đang hoạt động
CREATE VIEW ACTIVE_ACCOUNTS AS
SELECT
    a.ACCOUNT_ID,
    a.USERNAME,
    r.ROLE_NAME,
    COALESCE(a.EMP_CODE, a.CUS_CODE) AS EMP_CODE,
    CASE
        WHEN a.EMP_CODE IS NOT NULL THEN 'EMPLOYEE'
        ELSE 'CUSTOMER'
    END AS ACCOUNT_TYPE
FROM ACCOUNT a
JOIN ROLE r ON a.ROLE_ID = r.ROLE_ID
WHERE a.IS_ACTIVE = TRUE
ORDER BY ACCOUNT_TYPE DESC, r.ROLE_NAME, a.USERNAME;

-- VIEW:
SELECT * FROM `ACTIVE_ACCOUNTS`;

-- 50. Liệt kê các đơn hàng có phí phụ thu
CREATE VIEW ORDERS_WITH_SURCHARGE AS
SELECT
    o.`ORDER_CODE`,
    o.`ORDER_WEIGHT`,
    o.`SHIPPING_FEE`,
    o.`SURCHARGE`,
    o.`DISCOUNT`,
    o.`TOTAL_AMOUNT`
FROM `ORDER` o
WHERE o.`SURCHARGE` > 0
ORDER BY o.`SURCHARGE` DESC, o.`ORDER_CODE`;

-- VIEW:
SELECT * FROM `ORDERS_WITH_SURCHARGE`;

-- 51. CTE: Đếm số đơn hàng của từng khách hàng
CREATE VIEW CTE_CUSTOMER_ORDER_COUNT AS
WITH CUSTOMER_ORDERS AS (
    SELECT
        c.`CUS_CODE`,
        CONCAT(c.`CUS_FNAME`, ' ', c.`CUS_LNAME`) AS CUSTOMER_NAME,
        COUNT(o.`ORDER_CODE`) AS ORDER_COUNT
    FROM `CUSTOMER` c
    LEFT JOIN `ORDER` o ON c.`CUS_CODE` = o.`CUS_CODE`
    GROUP BY c.`CUS_CODE`, c.`CUS_FNAME`, c.`CUS_LNAME`
)
SELECT
    `CUS_CODE`,
    CUSTOMER_NAME,
    ORDER_COUNT
FROM CUSTOMER_ORDERS
WHERE ORDER_COUNT >= 1
ORDER BY ORDER_COUNT DESC, CUSTOMER_NAME;

-- VIEW:
SELECT * FROM `CTE_CUSTOMER_ORDER_COUNT`;

-- 52. CTE: Tổng doanh thu theo từng chi nhánh
CREATE VIEW CTE_BRANCH_TOTAL_REVENUE AS
WITH BRANCH_ORDERS AS (
    SELECT
        b.`BRANCH_CODE`,
        b.`BRANCH_NAME`,
        SUM(o.`TOTAL_AMOUNT`) AS TOTAL_REVENUE,
        COUNT(DISTINCT o.`ORDER_CODE`) AS ORDER_COUNT
    FROM `BRANCH` b
    JOIN `EMPLOYEE` e ON b.`BRANCH_CODE` = e.`BRANCH_CODE`
    JOIN `SHIPMENT` s ON e.`EMP_CODE` = s.`EMP_CODE`
    JOIN `ORDER` o ON s.`ORDER_CODE` = o.`ORDER_CODE`
    GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`
)
SELECT
    `BRANCH_CODE`,
    `BRANCH_NAME`,
    TOTAL_REVENUE,
    ORDER_COUNT
FROM BRANCH_ORDERS
ORDER BY TOTAL_REVENUE DESC;

-- VIEW:
SELECT * FROM `CTE_BRANCH_TOTAL_REVENUE`;

-- 53. CTE: Tính số chuyến hàng theo tài xế
CREATE VIEW CTE_DRIVER_SHIPMENT_COUNT AS
WITH DRIVER_SHIPMENTS AS (
    SELECT
        e.`EMP_CODE`,
        CONCAT(e.`EMP_FNAME`, ' ', e.`EMP_LNAME`) AS DRIVER_NAME,
        COUNT(s.`SHIP_CODE`) AS SHIPMENT_COUNT
    FROM `EMPLOYEE` e
    LEFT JOIN `SHIPMENT` s ON e.`EMP_CODE` = s.`EMP_CODE`
    WHERE e.`EMP_JOB` = 'Driver'
    GROUP BY e.`EMP_CODE`, e.`EMP_FNAME`, e.`EMP_LNAME`
)
SELECT
    `EMP_CODE`,
    DRIVER_NAME,
    SHIPMENT_COUNT
FROM DRIVER_SHIPMENTS
ORDER BY SHIPMENT_COUNT DESC, DRIVER_NAME;

-- VIEW:
SELECT * FROM `CTE_DRIVER_SHIPMENT_COUNT`;

-- 54. CTE: Tính số xe theo từng chi nhánh
CREATE VIEW CTE_BRANCH_VEHICLE_COUNT AS
WITH BRANCH_VEHICLES AS (
    SELECT
        b.`BRANCH_CODE`,
        b.`BRANCH_NAME`,
        COUNT(v.`VEHICLE_CODE`) AS VEHICLE_COUNT,
        SUM(v.`CAPACITY`) AS TOTAL_CAPACITY
    FROM `BRANCH` b
    LEFT JOIN `VEHICLE` v ON b.`BRANCH_CODE` = v.`BRANCH_CODE`
    GROUP BY b.`BRANCH_CODE`, b.`BRANCH_NAME`
)
SELECT
    `BRANCH_CODE`,
    `BRANCH_NAME`,
    VEHICLE_COUNT,
    TOTAL_CAPACITY
FROM BRANCH_VEHICLES
ORDER BY VEHICLE_COUNT DESC, `BRANCH_NAME`;

-- VIEW:
SELECT * FROM `CTE_BRANCH_VEHICLE_COUNT`;

-- 55. CTE: Tìm kho có số lần lưu trữ cao hơn trung bình
CREATE VIEW CTE_WAREHOUSE_ABOVE_AVG_STORAGE AS
WITH WAREHOUSE_STORAGE_COUNT AS (
    SELECT
        w.`WAREHOUSE_CODE`,
        w.`WAREHOUSE_ADDRESS`,
        COUNT(owl.`ORDER_CODE`) AS STORAGE_COUNT
    FROM `WAREHOUSE` w
    LEFT JOIN `ORDER_WAREHOUSE_LOG` owl ON w.`WAREHOUSE_CODE` = owl.`WAREHOUSE_CODE`
    GROUP BY w.`WAREHOUSE_CODE`, w.`WAREHOUSE_ADDRESS`
)
SELECT
    `WAREHOUSE_CODE`,
    `WAREHOUSE_ADDRESS`,
    STORAGE_COUNT
FROM WAREHOUSE_STORAGE_COUNT
WHERE STORAGE_COUNT > (
    SELECT AVG(STORAGE_COUNT)
    FROM WAREHOUSE_STORAGE_COUNT
)
ORDER BY STORAGE_COUNT DESC, `WAREHOUSE_CODE`;

-- VIEW:
SELECT * FROM `CTE_WAREHOUSE_ABOVE_AVG_STORAGE`;


-- 56. Thống kê số tài khoản đang hoạt động theo vai trò
CREATE VIEW CTE_ROLE_ACTIVE_ACCOUNT_COUNT AS
WITH ROLE_ACCOUNT_STATS AS (
    SELECT
        r.ROLE_ID,
        r.ROLE_NAME,
        COUNT(a.ACCOUNT_ID) AS ACTIVE_ACCOUNTS
    FROM ROLE r
    LEFT JOIN ACCOUNT a ON r.ROLE_ID = a.ROLE_ID AND a.IS_ACTIVE = TRUE
    GROUP BY r.ROLE_ID, r.ROLE_NAME
)
SELECT
    ROLE_ID,
    ROLE_NAME,
    ACTIVE_ACCOUNTS
FROM ROLE_ACCOUNT_STATS
ORDER BY ACTIVE_ACCOUNTS DESC;

-- VIEW:
SELECT * FROM CTE_ROLE_ACTIVE_ACCOUNT_COUNT;

-- 57. Liệt kê tất cả vai trò trong hệ thống
CREATE VIEW ROLE_INFO AS
SELECT
    ROLE_ID,
    ROLE_NAME
FROM ROLE
ORDER BY ROLE_NAME;

-- VIEW:
SELECT * FROM ROLE_INFO;

-- 58. Thống kê số tài khoản theo từng vai trò
CREATE VIEW CTE_ROLE_USER_RATIO AS
WITH ROLE_COUNTS AS (
    SELECT
        r.ROLE_ID,
        r.ROLE_NAME,
        COUNT(a.ACCOUNT_ID) AS USER_COUNT
    FROM ROLE r
    LEFT JOIN ACCOUNT a
        ON r.ROLE_ID = a.ROLE_ID
    GROUP BY r.ROLE_ID, r.ROLE_NAME
)
SELECT
    ROLE_ID,
    ROLE_NAME,
    USER_COUNT
FROM ROLE_COUNTS
WHERE USER_COUNT > 0
ORDER BY USER_COUNT DESC;

-- VIEW:
SELECT * FROM CTE_ROLE_USER_RATIO;

-- 59. Liệt kê các cặp tuyến đường và phương tiện
CREATE VIEW ROUTE_VEHICLE_INFO AS
SELECT
    ROUTE_VEHICLE_CODE,
    ROUTE_CODE,
    VEHICLE_CODE
FROM ROUTE_VEHICLE
ORDER BY ROUTE_CODE;

-- VIEW:
SELECT * FROM ROUTE_VEHICLE_INFO;

-- 60. Thống kê số chuyến vận chuyển của từng cặp đường tuyến đường – phương tiện
CREATE VIEW CTE_ROUTE_VEHICLE_WORKLOAD AS
WITH VEHICLE_TRIPS AS (
    SELECT
        rv.ROUTE_VEHICLE_CODE,
        rv.ROUTE_CODE,
        rv.VEHICLE_CODE,
        COUNT(s.SHIP_CODE) AS TOTAL_TRIPS
    FROM ROUTE_VEHICLE rv
    LEFT JOIN SHIPMENT s
        ON rv.ROUTE_VEHICLE_CODE = s.ROUTE_VEHICLE_CODE
    GROUP BY rv.ROUTE_VEHICLE_CODE,
             rv.ROUTE_CODE,
             rv.VEHICLE_CODE
)
SELECT
    ROUTE_VEHICLE_CODE,
    ROUTE_CODE,
    VEHICLE_CODE,
    TOTAL_TRIPS
FROM VEHICLE_TRIPS
ORDER BY TOTAL_TRIPS DESC;

-- VIEW:
SELECT * FROM CTE_ROUTE_VEHICLE_WORKLOAD;

-- 61. Thống kê số lần cập nhật trạng thái của mỗi đơn hàng
CREATE VIEW CTE_TRACKING_ACTIVITY AS
WITH TRACKING_STATS AS (
    SELECT
        ORDER_CODE,
        COUNT(*) AS TOTAL_LOGS,
        MAX(LOG_TIME) AS LAST_UPDATE
    FROM TRACKING_LOG
    GROUP BY ORDER_CODE
)
SELECT
    ORDER_CODE,
    TOTAL_LOGS,
    LAST_UPDATE
FROM TRACKING_STATS
ORDER BY TOTAL_LOGS DESC,
         LAST_UPDATE DESC;

-- VIEW:
SELECT * FROM CTE_TRACKING_ACTIVITY;