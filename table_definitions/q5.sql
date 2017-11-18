-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS all_cabinet_party CASCADE;

-- Define views for your intermediate steps here.

-- All cabinet_party from the past 20 years
create view all_cabinet_party as
select cabinet.id, country_id,start_date, party_id
from cabinet join cabinet_party on cabinet.id=cabinet_id
where extract(year from start_date)>=1997;

-- if all parties have been a member of all cabinets
create view suppose_to_be as
select distinct a1.country_id, a1.party_id, a2.start_date 
from all_cabinet_party a1, all_cabinet_party a2
where a1.id<>a2.id and a1.country_id=a2.country_id
order by a1.country_id, a1.party_id;

-- All parites who have not been a member of all cabinets
create view not_member as 
select distinct country_id, party_id from (
select * from suppose_to_be 
except 
select country_id, party_id, start_date from all_cabinet_party
order by country_id) as supposed;

-- All parites who have been a member of all cabinets in its country
create view member as
select country_id, party_id 
from all_cabinet_party 
except (select * from not_member);

-- Answer
create view answer as
select country.name as countryName, party.name as partyName, family, state_market
from member join country on member.country_id=country.id 
join party on member.party_id=party.id
join party_family on member.party_id=party_family.party_id
join party_position on member.party_id=party_position.party_id;

-- the answer to the query 
insert into q5 
select * from answer;
