$:.unshift 'lib'
require 'db'

GoalsViz::DBConnection.new.connect(setup_tables: true, seed_tables: true)

