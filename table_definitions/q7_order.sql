SET SEARCH_PATH TO parlgov;

select * from q7
order by 
countryId desc,
alliedPartyId1 desc,
alliedPartyId2 desc;
