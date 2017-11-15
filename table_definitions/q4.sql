-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS all_parties CASCADE;

-- Define views for your intermediate steps here.

-- all parties with their left-right score
create view all_parties as
select country_id, party_id, left_right
from party left join party_position on id=party_id; 

-- all countries with their number of parties that falls into [0,2)
create view first_interval as
select country_id, count(*) as "r0_2" 
from all_parties 
where left_right>=0 and left_right<2
group by country_id;

-- all countries with their number of parties that falls into [2,4)
create view second_interval as
select country_id, count(*) as "r2_4" 
from all_parties 
where left_right>=2 and left_right<4
group by country_id;

-- all countries with their number of parties that falls into [4,6)
create view third_interval as 
select country_id, count(*) as "r4_6" 
from all_parties 
where left_right>=4 and left_right<6
group by country_id;

-- all countries with their number of parties that falls into [6,8)
create view forth_interval as
select country_id, count(*) as "r6_8" 
from all_parties 
where left_right>=6 and left_right<8
group by country_id;

-- all countries with their number of parties that falls into [8,10]
create view fifth_interval as
select country_id, count(*) as "r8_10" 
from all_parties 
where left_right>=8 and left_right<=10
group by country_id;

-- answer
create view answer as 
select name as countryName, r0_2, r2_4, r4_6, r6_8, r8_10 
from (first_interval natural join second_interval natural join third_interval
natural join forth_interval natural join fifth_interval) join country on country_id=id;

-- the answer to the query 
INSERT INTO q4 
select * from answer;
