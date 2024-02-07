--Написать триггер INSTEAD OF для работы с не обновляемым представлением

CREATE OR REPLACE VIEW basket_view AS 
Select exhibition.exhibitionName , exhibits.exhibitsName  --, count(exhibits.exhibitsName) as ex_count, 
From basket 
right join exhibition using(exhibitionKey) 
right join exhibits using(exhibitsKey) 


CREATE OR REPLACE TRIGGER basket_view_trigger
INSTEAD OF INSERT OR UPDATE OR DELETE ON basket_view
FOR EACH ROW
DECLARE
    v_exhibition_key exhibition.exhibitionKey%TYPE;
    v_exhibits_key exhibits.exhibitsKey%TYPE;
BEGIN
    CASE
        WHEN INSERTING THEN
            begin
            SELECT exhibitionKey INTO v_exhibition_key
            FROM exhibition
            WHERE exhibitionName = :NEW.exhibitionName;

            
           EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Указано неворное имя выставки');
            end;

            begin
            SELECT exhibitsKey INTO v_exhibits_key
            FROM exhibits
            WHERE exhibitsName = :NEW.exhibitsName;

             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Указано неворное имя экспоната');
            end;

            INSERT INTO basket (exhibitionKey, exhibitsKey)
            VALUES (v_exhibition_key, v_exhibits_key);

        WHEN UPDATING('exhibitionName') THEN
        begin
                SELECT exhibitionKey INTO v_exhibition_key
                FROM exhibition
                WHERE exhibitionName = :NEW.exhibitionName;

                UPDATE basket
                SET exhibitionKey = v_exhibition_key
                WHERE exhibitionKey = (
                    SELECT exhibitionKey FROM exhibition WHERE exhibitionName = :OLD.exhibitionName
                );
                   EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Указано неворное имя выставки');
                  end;


        WHEN UPDATING('exhibitsName') THEN
        begin
            SELECT exhibitsKey INTO v_exhibits_key
            FROM exhibits
            WHERE exhibitsName = :NEW.exhibitsName;

            UPDATE basket
            SET exhibitsKey = v_exhibits_key
            WHERE exhibitsKey = ALL(
                SELECT exhibitsKey FROM exhibits WHERE exhibitsName = :OLD.exhibitsName
            );
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Указано неворное имя экспоната');
                  end;

        WHEN DELETING THEN
            DELETE FROM basket
            WHERE exhibitionKey = (
                SELECT exhibitionKey FROM exhibition WHERE exhibitionName = :OLD.exhibitionName
            )
            AND exhibitsKey = (
                SELECT exhibitsKey FROM exhibits WHERE exhibitsName = :OLD.exhibitsName
            );
    END CASE;
END;
/


UPDATE basket_view SET exhibitionName = 'hh' WHERE exhibitionName = 'лето';

INSERT INTO basket_view (exhibitionName, exhibitsName) VALUES ('лето', 'ввв');

delete from basket_view where exhibitionName = 'июль' and exhibitsName='Моисей'

delete from basket_view where exhibitionName = 'лето' and exhibitsName='Черный квадрат'

update basket_view SET exhibitsName = 'Боо' WHERE exhibitsName = 'Аленушка'

select * from basket_view
