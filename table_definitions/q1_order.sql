SET SEARCH_PATH TO parlgov;

select * from q1
order by (year, countryname, voterange, partyname) desc; 