CREATE OR REPLACE PACKAGE exhibition_pkg IS
  -- Версия функции, принимающая год и месяц в виде NUMBER
  FUNCTION count_exhibitions( p_year NUMBER, p_month NUMBER ) RETURN NUMBER;

  -- Версия функции, принимающая месяц в виде VARCHAR
  FUNCTION count_exhibitions( p_month VARCHAR2 ) RETURN NUMBER;

  -- Локальная функция для преобразования названия месяца в число
  FUNCTION MESYATS_TO_INT (NAME IN VARCHAR2) RETURN INTEGER;

  -- Процедура для получения экспонатов авторов с более чем 4 работами
  PROCEDURE GetExhibitsByAuthors;
END exhibition_pkg;
/

CREATE OR REPLACE PACKAGE BODY exhibition_pkg IS
  -- Версия функции, принимающая год и месяц в виде NUMBER
  FUNCTION count_exhibitions(
    p_year NUMBER,
    p_month NUMBER
  ) RETURN NUMBER IS
    v_count NUMBER;
    ILLEGAL_MONTH EXCEPTION;

    CURSOR c_exhibitions IS
      SELECT COUNT(*) AS exhibition_count
      FROM exhibition
      WHERE EXTRACT(YEAR FROM dateOfBegginig) = p_year
      AND EXTRACT(MONTH FROM dateOfBegginig) = p_month;
  BEGIN
    -- Инициализация
    v_count := 0;

     IF p_month < 1 OR p_month > 12 THEN
     RAISE ILLEGAL_MONTH;
     END IF;

    -- Открытие курсора
    OPEN c_exhibitions;

    -- Получение результата
    FETCH c_exhibitions INTO v_count;

    -- Закрытие курсора
    CLOSE c_exhibitions;

    -- Обработка исключительных ситуаций
    
      DBMS_OUTPUT.PUT_LINE('Количество выставок в указанном месяце и году: ' || v_count);
      RETURN v_count;
   
  EXCEPTION
        WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Incorrect input');
        RETURN -1;

  WHEN ILLEGAL_MONTH THEN
        DBMS_OUTPUT.PUT_LINE('MONTH IS NOT CORRECT');
        RETURN -1;

    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      RETURN 0;
  END count_exhibitions;

  -- Версия функции, принимающая месяц в виде VARCHAR
  FUNCTION count_exhibitions(
    p_month VARCHAR2
  ) RETURN NUMBER IS
    v_count NUMBER;
    p_month_number NUMBER; -- Переменная для хранения числа месяца   
   

    CURSOR c_exhibitions IS
      SELECT COUNT(*) AS exhibition_count
      FROM exhibition
      WHERE EXTRACT(MONTH FROM dateOfBegginig) = p_month_number;
  BEGIN
    -- Преобразование месяца в число с использованием локальной функции MESYATS_TO_INT
    p_month_number := MESYATS_TO_INT(p_month);
    -- Инициализация
    v_count := 0;


    -- Открытие курсора
    OPEN c_exhibitions;

    -- Получение результата
    FETCH c_exhibitions INTO v_count;

    -- Закрытие курсора
    CLOSE c_exhibitions;

    -- Обработка исключительных ситуаций
      DBMS_OUTPUT.PUT_LINE('Количество выставок в указанном месяце: ' || v_count);
      RETURN v_count;

  EXCEPTION    
      WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Incorrect input');
        RETURN -1;

    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      RETURN 0;

  END count_exhibitions;

  -- Локальная функция для преобразования названия месяца в число
  FUNCTION MESYATS_TO_INT (NAME IN VARCHAR2) RETURN INTEGER IS
    NOT_NAME EXCEPTION;
    STR VARCHAR2(20);
  BEGIN
    STR := UPPER(NAME); -- регистр не учитываем
    CASE
      WHEN STR IN ('ЯНВАРЬ','JANUARY','JAN') THEN RETURN 1;
      WHEN STR IN ('ФЕВРАЛЬ','FEBRUARY','FEB') THEN RETURN 2;
      WHEN STR IN ('МАРТ','MARCH','MAR') THEN RETURN 3;
      WHEN STR IN ('АПРЕЛЬ','APRIL','APR') THEN RETURN 4;
      WHEN STR IN ('МАЙ','MAY','MAY') THEN RETURN 5;
      WHEN STR IN ('ИЮНЬ','JUNE','JUN') THEN RETURN 6;
      WHEN STR IN ('ИЮЛЬ','JULY','JUL') THEN RETURN 7;
      WHEN STR IN ('АВГУСТ','AUGUST','AUG') THEN RETURN 8;
      WHEN STR IN ('СЕНТЯБРЬ','SEPTEMBER','SEP') THEN RETURN 9;
      WHEN STR IN ('ОКТЯБРЬ','OCTOBER','OCT') THEN RETURN 10;
      WHEN STR IN ('НОЯБРЬ','NOVEMBER','NOV') THEN RETURN 11;
      WHEN STR IN ('ДЕКАБРЬ','DECEMBER','DEC') THEN RETURN 12;
      ELSE RAISE NOT_NAME;
    END CASE;
    EXCEPTION
    WHEN NOT_NAME THEN
      DBMS_OUTPUT.PUT_LINE('BAD INPUT');
      RETURN -1; -- условная ошибка
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR');
      RETURN -1; -- условная ошибка 
  END MESYATS_TO_INT;

  -- Процедура для получения экспонатов авторов с более чем 4 работами
  PROCEDURE GetExhibitsByAuthors AS
    -- Объявление явного курсора
    CURSOR author_cursor IS
        SELECT authorKey, lastName FROM author;

    -- Объявление курсорных переменных
    author_rec author_cursor%ROWTYPE;
    author_exhibits_count NUMBER;

  BEGIN
      OPEN author_cursor; -- Открываем курсор

      -- Перебираем записи авторов
      LOOP
          BEGIN
              FETCH author_cursor INTO author_rec;
              EXIT WHEN author_cursor%NOTFOUND;

              -- Подсчитываем количество экспонатов автора
              SELECT COUNT(*) INTO author_exhibits_count
              FROM exhibits
              WHERE authorKey = author_rec.authorKey;

              -- Проверяем, что у автора есть не менее чем 4 работы
              IF author_exhibits_count >= 3 THEN
                  -- Выводим информацию об экспонатах автора
                  DBMS_OUTPUT.PUT_LINE('Автор: ' || author_rec.lastName);

                  -- Открываем вложенный курсор для получения экспонатов автора
                  FOR exhibit_rec IN (SELECT exhibitsName FROM exhibits WHERE authorKey = author_rec.authorKey) LOOP
                      DBMS_OUTPUT.PUT_LINE('Экспонат: ' || exhibit_rec.exhibitsName);
                  END LOOP;

                  DBMS_OUTPUT.PUT_LINE('Всего экспонатов: ' || author_exhibits_count);
                 
              END IF;               

          END;
      END LOOP;


      CLOSE author_cursor; -- Закрываем курсор
     -- Обрабатываем ошибку, если она есть
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);

  END GetExhibitsByAuthors;

