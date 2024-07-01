# SERU Test Database

## Database Schema and Data Entries

### 1. Teachers Table:

Create teachers table :

```sql
CREATE TABLE teachers (
    id INT AUTO_INCREMENT,
    name VARCHAR(100),
    subject VARCHAR(50),
    PRIMARY KEY(id)
    );
```

Insert Data into Teachers Table:

```sql
INSERT INTO teachers (name, subject) VALUES ('Pak Anton', 'Matematika');
INSERT INTO teachers (name, subject) VALUES ('Bu Dina', 'Bahasa Indonesia');
INSERT INTO teachers (name, subject) VALUES ('Pak Eko', 'Biologi');
```

### 2. Classes Table

Create classes table :

```sql
CREATE TABLE classes (
    id INT AUTO_INCREMENT,
    name VARCHAR(50),
    teacher_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);
```

Insert Data into Classes Table:

```sql
INSERT INTO classes (name, teacher_id) VALUES ('Kelas 10A', 1);
INSERT INTO classes (name, teacher_id) VALUES ('Kelas 11B', 2);
INSERT INTO classes (name, teacher_id) VALUES ('Kelas 12C', 3);
```

### 3. Student Table

Create Student Table :

```sql
CREATE TABLE students (
    id INT AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    class_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);
```

Insert Data into Student Table :

```sql
INSERT INTO students (name, age, class_id) VALUES ('Budi', 16, 1);
INSERT INTO students (name, age, class_id) VALUES ('Ani', 17, 2);
INSERT INTO students (name, age, class_id) VALUES ('Candra', 18, 3);
```

## Cases Study

### 1. Tampilkan daftar siswa beserta kelas dan guru yang mengajar kelas tersebut.

```sql
SELECT students.name AS student_name, classes.name AS class_name, teachers.name AS teacher_name
FROM students
JOIN classes ON students.class_id = classes.id
JOIN teachers ON classes.teacher_id = teachers.id;

```

- Query tersebut akan menggabungkan tabel students, classes, dan teachers untuk mendapatkan informasi lengkap tentang siswa, kelas, dan guru yang mengajar di kelas tersebut

### 2. Tampilkan daftar kelas yang diajar oleh guru yang sama.

```sql
SELECT teachers.name AS teacher_name, GROUP_CONCAT(classes.name SEPARATOR ', ') AS class_names
FROM classes
JOIN teachers ON classes.teacher_id = teachers.id
GROUP BY teachers.name
HAVING COUNT(classes.name) > 1;
```

- Query ini akan menggabungkan tabel classes dan teachers, kemudian mengelompokkan berdasarkan nama guru (teachers.name). Hanya guru yang mengajar lebih dari satu kelas yang akan ditampilkan.

### 3. buat query view untuk siswa, kelas, dan guru yang mengajar

- Membuat View :

```sql
CREATE VIEW student_class_teacher AS
SELECT students.name AS student_name,
       classes.name AS class_name,
       teachers.name AS teacher_name
FROM students
JOIN classes ON students.class_id = classes.id
JOIN teachers ON classes.teacher_id = teachers.id;
```

- Setelah VIEW dibuat, kita dapat menggunakannya untuk mendapatkan informasi yang kita butuhkan dengan query sederhana:

```sql
SELECT * FROM student_class_teacher;
```

Penjelasan

- CREATE VIEW student_class_teacher AS: Membuat sebuah VIEW bernama student_class_teacher.
- SELECT students.name AS student_name, classes.name AS class_name, teachers.name AS teacher_name: Memilih kolom-kolom yang diperlukan dari tabel students, classes, dan teachers.
- FROM students JOIN classes ON students.class_id = classes.id JOIN teachers ON classes.teacher_id = teachers.id: Menggabungkan tabel-tabel tersebut berdasarkan kunci relasi yang sesuai.

### 4. buat query yang sama tapi menggunakan store_procedure

- Membuat Stored Procedure :

```sql
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
```

- Memanggil Stored Procedure :

```sql
CALL GetStudentClassTeacher();
```

Penjelasan

- DELIMITER //: Mengubah delimiter dari ; menjadi // untuk memungkinkan pembuatan stored procedure yang mengandung beberapa pernyataan SQL.
- CREATE PROCEDURE GetStudentClassTeacher(): Mendefinisikan sebuah stored procedure bernama GetStudentClassTeacher.
- BEGIN ... END: Menandai awal dan akhir blok pernyataan dalam stored procedure.
- SELECT ...: Query yang sama seperti yang digunakan dalam VIEW, yang memilih kolom dari tabel students, classes, dan teachers, serta melakukan JOIN untuk menggabungkan data yang relevan.
- DELIMITER ;: Mengembalikan delimiter ke ; setelah selesai mendefinisikan stored procedure.

### 5. buat query input, yang akan memberikan warning error jika ada data yang sama pernah masuk

- Membuat Stored Procedure untuk Input Data :

```sql
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
```

- Memanggil Stored Procedure :

```sql
CALL InsertStudent('Budi', 16, 1);
```

Penjelasan

- DELIMITER //: Mengubah delimiter dari ; menjadi // untuk memungkinkan definisi stored procedure yang lebih kompleks.
- CREATE PROCEDURE InsertStudent(...): Mendefinisikan stored procedure InsertStudent dengan tiga parameter input: p_name, p_age, dan p_class_id.
- DECLARE duplicate_count INT;: Mendeklarasikan variabel lokal duplicate_count untuk menyimpan jumlah data duplikat yang ditemukan.
- SELECT COUNT(\*) INTO duplicate_count ...: Menghitung jumlah baris dalam tabel students yang memiliki nama siswa (p_name) dan class_id yang sama dengan parameter yang diberikan.
- IF duplicate_count > 0 THEN ... ELSE ... END IF;: Menggunakan struktur kontrol untuk memutuskan apakah akan melakukan insert data atau menimbulkan error.
- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...': Membuat sinyal SQL untuk menimbulkan error dengan pesan yang ditentukan jika data duplikat ditemukan.
- INSERT INTO students ...: Perintah untuk memasukkan data siswa ke dalam tabel students jika tidak ada duplikat yang ditemukan.
- SELECT '...' AS message;: Mengembalikan pesan sukses setelah data berhasil dimasukkan.
