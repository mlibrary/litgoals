require 'sequel'
require 'dotenv'
Dotenv.overload


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
      @db = Sequel.connect(adapter:  ENV['litgoals_adapter'],
                           database: ENV['litgoals_database'],
                           user:     ENV['litgoals_user'],
                           host:     ENV['litgoals_host'],
                           password: ENV['litgoals_password']
      )
      @db
    end

    def self.initialize_sqlite_db
      dir = File.dirname(__FILE__)
      filename = File.join(dir, "litgoals_fake.db")
      already_exists = File.exist?(filename)

      @db  = Sequel.connect("sqlite://#{filename}")

      unless already_exists
        # seed it
        db << File.read("#{dir}/../seeds/sqlite_tables.sql")
        load "#{dir}/../seeds/seed.rb"
        s = GoalsViz::Seed.new(db)
        s.seed
      end
    end

  end
end
