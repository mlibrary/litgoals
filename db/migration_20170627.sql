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

create view human_owners as
  select goal.id, goal.title, group_concat(concat(o.uniqname,' ', o.lastname, ' ', coalesce(o.firstname, '')) separator ', ') names
  from goal, goalowner o, goaltoowner gto where goal.id = gto.goalid and o.id = gto.ownerid and o.is_unit = 0 group by goal.id;

create view human_stewards as
  select goal.id, goal.title, group_concat(concat(o.uniqname, ' ',  o.lastname, ' ', coalesce(o.firstname, '')) separator ', ') names
  from goal, goalowner o, goaltosteward gts where goal.id = gts.goalid and o.id = gts.stewardid and o.is_unit = 0 group by goal.id;

create view goalsearch AS
  select goal.id, goal.title, goal.description,
    concat(coalesce(human_owners.names, ' '), coalesce(human_stewards.names, ' ')) people from goal
    left OUTER JOIN human_owners on human_owners.id = goal.id
  left OUTER JOIN human_stewards on human_stewards.id = goal.id;

