SET SEARCH_PATH TO parlgov;

select * from q5
order by 
countryname asc,
partyname asc,
statemarket desc;