END exhibition_pkg;
/


DECLARE
  v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE('FUNCTION OUTPUT');
    DBMS_OUTPUT.PUT_LINE('----------------');  

    v_count := exhibition_pkg.count_exhibitions(2023, 3);
    v_count := exhibition_pkg.count_exhibitions(2023, 20);
    v_count := exhibition_pkg.count_exhibitions(2020, 3);

    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE('PROCEDURE OUTPUT');
    DBMS_OUTPUT.PUT_LINE('----------------');

    exhibition_pkg.GetExhibitsByAuthors;

    DBMS_OUTPUT.PUT_LINE('--------------------------');
    DBMS_OUTPUT.PUT_LINE('OVERLOADED FUNCTION OUTPUT');
    DBMS_OUTPUT.PUT_LINE('--------------------------');


    v_count := exhibition_pkg.count_exhibitions('may');
    v_count := exhibition_pkg.count_exhibitions('jul');
    v_count := exhibition_pkg.count_exhibitions('vbdhvbdhv');
    v_count := exhibition_pkg.count_exhibitions(2);
END;
/

delete from exhibits where exhibitsName = 'Мона Лиза';
delete from exhibits where exhibitsName = 'Вася';

insert into exhibits(exhibitsName,authorKey,themeKey,worth) values('Мона Лиза',2,1,5);
insert into exhibits(exhibitsName,authorKey,themeKey,worth) values('Вася',3,1,4);