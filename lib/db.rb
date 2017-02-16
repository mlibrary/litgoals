require 'sequel'
require 'dotenv'
require 'dry-auto_inject'

Dotenv.load


module GoalsViz

  CurrentConfig = if ENV['litgoals_environment'] == 'mysql'
               require_relative('../lib/dbconfig/mysql')
               Dry::AutoInject(GoalsViz::DBConfig::Mysql)
             else
               require_relative('../lib/dbconfig/sqlite')
               Dry::AutoInject(GoalsViz::DBConfig::SQLite)
             end

  def self.new_db_connection
    DBConnection.new.connect
  end

  class DBConnection

    include CurrentConfig["database_type", "dsn", "setup", "seed"]

    attr_reader :db

    def connect(setup_tables: false, seed_tables: false)
      db = Sequel.connect(dsn)
      setup.(db) if setup_tables
      seed.(db)  if seed_tables
      @db = db
    end


    def setup_tables
      setup.(@db)
    end

    def seed_tables
      seed.(@db)
    end

  end
end
