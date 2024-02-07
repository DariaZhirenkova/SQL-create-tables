--есть ли сотрудники с днем рождения равной текущей дате
SELECT supervisor.lastName, supervisor.firstName, supervisor.dateOfBirth
FROM supervisor
WHERE supervisor.dateOfBirth = SYSDATE

-- (Условный запрос) большие залы
SELECT hall.hallName, hall.square
FROM hall
WHERE hall.square BETWEEN 200 AND 499

--«Выставлено работ по авторам» (итоговый запрос)
SELECT author.lastName, COUNT(exhibitsName) FROM author
INNER JOIN exhibits ON author.authorKey = exhibits.authorKey
GROUP BY author.lastName

--Количество выставок по кварталам» (запрос по полю с типом дата).
SELECT TO_CHAR(exhibition.dateOfBegginig, 'Q') AS quator, count(exhibition.exhibitionName) as count_exh
from exhibition
group by TO_CHAR(exhibition.dateOfBegginig, 'Q')
order by TO_CHAR(exhibition.dateOfBegginig, 'Q')

--«Экспозиции работ повышенной ценности» (параметрический запрос)
SELECT author.lastName, author.firstName, exhibits.exhibitsName,exhibits.worth
FROM exhibits
INNER JOIN author ON exhibits.authorKey = author.authorKey
WHERE exhibits.worth = :worth;

--«Общий список авторов с количеством работ и экспонатов с количеством экспозиций» (запрос на объединение)
SELECT author.lastName AS NAME, COUNT(exhibits.exhibitsName) AS "Quantity" , 'Author' AS TYPE FROM author
INNER JOIN exhibits ON author.authorKey = exhibits.authorKey
GROUP BY author.lastName
UNION ALL SELECT exhibits.exhibitsName AS NAME, COUNT(exhibition.exhibitionName)AS "Quantity", 'Exhibit' AS TYPE FROM basket
INNER JOIN exhibits ON basket.exhibitsKey = exhibits.exhibitsKey
INNER JOIN exhibition ON  basket.exhibitionKey = exhibition.exhibitionKey
GROUP BY exhibits.exhibitsName

--INNER JOIN USING корзина
SELECT exhibition.exhibitionName, exhibits.exhibitsName
FROM basket
INNER JOIN exhibits USING (exhibitsKey)
INNER JOIN exhibition USING (exhibitionKey)
ORDER BY exhibition.exhibitionName

--Использование предиката IN с подзапросом, все экспозиции с тематиой "Эпоха Возрождения"
SELECT exhibition.exhibitionName FROM exhibition
WHERE exhibition.thematicsKey IN (Select thematics.thematicsKey FROM thematics WHERE thematics.thematicsName = 'Эпоха Возрождения')

--Использование предиката ANY с подзапросом, вывести авторов которые старше супервизеров
SELECT author.lastName, author.firstName 
FROM author
WHERE author.dateOfBirth > ANY (SELECT supervisor.dateOfBirth FROM supervisor)


--Использование предиката EXISTS/NOT EXISTS с подзапросом, экспозиции которых нет в корзине
SELECT exhibition.exhibitionName
FROM exhibition  
WHERE NOt EXISTS (SELECT 1 FROM basket WHERE exhibition.exhibitionKey = basket.exhibitionKey ); 

--Внешнее соединение темы экспонатов
SELECT theme.themeName, exhibits.exhibitsName
FROM exhibits
RIGHT JOIN theme USING (themeKey)

-- запрос на обновление
UPDATE hall SET hall.hallName = CONCAT(hall.hallName, hall.floor)


--Запрос, отображающий супервизоров, учавствовавших в выставке с наибольшим количеством экспонатов
SELECT supervisor.lastName,supervisor.firstName,supervisor.hallKey FROM supervisor WHERE supervisor.hallKey = ANY (
SELECT hall.hallKey FROM hall WHERE hall.hallKey = ANY (
SELECT hall.hallKey FROM hall WHERE hall.hallKey = ANY (
SELECT exhibition.hallKey FROM exhibition WHERE exhibition.exhibitionName = ANY (SELECT exhibition.exhibitionName
FROM basket
INNER JOIN exhibits ON basket.exhibitsKey = exhibits.exhibitsKey
INNER JOIN exhibition ON  basket.exhibitionKey = exhibition.exhibitionKey
GROUP BY exhibition.exhibitionName
having count(exhibition.exhibitionName) = (select max(cf_num)
           from (
            SELECT exhibition.exhibitionName,count(exhibition.exhibitionName) as cf_num
            FROM basket
                INNER JOIN exhibits ON basket.exhibitsKey = exhibits.exhibitsKey
                INNER JOIN exhibition ON  basket.exhibitionKey = exhibition.exhibitionKey
                GROUP BY exhibition.exhibitionName
              ) t1 )))))



