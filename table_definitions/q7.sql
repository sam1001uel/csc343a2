-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedParty1 INT, 
        alliedParty2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS all_pairs CASCADE;
DROP VIEW IF EXISTS num_election CASCADE;

-- Define views for your intermediate steps here.

-- find all pairs of alliance. Report the election_id, alliedPartyId1 and alliedPartyId2
create view all_pairs as
select p1.election_id, p1.party_id as alliedPartyId1, p2.party_id as alliedPartyId2
from election_result p1 join election_result p2 on p1.election_id=p2.election_id
where p1.party_id<p2.party_id and (
p1.id=p2.alliance_id or p2.id=p1.alliance_id or p1.alliance_id=p2.alliance_id);

-- bind country_id to all_pairs
create view all_pairs_countryId as
select country_id as countryId, alliedPartyId1, alliedPartyId2
from all_pairs join election on all_pairs.election_id=election.id;

-- count the number of times each pair has been allied with each other
create view num_all_pairs as
select countryId, alliedPartyId1, alliedPartyId2, count(*) as occurence
from all_pairs_countryid 
group by countryid, alliedPartyId1, alliedPartyId2;

-- count the total number of elections in each country
create view num_election as
select country_id, count(*) as total
from election
group by country_id;

--Answer. divide occurence by total and select pairs >= 0.3 
create view answer as 
select num_all_pairs.countryId, num_all_pairs.alliedpartyid1, num_all_pairs.alliedpartyId2
from num_all_pairs join num_election on num_all_pairs.countryId=num_election.country_id
where (cast (occurence as float)/ total) >= 0.3;

-- the answer to the query 
insert into q7 
select * from answer;