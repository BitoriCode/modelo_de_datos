-- Datos ilustrativos de la nota de álgebra, no un caso biográfico.
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS people;
CREATE TABLE people (id INT PRIMARY KEY, first_name TEXT, last_name TEXT, birth_date DATE, genre CHAR(1), company TEXT);
CREATE TABLE products (id TEXT PRIMARY KEY, name TEXT, brand TEXT, inventory INT);
INSERT INTO people VALUES
(1, 'BILL', 'GATES', '1955-10-28', 'M', 'MICROSOFT'),
(2, 'STEVE', 'JOBS', '1955-02-24', 'M', 'APPLE'),
(3, 'ELON', 'MUSK', '1971-06-28', 'M', 'TESLA'),
(4, 'SERGEI', 'BRIN', '1973-08-21', 'M', 'GOOGLE'),
(5, 'LARRY', 'PAGE', '1973-03-26', 'M', 'GOOGLE'),
(6, 'MICHELLE', 'ZATLYN', NULL, 'F', 'CLOUDFLARE'),
(7, 'MELANIE', 'PERKINS', '1987-05-13', 'F', 'CANVA'),
(8, 'MIKE', 'WONG', NULL, 'M', 'SUNFOUNDER');
INSERT INTO products VALUES
('A1', 'ARDUINO UNO', 'ARDUINO', 750),
('AM', 'ARDUINO MINI', 'ARDUINO', 50),
('WD1M', 'WEMOS D1 MINI', 'LOLIN', 1500),
('WD1P', 'WEMOS D1 MINI PRO', 'LOLIN', 100),
('BME280', 'SENSOR BME 280', 'SUNFOUNDER', 50),
('PIR-01', 'SENSOR DE MOVIMIENTO', 'SUNFOUNDER', 430),
('ROT01', 'SENSOR ROTATORIO', 'SUNFOUNDER', 500);
