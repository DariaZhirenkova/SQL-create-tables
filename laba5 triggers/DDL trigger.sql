CREATE TABLE LOG2 (
  TABLE_NAME VARCHAR2(30),
  ACTION_TYPE VARCHAR2(10),
  USERNAME VARCHAR2(50),
  ACTION_DATE TIMESTAMP
);

CREATE OR REPLACE TRIGGER DDL_TRIGGER
BEFORE CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
  curr_time TIMESTAMP;
BEGIN
  SELECT SYSTIMESTAMP AT TIME ZONE 'Europe/Moscow' INTO curr_time FROM DUAL;

  -- Проверка времени
  IF TO_CHAR(curr_time, 'HH24:MI') between '09:00' and '18:00' THEN
    -- Протоколирование действия
    INSERT INTO LOG2 (TABLE_NAME, ACTION_TYPE, USERNAME,ACTION_DATE)
    VALUES (ora_dict_obj_name, ora_sysevent,USER,curr_time);
  ELSE
    -- Запрет действия
    RAISE_APPLICATION_ERROR(-20001, 'Попробуйте снова в рабочее время с 9:00 до 18:00');
  END IF;
END;
/
