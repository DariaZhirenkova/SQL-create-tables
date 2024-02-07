--При добавлении в корзину экспонатов , автором которых является да Винчи, автоматически в эту же выставку добавляются все экспонаты да Винчи.

CREATE OR REPLACE TRIGGER add_da_vinci_to_basket
FOR INSERT ON basket
COMPOUND TRIGGER

-- Объявление переменных
author_name VARCHAR2(60);
found_count number;
exk number;

-- Объявляем и открываем курсор внутри блока
cursor da_vinci_cursor IS
SELECT exhibitsKey
FROM exhibits
WHERE authorKey = (SELECT authorKey FROM author WHERE lastName = 'да Винчи');
da_vinci_rec da_vinci_cursor%rowtype;

-- Перед каждым вставлением
BEFORE EACH ROW IS
BEGIN
-- Получаем имя автора
SELECT lastName INTO author_name
FROM author
WHERE authorKey = (SELECT authorKey FROM exhibits WHERE exhibitsKey = :NEW.exhibitsKey);

SELECT exhibitionKey INTO exk FROM exhibition WHERE exhibitionKey = :NEW.exhibitionKey;

END BEFORE EACH ROW;

-- После выполнения INSERT
AFTER STATEMENT IS
BEGIN
-- Если автор - да Винчи
IF author_name = 'да Винчи' THEN

-- Открываем курсор
OPEN da_vinci_cursor;

-- Цикл по всем экспонатам
LOOP
-- Получаем следующий экспонат из курсора
FETCH da_vinci_cursor INTO da_vinci_rec;

-- Проверяем конец курсора
EXIT WHEN da_vinci_cursor%NOTFOUND;

-- Проверяем, есть ли экспонат в корзине
SELECT COUNT(*)
INTO found_count
FROM basket
WHERE exhibitsKey = da_vinci_rec.exhibitsKey and exhibitionKey = exk;

-- Если экспонат не найден, добавляем его
IF found_count = 0 THEN

INSERT INTO basket(exhibitsKey, exhibitionKey)
VALUES (da_vinci_rec.exhibitsKey, exk);
END IF;
END LOOP;

-- Закрываем курсор
CLOSE da_vinci_cursor;
END IF;
END AFTER STATEMENT;
END add_da_vinci_to_basket;
/


delete from basket where exhibitsKey=2

insert into basket values(4,2)

SELECT* FROM basket

 Create FUNCTION get_exhibition_key(p_exhibits_key number) RETURN NUMBER IS
    v_exhibition_key NUMBER;
  BEGIN
    SELECT exhibitionKey INTO v_exhibition_key
    FROM basket
    WHERE exhibitsKey = p_exhibits_key;

    RETURN v_exhibition_key;
  END get_exhibition_key;
  /


   SELECT exhibitionKey FROM basket WHERE exhibitsKey = 2;
