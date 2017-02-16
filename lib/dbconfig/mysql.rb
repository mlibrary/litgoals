require 'dry-container'
require 'dry-auto_inject'
require_relative 'general'


module GoalsViz

  module DBConfig
    class Mysql < General

      class Setup


        def call(db)
          General.drop_all_tables(db)
          dir = File.dirname(__FILE__)
          sql = File.read("#{dir}/../../seeds/mysql_tables.sql")
          sql.split(/;/).select{|x| x =~ /S/}.each {|x| db.run x}
        end
      end


      extend Dry::Container::Mixin

      register "database_type" do
        :mysql
      end

      register "dsn" do
        {adapter: ENV['litgoals_adapter'],
         database: ENV['litgoals_database'],
         user: ENV['litgoals_user'],
         host: ENV['litgoals_host'],
         password: ENV['litgoals_password']
        }
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

