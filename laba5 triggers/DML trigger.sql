CREATE TABLE LOG1 (
    tableName VARCHAR(50),
    actionType VARCHAR(10),
    pk_key VARCHAR2(70),
    column_name VARCHAR2(30),
    userName VARCHAR(50),
    oldValues VARCHAR2(70),
    newValues VARCHAR2(70),
    dateoper TIMESTAMP);

drop table LOG1

CREATE OR REPLACE PROCEDURE helpProcedure (
    vtable_name IN VARCHAR2,
    vact_name IN CHAR,
    vpk_key IN VARCHAR2,
    vcolumn_name IN VARCHAR2,
    vold_value IN VARCHAR2,
    vnew_value IN VARCHAR2
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    datetime TIMESTAMP;

BEGIN
    IF vold_value <> vnew_value OR vact_name IN ('I','D') THEN
        SELECT SYSTIMESTAMP AT TIME ZONE 'Europe/Istanbul' INTO datetime FROM DUAL;
        INSERT INTO LOG1 (tableName, actionType, pk_key, column_name, oldValues,newValues,userName, dateoper)
        VALUES ( vtable_name,vact_name, vpk_key, vcolumn_name, vold_value, vnew_value, USER, datetime);
        COMMIT;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER super_audit
AFTER INSERT OR UPDATE OR DELETE ON supervisor
FOR EACH ROW
DECLARE
op   CHAR (1) := 'I';
BEGIN
   CASE
      WHEN INSERTING THEN
op:= 'I';
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'lastName', NULL,:NEW.lastName);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'firstName', NULL,:NEW.firstName);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'dateOfBirth', NULL,:NEW.dateOfBirth);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'hallKey', NULL,:NEW.hallKey);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'telephoneNumber', NULL, :NEW.telephoneNumber);
 WHEN UPDATING('lastName') OR UPDATING('hallKey') OR
 UPDATING('telephoneNumber') THEN 
op:='U';
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'lastName', :OLD.lastName,:NEW.lastName);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'hallKey', :OLD.hallKey,:NEW.hallKey);
helpProcedure ('SUPERVISOR', op, :NEW.supervisorKey, 'telephoneNumber',:OLD.telephoneNumber, :NEW.telephoneNumber);
      WHEN DELETING THEN
op:='D';
helpProcedure ('SUPERVISOR', op, :old.supervisorKey, 'lastName', :OLD.lastName,NULL);
helpProcedure ('SUPERVISOR', op, :old.supervisorKey, 'firstName',:OLD.firstName,NULL);
helpProcedure ('SUPERVISOR', op, :old.supervisorKey, 'hallKey', :OLD.hallKey,NULL);
helpProcedure ('SUPERVISOR', op, :old.supervisorKey, 'dateOfBirth', :OLD.dateOfBirth,NULL);
helpProcedure ('SUPERVISOR', op, :old.supervisorKey, 'telephoneNumber',:OLD.telephoneNumber, NULL);
   ELSE
null;
   END CASE;
END super_audit;
/

insert into supervisor(firstName,lastName,hallKey,telephoneNumber,dateOfBirth,dateNow) values ('Катя','Мурзкина',4,'+375(29)222-88-88',to_date('23.04.1968','dd.mm.yy'),to_date('','dd.mm.yy'));

UPDATE supervisor
SET lastName = 'Мурз111', telephoneNumber = '+375(33)333-33-55',dateOfBirth = to_date('14.04.1988','dd.mm.yy')
WHERE supervisorKey= 7;
 