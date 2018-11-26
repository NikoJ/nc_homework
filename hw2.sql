/*
1)Написать функцию, которая вернет вложенную таблицу из имен сотрудников заданного подразделения.+
То есть, на вход этой функции передается ID подразделения. +
Учесть в коде, что такого подразделения может не быть и обработать исключительную ситуацию.+
Реализовать выборку через обычный CURSOR и через неявный (for I in (select …)). 
Написать PL/SQL блок, который вызовет вашу функцию и выведет результат на экран. Так же показать, как вызвать эту функцию из Select предложения. 
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE arrayofnames IS
    TABLE OF VARCHAR2(100);
/

CREATE OR REPLACE FUNCTION get_name (
    p_emp_dep_id IN   NUMBER
) RETURN arrayofnames IS
    arr1   arrayofnames;
BEGIN
    SELECT
        first_name
    BULK COLLECT
    INTO arr1
    FROM
        employees
    WHERE
        department_id = p_emp_dep_id;

    RETURN arr1;
END get_name;
/

DECLARE
    arr   arrayofnames := get_name(100);
BEGIN
    FOR i IN arr.first..arr.last LOOP
        dbms_output.put_line(arr(i));
    END LOOP;
END;
/

/*
2)Создать пакет PKG_OPERATIONS. Описать спецификацию:
1. Создать процедуру make которая принимает на вход имя таблицы и название колонокю
2. создать процедуру add_row(table_name VARCHAR2, values VARCHAR2, cols VARCHAR2 := null);
3. Создать еще две процедуры на подобие первой, только для обновления и удаления строк.
4. Создать функцию remove, которая принимает на вход имя таблицы.
5. Создать тело пакета, в котором описать логику работы перечисленных процедур. 
Процедуры должны динамически создавать таблицы, делать все манипуляции с данными и удалять таблицу. Использовать Native Dynamic SQL.
6. Написать блок PL/SQL который вызовет процедуры вашего пакета и создаст таблицы, например: 

make(‘my_contacts’, ‘id number(4), name varchar2(40)');
add_row(‘my_contacts’,’1,’’Andrey Gavrilov’’’, ’id, name’);
upd_row(‘my_contacts’,’name=’’Andrey A. Gavrilov’’’, ‘id=2’);
remove(‘my_contacts’);

Все процедуры должны быть обработаны на возможные исключения. 
При вызове удаления таблицы – вывести количество строк, которые были удалены (использовать неявные курсоры SQL%...)
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE test_pkg IS
    PROCEDURE make (
        table_name    IN            VARCHAR2,
        column_name   IN            VARCHAR2
    );

    PROCEDURE add_row (
        table_name   IN           VARCHAR2,
        values_row   IN           VARCHAR2,
        cols         IN           VARCHAR2
    );

    PROCEDURE upd_row (
        table_name   IN           VARCHAR2,
        column_val   IN           VARCHAR2,
        val          IN           VARCHAR2
    );

    PROCEDURE remove_table (
        table_name IN   VARCHAR2
    );

END test_pkg;
/

CREATE OR REPLACE PACKAGE BODY test_pkg AS

    PROCEDURE make (
        table_name VARCHAR2,
        column_name VARCHAR2
    ) IS
    BEGIN
        EXECUTE IMMEDIATE 'CREATE TABLE '
                          || table_name
                          || '('
                          || column_name
                          || ')';
    EXCEPTION
        WHEN OTHERS THEN
            IF sqlcode = -00904 THEN
                dbms_output.put_line('Неверное имя колонки!');
            ELSIF sqlcode = -00907 THEN
                dbms_output.put_line('Все скобки должны быть парными!');
            ELSIF sqlcode = -00903 THEN
                dbms_output.put_line('Неверное имя таблицы!');
            ELSIF sqlcode = -00955 THEN
                dbms_output.put_line('Таблица с таким именем уже существует!');
            ELSE
                dbms_output.put_line('Ошибка при создании таблицы!');
            END IF;
    END make;

    PROCEDURE add_row (
        table_name   VARCHAR2,
        values_row   VARCHAR2,
        cols         VARCHAR2
    ) IS
    BEGIN
        EXECUTE IMMEDIATE 'INSERT INTO '
                          || table_name
                          || '('
                          || cols
                          || ')'
                          || ' VALUES('
                          || values_row
                          || ')';
    EXCEPTION
        WHEN OTHERS THEN
            IF sqlcode = -00904 THEN
                dbms_output.put_line('Неверное имя колонки!');
            ELSIF sqlcode = -00907 THEN
                dbms_output.put_line('Все скобки должны быть парными!');
            ELSIF sqlcode = -00903 THEN
                dbms_output.put_line('Неверное имя таблицы!');
            ELSIF sqlcode = -00942 THEN
                dbms_output.put_line('Таблицы с таким именем не существует!');
            ELSE
                dbms_output.put_line('Ошибка при добавлении!');
            END IF;
    END add_row;

    PROCEDURE upd_row (
        table_name   VARCHAR2,
        column_val   VARCHAR2,
        val          VARCHAR2
    ) AS
    BEGIN
        EXECUTE IMMEDIATE 'UPDATE '
                          || table_name
                          || ' SET '
                          || column_val
                          || ' WHERE '
                          || val;
    EXCEPTION
        WHEN OTHERS THEN
            IF sqlcode = -00904 THEN
                dbms_output.put_line('Неверное имя колонки!');
            ELSIF sqlcode = -00907 THEN
                dbms_output.put_line('Все скобки должны быть парными!');
            ELSIF sqlcode = -00903 THEN
                dbms_output.put_line('Неверное имя таблицы!');
            ELSIF sqlcode = -00971 THEN
                dbms_output.put_line('missing SET keyword!');
            ELSIF sqlcode = -00942 THEN
                dbms_output.put_line('Таблицы с таким именем не существует!');
            ELSE
                dbms_output.put_line('Ошибка при обновлении!');
            END IF;
    END upd_row;

    PROCEDURE remove_table (
        table_name IN   VARCHAR2
    ) AS
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_name;
    EXCEPTION
        WHEN OTHERS THEN
            IF sqlcode = -00904 THEN
                dbms_output.put_line('Неверное имя колонки!');
            ELSIF sqlcode = -00907 THEN
                dbms_output.put_line('Все скобки должны быть парными!');
            ELSIF sqlcode = -00903 THEN
                dbms_output.put_line('Неверное имя таблицы!');
            ELSIF sqlcode = -00942 THEN
                dbms_output.put_line('Таблицы с таким именем не существует!');
            ELSE
                dbms_output.put_line('Ошибка при удаление!');
            END IF;
    END remove_table;

END test_pkg;
/

BEGIN
    test_pkg.make('my_contacts', 'id number(4), name varchar2(40)');
    dbms_output.put_line('Таблица успешно создана!');
    test_pkg.add_row('my_contacts', '1,''Andrey Gavrilov''', 'id, name');
    dbms_output.put_line('Данные успешно добавлены!');
    test_pkg.upd_row('my_contacts', q'[name='Andrey A. Gavrilov']', 'id=2');
    dbms_output.put_line('Данные успешно обнавлены!');
    test_pkg.remove_table('my_contacts');
    dbms_output.put_line('Данные успешно удалены!');
END;
/
/*
3)Написать PL/SQL блок или SQL запрос, который посчитает количество всех счастливых билетов. Мы знаем, что максимальное число, из которого может получиться счастливый билет – 999999.
*/

