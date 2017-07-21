$:.unshift '../lib'

require_relative '../litgoals'


bill = GoalsViz::Person.where(uniqname: 'dueberb').first
roger = GoalsViz::Person.where(uniqname: 'roger').first
parent_goal = GoalsViz::Goal.new
parent_goal.title = 'This is the parent'
parent_goal.save
parent_goal.creator = bill
parent_goal.add_associated_steward roger
parent_goal.save

child_goal = GoalsViz::Goal.new
child_goal.title = "This is the child"
child_goal.save
child_goal.creator = roger
child_goal.add_associated_steward bill
child_goal.replace_associated_goals [parent_goal]

child_goal.save



pg = GoalsViz::Goal[parent_goal.id]
ch = GoalsViz::Goal[child_goal.id]

# do some tests
