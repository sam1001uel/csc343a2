-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Create a view that store all elections from 1996 to 2016 inclusive
create view all_elections as
select id as election_id, country_id, extract(year from e_date) as year, votes_valid
from election
where extract(year from e_date)>=1996 and extract(year from e_date)<=2016; 

-- Create a view that store all results of election of each party in the elections
create view all_votes as
select election_id, party_id, name_short, votes
from election_result join party on party_id = party.id
where election_id in (select election_id from all_elections); 

-- Join all_elections and all_votes together
create view all_elections_votes as
csc343h-leetsz9-> select * 
csc343h-leetsz9-> from all_elections natural join all_votes;

-- Create view with country name and vote percentage
create view vote_percentage as
select election_id, year, country.name as countryName, name_short as partyName, round(cast(votes as decimal)/cast(votes_valid as decimal)*100,2) as percentage
from all_elections_votes join country on country_id=country.id;

-- Create view with countries that have more than one election in the same year
create view duplicate as 
csc343h-leetsz9-> select v1.election_id, v1.year, v1.countryname, v1.partyname, v1.percentage
csc343h-leetsz9-> from vote_percentage v1, vote_percentage v2
csc343h-leetsz9-> where v1.year=v2.year and v1.countryname=v2.countryname and v1.partyname=v2.partyname and v1.election_id<>v2.election_id;

-- Create view that store the avg vote of each party in duplicate elections
create view vote_percentage_duplicate as
select distinct year, countryname, partyname, new_percentage as percentage
from duplicate join (select partyname as pname, round(avg(percentage),2)as new_percentage from duplicate group by partyname) as d2 on partyname=pname;

-- Create view that store votes of each party in all non-duplicate elections
create view vote_percentage_noduplicate as
select year, countryname, partyname, percentage from vote_percentage
except all (select year, countryname, partyname, percentage from duplicate);


-- the answer to the query 
alter table q1 add column percentage decimal;

insert into q1 (year, countryname, partyname, percentage)
(select * from vote_percentage_duplicate);

insert into q1 (year, countryname, partyname, percentage)
(select * from vote_percentage_noduplicate);

update q1
set voterange=
case when percentage>0 and percentage<=5
then '(0,5]'
when percentage>5 and percentage<=10
then '(5,10]'
when percentage>10 and percentage<=20
then '(10,20]'
when percentage>20 and percentage<=30
then '(20,30]'
when percentage>30 and percentage<=40
then '(30,40]'
when percentage>40 
then '(40,]'
end;

alter table q1 drop column percentage;