SET SERVEROUTPUT ON;

DECLARE
    amount_bilet   NUMBER := 1;
    sum_first      NUMBER := 0;
    sum_second     NUMBER := 0;
    temp           VARCHAR2(255);
    v1             NUMBER := 0;
    v2             NUMBER := 0;
    v3             NUMBER := 0;
    v4             NUMBER := 0;
    v5             NUMBER := 0;
    v6             NUMBER := 0;
BEGIN
    FOR i IN 1..999999 LOOP
        temp := TO_CHAR(i);
        v1 := to_number(substr(temp, 1, 1));
        v2 := to_number(substr(temp, 2, 1));
        v3 := to_number(substr(temp, 3, 1));
        sum_first := v1 + v2 + v3;
        IF ( to_number(substr(temp, 4, 1)) > -1 ) THEN
            v4 := to_number(substr(temp, 4, 1));
        END IF;

        IF ( to_number(substr(temp, 5, 1)) > -1 ) THEN
            v5 := to_number(substr(temp, 5, 1));
        END IF;

        IF ( to_number(substr(temp, 6, 1)) > -1 ) THEN
            v6 := to_number(substr(temp, 6, 1));
        END IF;

        sum_second := v4 + v5 + v6;
        IF ( sum_first = sum_second ) THEN
            amount_bilet := amount_bilet + 1;
        END IF;
        sum_first := 0;
        sum_second := 0;
        v1 := 0;
        v2 := 0;
        v3 := 0;
        v4 := 0;
        v5 := 0;
        v6 := 0;
    END LOOP;

    dbms_output.put_line('Итого: ' || TO_CHAR(amount_bilet));
END;
/


/*
4)Создать триггер и последовательность (sequence) на вставку данных в таблицу 
(создать свою таблицу, с любым набором полей, но чтобы там был PK_ID который не может быть пустым или null). 
Триггер должен реагировать, когда происходит вставка в вашу таблицу и записывать в поле PK_ID очередное уникальное значение из последовательности (nextval).
Написать PL/SQL блок или обычный вызов Insert предложения в вашу таблицу для демонстрации, как работает триггер. 
На вход НЕ должно быть подано значение PK_ID, оно должно генерится автоматически.
*/

CREATE TABLE usrs (
    id         NUMBER(10)
        CONSTRAINT usrs_id_pk PRIMARY KEY,
    name       VARCHAR2(50)
        CONSTRAINT usrs_name_nn NOT NULL,
    password   VARCHAR2(50)
);
/

CREATE SEQUENCE new_id_urs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/

CREATE OR REPLACE TRIGGER id_trg BEFORE
    INSERT ON usrs
    FOR EACH ROW
BEGIN
    :new.id := new_id_urs.nextval;
END;
/

    INSERT INTO usrs (
        name,
        password
    ) VALUES (
        'John',
        '16g1b382'
    );
/

    INSERT INTO usrs (
        name,
        password
    ) VALUES (
        'Sam',
        '123'
    );
/

SELECT
    *
FROM
    usrs;
/