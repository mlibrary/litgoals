require 'dry-container'
require 'dry-auto_inject'
require_relative 'general'


module GoalsViz

  module DBConfig
    class SQLite < General

      class Setup

        TABLENAMES = %w(status goalowner goal goaltogoal goaltoowner)

        def call(db)
          General.drop_all_tables(db)
          dir = File.dirname(__FILE__)
          db << File.read("#{dir}/../../seeds/sqlite_tables.sql")
          db
        end
      end


      extend Dry::Container::Mixin

      register "database_type" do
        :sqlite
      end

      register "dsn" do
        filename ='litgoals_fake.db'
        {adapter: 'sqlite', database: filename}
      end

      register "setup" do
        Setup.new
      end

      register "seed" do
        Seed.new
      end


    end
  end
end

