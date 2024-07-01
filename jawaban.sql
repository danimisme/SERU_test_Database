-- 1. Tampilkan daftar siswa beserta kelas dan guru yang mengajar kelas tersebut.

	SELECT students.name AS nama_siswa, classes.name AS kelas, teachers.name AS nama_guru
	FROM students
	JOIN classes ON students.class_id = classes.id
	JOIN teachers ON classes.teacher_id = teachers.id;

-- 2. Tampilkan daftar kelas yang diajar oleh guru yang sama.

	SELECT teachers.name AS teacher_name, GROUP_CONCAT(classes.name SEPARATOR ', ') AS class_names
    FROM classes
    JOIN teachers ON classes.teacher_id = teachers.id
    GROUP BY teachers.name;

-- 3. buat query view untuk siswa, kelas, dan guru yang mengajar

	CREATE VIEW student_class_teacher AS
	SELECT students.name AS student_name, 
		   classes.name AS class_name, 
		   teachers.name AS teacher_name
	FROM students
	JOIN classes ON students.class_id = classes.id
	JOIN teachers ON classes.teacher_id = teachers.id;
	
    -- memanggil view
	SELECT * FROM student_class_teacher;

-- 4. buat query yang sama tapi menggunakan store_procedure

	DELIMITER //

	CREATE PROCEDURE GetStudentClassTeacher()
	BEGIN
		SELECT students.name AS student_name, 
			   classes.name AS class_name, 
			   teachers.name AS teacher_name
		FROM students
		JOIN classes ON students.class_id = classes.id
		JOIN teachers ON classes.teacher_id = teachers.id;
	END //

	DELIMITER ;
	
    -- memanggil prosedure
	CALL GetStudentClassTeacher();
	
	
-- 5. buat query input, yang akan memberikan warning error jika ada data yang sama pernah masuk

	CREATE PROCEDURE InsertStudent(
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_class_id INT
	)
	BEGIN
		DECLARE duplicate_count INT;
		
		-- Cek apakah student sudah ada
		SELECT COUNT(*)
		INTO duplicate_count
		FROM students
		WHERE name = p_name AND class_id = p_class_id;
		
		-- jika student sudah ada tampilkan pesan
		IF duplicate_count > 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Data siswa dengan nama yang sama sudah ada dalam kelas yang sama.';
		ELSE
			-- Insert student jika belum ada
			INSERT INTO students (name, age, class_id)
			VALUES (p_name, p_age, p_class_id);
			
			SELECT 'Data siswa berhasil dimasukkan.' AS message;
		END IF;
	END //

	DELIMITER ;


    -- memanggil storedprosedured
    CALL InsertStudent('Budi', 16, 1);