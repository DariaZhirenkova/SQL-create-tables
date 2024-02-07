-- авторы, у которых в стране рождения встречается слово империя
-- Горизонтальное обновляемое представление с условием (WHERE)

CREATE OR REPLACE VIEW author_empire AS 
select * 
from author 
where author.countryOfBirth LIKE '%империя%'
WITH CHECK OPTION 

select* from author_empire

--2.2)	проверить обновляемость горизонтального представления 

insert into author_empire(lastName,firstName,countryOfBirth,dateOfBirth) values('fff','aaa','Российская империя',to_date('23.02.1879','dd.mm.yy'));--работает
Delete from author_empire Where lastname = 'fff'

insert into author_empire(lastName,firstName,countryOfBirth,dateOfBirth) values('fff','aaa','Россия',to_date('23.02.1879','dd.mm.yy'));--не работает
UPDATE author_empire SET countryOfBirth = 'Аргентина' WHERE lastName = 'да Винчи'--ошибка
UPDATE author_empire SET countryOfBirth = 'Османская империя' WHERE lastName = 'да Винчи'--работает

UPDATE author_empire SET countryOfBirth = 'Римская империя' WHERE lastName = 'да Винчи'--работает



-- Создать вертикальное или смешанное необновляемое представление
CREATE OR REPLACE VIEW basket_view AS 
Select exhibition.exhibitionName , exhibits.exhibitsName  --, count(exhibits.exhibitsName) as ex_count, 
From basket 
right join exhibition using(exhibitionKey) 
right join exhibits using(exhibitsKey) 
--Having count(exhibits.exhibitsName) = 6
--group by exhibition.exhibitionName

select* from basket_view

insert into basket_view
delete from basket_view where exhibitionName = 'весна'
update basket_view SET exhibitionName = 'фывапр' WHERE exhibitsName = 'Богатыри'
insert into basket_view values(6,3)


--обновляемое представление для работы с данными только в рабочие дни
CREATE OR REPLACE VIEW time_work AS 
select *
from exhibition 
Where TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'Europe/Istanbul','HH24') between 9 and 17 and TO_CHAR(SYSDATE,'D') between 2 and 6 
WITH CHECK OPTION  

select * from time_work

Insert into exhibition(exhibitionName,hallKey,dateOfBegginig,dateOfEnding,thematicsKey) values('Катя',1,to_date('14.10.2023','dd.mm.yy'),to_date('31.12.2023','dd.mm.yy'),1);