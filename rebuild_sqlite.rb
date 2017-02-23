$:.unshift 'lib'
require 'db'

connection = GoalsViz::DBConnection.new
connection.connect
connection.setup_tables
connection.seed_tables

require 'sql_models'


bill = GoalsViz::Person.where(uniqname: 'dueberb').first
dla = GoalsViz::Unit.where(uniqname: 'DLA').first


g = GoalsViz::Goal.new
g.title = "Sample one"
g.description = "Description of sample one"
g.save
g.creator = bill
g.replace_owners [bill]
g.goal_year = 2016
g.status = "Not started"
g.target_date = "2017/06"
g.save

g = GoalsViz::Goal.new
g.title = "Sample two, a DLA goal"
g.description = "DLA (linkable) goal"
g.save
g.creator = bill
g.replace_owners [dla]
g.goal_year = 2016
g.status = "Not started"
g.target_date = "2017/06"
g.save



