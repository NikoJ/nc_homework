--Использовал СУБД PostgreSQL

--Create table(не забывайте про первичный ключи, ограничения, внешние ключи и т.д. и т.п.).

CREATE TABLE attr_types (
  attr_type_id INTEGER PRIMARY KEY,
  name         VARCHAR(255) NOT NULL,
  properties   VARCHAR(255)
);

CREATE TABLE attr_groups (
  attr_group_id INTEGER PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  properties    VARCHAR(255)
);

CREATE TABLE attributes (
  attr_id       INTEGER PRIMARY KEY,
  attr_type_id  INTEGER REFERENCES attr_types,
  attr_group_id INTEGER REFERENCES attr_groups,
  name          VARCHAR(255) NOT NULL,
  description   TEXT,
  ismultiple    BOOLEAN,
  properties    VARCHAR(255)
);

CREATE TABLE object_types (
  object_type_id INTEGER PRIMARY KEY,
  parent_id      INTEGER REFERENCES object_types,
  name           VARCHAR(255) NOT NULL,
  description    TEXT,
  properties     VARCHAR(255)
);

CREATE TABLE attr_binds (
  object_type_id INTEGER REFERENCES object_types,
  attr_id        INTEGER REFERENCES attributes,
  options        VARCHAR(255),
  isrequired     BOOLEAN,
  deafult_value  VARCHAR(255),
  PRIMARY KEY (object_type_id, attr_id)
);

CREATE TABLE objects (
  object_id      INTEGER PRIMARY KEY,
  parent_id      INTEGER REFERENCES objects,
  object_type_id INTEGER REFERENCES object_types,
  name           VARCHAR(255) NOT NULL,
  description    TEXT,
  order_number   INTEGER
);

CREATE TABLE params (
  attr_id    INTEGER REFERENCES attributes,
  object_id  INTEGER REFERENCES objects,
  value      VARCHAR(255),
  date_value TIMESTAMP,
  show_order INTEGER
);

CREATE TABLE refrences (
  attr_id    INTEGER REFERENCES attributes,
  object_id  INTEGER REFERENCES objects,
  reference  INTEGER REFERENCES objects,
  show_order INTEGER
);

--Insert в таблички(больше 5 записей не надо делать).

INSERT INTO attr_types VALUES
  (1, 'Dots per Inch', 'prop 1'),
  (2, 'Pages per Minute', 'prop 2'),
  (3, 'Name', 'prop 3'),
  (4, 'Frequency', 'prop 4'),
  (5, 'Color', 'prop 5'),
  (6, 'Number of Colors', 'prop 6'),
  (7, 'Object reference', 'prop 7');

INSERT INTO attr_groups VALUES
  (1, 'MRS technique', 'prop 1'),
  (2, 'UPT technique', 'prop 2'),
  (3, 'NTP technique', 'prop 3'),
  (4, 'VNR technique', 'prop 4'),
  (5, 'PLT technique', 'prop 5');

INSERT INTO attributes VALUES
  (1, 1, 1, 'dpi', 'description 1', FALSE, 'prop 1'),
  (2, 2, 2, 'ppm', 'description 2', FALSE, 'prop 2'),
  (3, 3, 3, 'networkName', 'description 3', TRUE, 'prop 3'),
  (4, 4, 4, 'CPUfrequency', 'description 4', FALSE, 'prop 4'),
  (5, 5, 5, 'inkColor', 'description 5', FALSE, 'prop 5'),
  (6, 6, 5, 'colorsCount', 'description 6', FALSE, 'prop 6'),
  (7, 7, 4, 'Computer-Printer', 'description 7', TRUE, 'prop 7'),
  (8, 4, 3, 'printFreq', 'description 8', FALSE, 'prop 8');

INSERT INTO object_types VALUES
  (1, NULL, 'Computer', 'Компьютер', 'prop 1'),
  (2, NULL, 'Printer', 'Принтер', 'prop 2'),
  (3, 2, 'Inkjet Printer', 'Струйный принтер', 'prop 3'),
  (4, NULL, 'Head', 'Головка принтера', 'prop 4'),
  (5, NULL, 'ImageSetter', 'Фотонаборный автомат', 'prop 5');

INSERT INTO attr_binds VALUES
  (2, 1, 'Printer dpi', TRUE, NULL),
  (5, 1, 'ImageSetter dpi', TRUE, NULL),
  (2, 2, 'Printer ppm', TRUE, NULL),
  (3, 6, 'Number of InkJet Colors', FALSE, NULL),
  (4, 5, 'Color of Head', FALSE, NULL),
  (1, 3, 'Computer Name', TRUE, NULL),
  (1, 4, 'Computer Frequency', TRUE, NULL),
  (1, 7, 'Connected Printer', TRUE, NULL);

INSERT INTO objects VALUES
  (1, NULL, 1, 'MyComp', NULL, NULL),
  (2, NULL, 3, 'MyPrinter', 'HP DeskJet', NULL),
  (3, 2, 4, 'Head1', NULL, NULL),
  (4, 2, 4, 'Head2', NULL, NULL),
  (5, 2, 4, 'Head3', NULL, NULL),
  (6, 2, 4, 'Head4', NULL, NULL),
  (7, NULL, 2, 'NetPrinter', 'HP LaserJet', NULL);

INSERT INTO refrences VALUES
  (7, 1, 2, NULL),
  (7, 1, 7, NULL);

