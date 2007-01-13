
CREATE TABLE IF NOT EXISTS my_table (
id 	INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
field1 	VARCHAR(100),
field2	TEXT,
field3	DATETIME );

INSERT INTO my_table VALUES (1, "test one", "this is a longer field", "12/12/04");
INSERT INTO my_table VALUES (2, "test one two", "this is a longer field 123", "1/1/02");
INSERT INTO my_table VALUES (3, "test one three", "this is a longer field 321412", "2/2/02");
INSERT INTO my_table VALUES (4, "test one twenty", "this is a longer field 4324123", "5/21/02");
INSERT INTO my_table VALUES (5, "test one house", "this is a longer field 16256", "4/1/01");
INSERT INTO my_table VALUES (6, "test one cat", "this is a longer field 45984", "2/21/99");
INSERT INTO my_table VALUES (7, "test one mouse", "this is a longer field 34821934", "8/11/04");
INSERT INTO my_table VALUES (8, "test one perro", "this is a longer field 4813948", "10/29/12");

CREATE TABLE IF NOT EXISTS friends (
last_name	VARCHAR(200),
first_name	VARCHAR(200) );

INSERT INTO friends VALUES ("Verderkauf", "Hans");
INSERT INTO friends VALUES ("Esperago", "Manuel");
INSERT INTO friends VALUES ("Bobochi", "Mandula");
INSERT INTO friends VALUES ("Lee", "Pu");
INSERT INTO friends VALUES ("Sankyu", "Hichi");
INSERT INTO friends VALUES ("Smith", "Fred");

