-- need to add a new relationship -- "stewards" -- for each goal

drop table if EXISTS goaltosteward;
create table goaltosteward (goalid integer unsigned, stewardid integer unsigned);


-- also, create a fulltext index for searching
# drop index title_desc_fulltext on goal;
create fulltext index title_desc_fulltext on goal(title, description);

