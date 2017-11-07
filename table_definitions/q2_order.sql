SET SEARCH_PATH TO parlgov;

select * from q2
order by 
countryname asc,
wonelections asc,
partyname desc;