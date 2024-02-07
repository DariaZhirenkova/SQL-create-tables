--1.Запретить выставлять один экспонат на две выставки одновременно;
--2.Контролировать количество экспонатов на каждой выставке.

CREATE OR REPLACE TRIGGER prevent_duplicate_exhibit_and_control_count
BEFORE INSERT ON basket
FOR EACH ROW
DECLARE
    exhibit_count NUMBER;
    date1 DATE;
    date2 DATE;
    max_exhibits_per_exhibition CONSTANT INTEGER := 4; -- Adjust the maximum number as needed
BEGIN
    -- Проверка на наличие экспоната на другой выставке в тот же период

    SELECT dateOfBegginig into date1 from exhibition where exhibitionKey = :NEW.exhibitionKey;
    SELECT dateOfEnding into date2 from exhibition where exhibitionKey = :NEW.exhibitionKey;
    SELECT COUNT(*)
    INTO exhibit_count
    FROM basket b
    JOIN exhibition e ON b.exhibitionKey = e.exhibitionKey
    WHERE b.exhibitsKey = :NEW.exhibitsKey 
     AND (
        (e.dateOfBegginig <= date2 AND e.dateOfEnding >= date1)
        OR
        (date1 <= e.dateOfEnding AND date2 >= e.dateOfBegginig)
      );

    IF exhibit_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Этот экспонат уже участвует в другой выставке в тот же период.');
    END IF;

    -- Проверка на превышение максимального количества экспонатов на выставке
    SELECT COUNT(*)
    INTO exhibit_count
    FROM basket
    WHERE exhibitionKey = :NEW.exhibitionKey;

    IF exhibit_count >= max_exhibits_per_exhibition THEN
        RAISE_APPLICATION_ERROR(-20002, 'Превышено максимальное количество экспонатов на выставке.');
    END IF;
END;
/

delete from basket where exhibitionKey=3 and exhibitsKey=1
insert into basket values(11,5)


--3.Если выставка закончилась, то во вспомогательной таблице обновлять «коэффициент выставляемости» по каждому экспонату.

CREATE TABLE coefficient_table (
    exhibitKey INTEGER,
    authorKey INTEGER,
    exhibit_coefficient NUMBER(5,2),
    FOREIGN KEY (exhibitKey) REFERENCES exhibits(exhibitsKey) ON DELETE CASCADE,
    FOREIGN KEY (authorKey) REFERENCES author(authorKey) ON DELETE CASCADE
);

drop table coefficient_table

CREATE OR REPLACE PROCEDURE UpdateExhibitCoefficientsProcedure(
    p_exhibition_key IN NUMBER
)
IS
    v_exhibition_end_date DATE;
    v_record_count NUMBER;
BEGIN
    -- Получаем дату окончания выставки
    SELECT dateOfEnding INTO v_exhibition_end_date
    FROM exhibition
    WHERE exhibitionKey = p_exhibition_key;

    -- Проверяем, закончилась ли выставка
    IF v_exhibition_end_date IS NOT NULL AND v_exhibition_end_date <= SYSDATE THEN
        -- Обновляем коэффициенты для экспонатов участвующих в выставке
        FOR exhibit_rec IN (SELECT DISTINCT exhibitsKey FROM basket WHERE exhibitionKey = p_exhibition_key) 
        LOOP
            -- Проверяем количество записей в coefficient_table для текущего экспоната
            SELECT COUNT(*) INTO v_record_count
            FROM coefficient_table
            WHERE exhibitKey = exhibit_rec.exhibitsKey;

            IF v_record_count > 0 THEN
                -- Обновляем коэффициент, если запись уже существует
                UPDATE coefficient_table
                SET
                    exhibit_coefficient = calculate_exhibit_coeff(exhibit_rec.exhibitsKey)
                WHERE
                    exhibitKey = exhibit_rec.exhibitsKey;
            ELSE
                -- Вставляем новую запись, если запись не существует
                INSERT INTO coefficient_table (exhibitKey, authorKey, exhibit_coefficient)
                SELECT
                    e.exhibitsKey,
                    au.authorKey,
                    calculate_exhibit_coeff(e.exhibitsKey) AS exhibit_coefficient
                FROM
                    exhibits e
                    JOIN author au ON e.authorKey = au.authorKey
                WHERE
                    e.exhibitsKey = exhibit_rec.exhibitsKey;
            END IF;
        END LOOP;
    END IF;
    COMMIT;
END UpdateExhibitCoefficientsProcedure;
/


select * from coefficient_table

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'UPDATE_EXHIBIT_COEFF_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                            UpdateExhibitCoefficientsProcedure(1);
                            UpdateExhibitCoefficientsProcedure(2);
                            UpdateExhibitCoefficientsProcedure(3);
                            UpdateExhibitCoefficientsProcedure(4);
                            UpdateExhibitCoefficientsProcedure(5);
                            UpdateExhibitCoefficientsProcedure(6);
                            UpdateExhibitCoefficientsProcedure(7);
                            UpdateExhibitCoefficientsProcedure(12);
                            UpdateExhibitCoefficientsProcedure(13);
                            END;',
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
        enabled         => TRUE
    );
END;
/


SELECT log_date, status, error#
FROM user_scheduler_job_run_details
WHERE job_name = 'UPDATE_EXHIBIT_COEFF_JOB';


select * from coefficient_table 

CREATE OR REPLACE FUNCTION calculate_exhibit_coeff(p_exhibitsKey INTEGER)
RETURN NUMBER IS
    v_total_participations INTEGER;
    v_coeff NUMBER;
BEGIN
    -- Получаем общее количество участий экспоната в завершенных выставках
    SELECT COUNT(*) INTO v_total_participations
    FROM basket b
    JOIN exhibition e ON b.exhibitionKey = e.exhibitionKey
    WHERE b.exhibitsKey = p_exhibitsKey
      AND e.dateOfEnding IS NOT NULL
      AND e.dateOfEnding <= SYSDATE;

    -- Рассчитываем коэффициент: 1 + 0.1 * общее количество участий
    v_coeff := 1 + 0.1 * v_total_participations;

    RETURN v_coeff;
END calculate_exhibit_coeff;
/


insert into exhibition(exhibitionName,hallKey,dateOfBegginig,dateOfEnding,thematicsKey) values('vfif',1,to_date('06.11.2023','dd.mm.yy'),to_date('04.12.2023','dd.mm.yy'),1);

insert into basket values(6,2);
insert into basket values(16,11);
