require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/hooks/default'

$:.unshift "../lib"
$:.unshift "../seeds"

ENV['RACK_ENV'] = "test"

require 'sql_dbh'
# GoalsViz::DB.initialize_sqlite_memory_db
GoalsViz::DB.initialize_mysql_db
DB = GoalsViz::DB.db
require_relative "../lib/sql_models"


