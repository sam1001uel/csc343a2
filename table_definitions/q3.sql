-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_15_years CASCADE;

-- Define views for your intermediate steps here.

-- store info of elections from the past 15 years
create view election_15_years as
select id as election_id, country_id, extract(year from e_date) as year, electorate, votes_cast
from election
where extract(year from e_date)>=2001 and extract(year from e_date)<=2016;

-- elections from the past 15 years and the participationratio for each
create view participationratio_all as
select election_id, country_id, year, (cast(votes_cast as decimal)/cast(electorate as decimal)) as participationratio
from election_15_years ;

-- elections from the same country that happen in the same year
create view participationratio_duplicate as
select p1.country_id, p1.year, p1.participationratio
from participationratio_all p1, participationratio_all p2
where p1.election_id<>p2.election_id and p1.country_id=p2.country_id and p1.year=p2.year;

-- find the avg participationratio among duplicates
create view participationratio_duplicate_avg as
select country_id, year, avg(participationratio) as participationratio
from participationratio_duplicate 
group by country_id,year;

-- No duplicates
create view participationratio_no_duplicate as
select country_id, year, participationratio from participationratio_all
except (select * from participationratio_duplicate);

-- haven't checked for monotonically non-decreasing
create view participationratio_unchecked as
select * from participationratio_no_duplicate 
union
select * from participationratio_duplicate_avg ;

-- checked for monotonically non-decreasing. delete countries that didn't have monotonically non-decreasing
create view participationratio_checked as
select * from participationratio_unchecked 
where country_id not in (
select distinct p1.country_id
from participationratio_unchecked p1, participationratio_unchecked p2
where p1.country_id=p2.country_id and p1.year<p2.year and p1.participationratio>p2.participationratio);

create view answer as
select name as countryName, year, participationratio
from participationratio_checked join country on country_id=id;

-- the answer to the query 
insert into q3 
select * from answer;
