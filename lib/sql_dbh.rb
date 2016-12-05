require 'sequel'
require 'dotenv'
Dotenv.load

module GoalsViz
  class DB

    def self.setup_from_environment
      if ENV['litgoals_environment'] == "mysql"
        setup(:mysql)
      else
        setup(:sqlite)
      end
    end

    def self.setup(dbtype)
      if dbtype == :mysql
        self.initialize_mysql_db
      else
        self.initialize_sqlite_db
      end
    end

    def self.db
      @db || exit("Need to initialize DB first!")
    end

    def self.db=(newdb)
      @db = newdb
    end

    # In the absense of an already-defined db, pick one up
    # from the environment variables
    def self.initialize_mysql_db
      @db = Sequel.connect(adapter: ENV['litgoals_adapter'],
                           database: ENV['litgoals_database'],
                           user: ENV['litgoals_user'],
                           host: ENV['litgoals_host'],
                           password: ENV['litgoals_password']
      )
      @db
    end

    def self.set_up_tables
      dir = File.dirname(__FILE__)
      @db << File.read("#{dir}/../seeds/sqlite_tables.sql")
    end

    def self.initialize_sqlite_memory_db
      @db = Sequel.sqlite
      self.set_up_tables
    end

    def self.initialize_sqlite_db
      dir = File.dirname(__FILE__)
      filename = File.join(dir, "litgoals_fake.db")
      if File.exist?(filename)
        File.delete(filename)
      end

      @db = Sequel.connect("sqlite://#{filename}")
      puts "Setting up tables for sqlite at #{filename}"
      self.set_up_tables

      puts "Seeing sqlite3 tables"
      require_relative "../seeds/seed.rb"
      GoalsViz::Seed.new(@db).seed

      @db
    end

  end
end
