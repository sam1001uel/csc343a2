-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS all_cabinets_pmParty CASCADE;

-- Define views for your intermediate steps here.

-- find all cabinets and report Country_id, Cabinet_id, start_date, pmParty_id and previous_cabinet_id
create view all_cabinets_pmParty as
select country_id, id as cabinetId, start_date, party_id as pmParty_id, previous_cabinet_id as prev_id
from cabinet left outer join (
select cabinet_id, party_id
from cabinet_party
where pm=true) as p on p.cabinet_id=id;

-- find all cabinets and report Country_id, cabinetId, startDate, endDate, pmParty_id
create view cabinets_pmparty_enddate as 
select all_cabinets_pmparty.country_id, cabinetId, all_cabinets_pmparty.start_date as startDate, cabinet.start_date as endDate, pmParty_id
from cabinet right outer join all_cabinets_pmparty on cabinet.previous_cabinet_id=cabinetId;

-- Answer to the query. Replace country_id by country name and pmParty_id by pmParty name
create view answer as 
select country.name as countryName, cabinetId, startDate, endDate, party.name as pmParty
from cabinets_pmparty_enddate left outer join country on country_id=country.id
left outer join party on pmParty_id=party.id;

-- the answer to the query 
insert into q6 
select * from answer;
