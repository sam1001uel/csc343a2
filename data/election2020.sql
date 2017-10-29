insert into election (id, country_id, e_date, seats_total, electorate, e_type)
values(2000, 29, to_date('2020-07-28', 'YYYY-MM-DD'), 1001, 1001, 'Parliamentary election');

insert into election_result (id, election_id, party_id, alliance_id)
values(10000, 2000, 368, null);

insert into election_result (id, election_id, party_id, alliance_id)
values(10001, 2000, 1259, 10000);

insert into election_result (id, election_id, party_id, alliance_id)
values(10002, 2000, 2148, 10000);

insert into election_result (id, election_id, party_id, alliance_id)
values(10003, 2000, 296, null);

insert into election_result (id, election_id, party_id, alliance_id)
values(10004, 2000, 1255, 10003);