INSERT INTO params VALUES
  (3, 1, 'MyComputer', NULL, NULL),
  (3, 1, 'Ivanov', NULL, NULL),
  (4, 1, '2.6', NULL, NULL),
  (1, 2, '600', NULL, NULL),
  (2, 2, '3', NULL, NULL),
  (6, 2, '4', NULL, NULL),
  (5, 3, 'Cyan', NULL, NULL),
  (5, 4, 'Magenta', NULL, NULL),
  (5, 5, 'Yellow', NULL, NULL),
  (5, 6, 'Black', NULL, NULL),
  (1, 7, '1200', NULL, NULL),
  (2, 7, '30', NULL, NULL);

--Select’ы
--1 Получение информации обо всех атрибутах(учитывая только атрибутную группу и атрибутные типы)(attr_id, attr_name, attr_group_id, attr_group_name, attr_type_id, attr_type_name)
SELECT
  attr.attr_id       AS attr_id,
  attr.name          AS attr_name,
  attr.attr_group_id AS attr_group_id,
  ag.name            AS attr_group_name,
  attr.attr_type_id  AS attr_type_id,
  at.name            AS attr_type_name
FROM attributes attr
  RIGHT JOIN attr_groups ag
    ON attr.attr_group_id = ag.attr_group_id
  RIGHT JOIN attr_types at
    ON attr.attr_type_id = at.attr_type_id;

--2  Получение всех атрибутов для заданного объектного типа, без учета наследования(attr_id, attr_name )
SELECT
  a.attr_id AS attr_id,
  a.name    AS attr_name
FROM attributes a
  INNER JOIN attr_binds ab
    ON a.attr_id = ab.attr_id
WHERE ab.object_type_id = 1;

--3 Получение иерархии ОТ(объектных типов)  для заданного объектного типа(нужно получить иерархию наследования) (ot_id, ot_name, LEVEL )
WITH RECURSIVE r AS (
  SELECT
    ot.object_type_id,
    ot.name,
    1 AS LEVEL
  FROM object_types ot
  WHERE ot.object_type_id = 2

  UNION

  SELECT
    rot.object_type_id,
    rot.name,
    r.level + 1 AS LEVEL
  FROM object_types rot
    JOIN r
      ON rot.parent_id = r.object_type_id
)

SELECT *
FROM r;

--4 Получение вложенности объектов для заданного объекта(нужно получить иерархию вложенности)(obj_id, obj_name, LEVEL )
WITH RECURSIVE r2 AS (
  SELECT
    ob.object_id,
    ob.name,
    1 AS LEVEL
  FROM objects ob
  WHERE ob.object_id = 2

  UNION

  SELECT
    rob.object_id,
    rob.name,
    r2.LEVEL + 1 AS level
  FROM objects rob
    JOIN r2
      ON rob.parent_id = r2.object_id
)

SELECT
  object_id AS obj_id,
  name      AS obj_name,
  LEVEL
FROM r2;

--5 Получение объектов заданного объектного типа(учитывая только наследование ОТ)(ot_id, ot_name, obj_id, obj_name)
WITH RECURSIVE r3 AS (
  SELECT
    ot.object_type_id,
    ot.name
  FROM object_types ot
  WHERE ot.object_type_id = 2

  UNION

  SELECT
    rot.object_type_id,
    rot.name
  FROM object_types rot
    JOIN r3
      ON rot.parent_id = r3.object_type_id
)

SELECT
  rec.object_type_id AS ot_id,
  rec.name           AS ot_name,
  ob.object_id       AS obj_id,
  ob.name            AS obj_name
FROM objects ob
  INNER JOIN r3 rec
    ON ob.object_type_id = rec.object_type_id;

--6 Получение значений всех атрибутов(всех возможных типов) для заданного объекта(без учета наследования ОТ)(attr_id, attr_name, VALUE )
SELECT
  a.attr_id,
  a.name AS attr_name,
  p.VALUE
FROM attributes a
  RIGHT JOIN params p
    ON a.attr_id = p.attr_id
WHERE p.object_id = 1;

--7 Получение ссылок на заданный объект(все объекты, которые ссылаются на текущий)(ref_id, ref_name)
SELECT
  ref.reference AS ref_id,
  o.name        AS ref_name
FROM refrences ref
  RIGHT JOIN objects o
    ON ref.reference = o.object_id
WHERE ref.object_id = 1;

--8 Получение значений всех атрибутов(всех возможных типов, без повторяющихся атрибутов) для заданного объекта( с учетом наследования ОТ) Вывести в виде см.п.6
WITH RECURSIVE r8 AS (
  SELECT
    ob.object_id,
    ob.object_type_id,
    ob.name
  FROM objects ob
  WHERE ob.object_id = 2

  UNION

  SELECT
    rob.object_id,
    rob.object_type_id,
    rob.name
  FROM objects rob
    JOIN r8
      ON rob.parent_id = r8.object_id
)

SELECT DISTINCT ON (a.attr_id)
  a.attr_id,
  a.name AS attr_name,
  p.VALUE
FROM r8
  LEFT JOIN params p
    ON p.object_id = r8.object_id
  LEFT JOIN attributes a ON p.attr_id = a.attr_id
ORDER BY a.attr_id;

--круто, когда есть скрипт, который после проверки удалит все, созданные объекты из БД
TRUNCATE attr_groups, attr_types, object_types CASCADE;