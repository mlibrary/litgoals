require 'dry-container'
require 'dry-auto_inject'
require_relative 'general'


module GoalsViz

  module DBConfig
    class Mysql < General

      extend Dry::Container::Mixin

      register "database_type" do
        :mysql
      end

      register "dsn" do
        YAML_Config = YAML.load '../config/database.yml'

        {adapter:  YAML_Config['litgoals_adapter'],
         database: YAML_Config['litgoals_database'],
         user:     YAML_Config['litgoals_user'],
         host:     YAML_Config['litgoals_host'],
         password: YAML_Config['litgoals_password']
        }
      end

    end
  end
end

