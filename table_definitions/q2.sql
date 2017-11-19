-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS max_vote CASCADE;
DROP VIEW IF EXISTS num_of_parties CASCADE;

-- Define views for your intermediate steps here.
-- find the maximum votes for a party in each election
create view max_vote as
select election_id, max(votes)
from election_result
group by election_id;

-- bind party_id of the party who got the maximum votes in each election
create view max_vote_party as
select election_result.election_id, party_id, votes
from election_result join max_vote on election_result.election_id=max_vote.election_id and votes=max;

-- find the number of times each party has won
create view election_won as
select party_id, count(*) as won
from max_vote_party 
group by party_id;

-- bind country_id and partyName to max_vote_party
create view intermediate_no_family as
select country_id, name as partyName, party.id as party_id, won as wonElections
from election_won join party on election_won.party_id=id;

-- total number of elections in a country
create view num_of_won_elections as
select country_id, sum(wonelections)
from intermediate_no_family 
group by country_id;

-- find the total number of parties in each country
create view num_of_parties as
select country_id, count(*) as num_of_parties
from party
group by country_id;

-- find the average number of elections won for a party in each country
create view avg_election_won as
select country_id, sum as total_won_elections, num_of_parties, round(cast(sum as decimal)/cast(num_of_parties as decimal),2) as avg_win_elections 
from num_of_won_elections natural join num_of_parties;

-- all parties who have won more than 3 times the average number of winning elections of parties of same country
create view more_than_3 as
select country_id, partyname, party_id, wonelections, (3*avg_win_elections) as threshold
from intermediate_no_family natural join avg_election_won 
where wonelections > (3*avg_win_elections);

-- For all parties from the above view, find election_id and year of the elections that they have won
create view more_than_3_election_won as 
select election_id, party_id, extract(year from e_date) as year
from max_vote_party natural join more_than_3 
join election on election_id=id;

-- Find out the election_id and year of the most recent elections that they have won
create view most_recent_won as
select * from more_than_3_election_won 
except (
select distinct m1.election_id, m1.party_id, m1.year 
from more_than_3_election_won m1, more_than_3_election_won m2
where m1.election_id<>m2.election_id and m1.party_id=m2.party_id and m1.year<m2.year);

-- Answer
create view answer as 
select name as countryName, partyname, family as partyFamily, wonElections, election_id as mostRecentlyWonElectionId, year as mostRecentlyWonElectionYear
from 
more_than_3 natural join most_recent_won 
left join party_family on more_than_3.party_id=party_family.party_id
join country on country_id=id;

-- the answer to the query 
insert into q2 
select * from answer ;

