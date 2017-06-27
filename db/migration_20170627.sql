# Was running the associations backwards -- all created by code, so it
# was all consistent. Changing things to be correct, and need to
# swap the columns
#
# Mysql docs note that trying to do `update tbl set x = y, y = x`
# results in both values being the same, and that:
#   > This behavior differs from standard SQL.
#
# Thanks, mysql
#
# So...do this weird temp-table thing, which is valid in both
# sqlite and mysql

create table ddd as (select * from goaltoowner limit 1);
insert into ddd (goalid, ownerid)  (select ownerid, goalid from goaltoowner);
drop table goaltoowner;
rename table ddd to goaltoowner;

create table ddd as (select * from goaltosteward limit 1);
delete from ddd;
insert into ddd (goalid, stewardid)  (select stewardid, goalid from goaltosteward);
drop table goaltosteward;
rename table ddd to goaltosteward;



create table ddd as (select * from goaltogoal limit 1);
delete from ddd;
insert into ddd (parentgoalid, childgoalid)  (select childgoalid, parentgoalid from goaltogoal);
drop table goaltogoal;
rename table ddd to goaltogoal;

