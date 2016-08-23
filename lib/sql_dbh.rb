require 'sequel'
require 'dotenv'
Dotenv.load


module GoalsViz
  class DB
    def self.db
      @db || self.initialize_db
    end

    def self.db=(newdb)
      @db = newdb
    end

    # In the absense of an already-defined db, pick one up
    # from the environment variables
    def self.initialize_db
      @db = Sequel.connect(adapter:  ENV['litgoals_adapter'],
                           database: ENV['litgoals_database'],
                           user:     ENV['litgoals_user'],
                           host:     ENV['litgoals_host'],
                           password: ENV['litgoals_password']
      )
      @db
    end

  end
end
