require 'sequel'
require 'dry-auto_inject'
require 'yaml'

module GoalsViz
  LOG = Logger.new(STDERR)

  YAML_Config = YAML.load '../config/database.yml'

  CurrentConfig = if YAML_Config['litgoals_environment'] == 'mysql'
                    LOG.info "Attaching to mysql"
                    require_relative('../lib/dbconfig/mysql')
                    Dry::AutoInject(GoalsViz::DBConfig::Mysql)
                  else
                    raise "We only support mysql now"
                  end

  def self.new_db_connection
    DBConnection.new.connect
  end

  class DBConnection

    include CurrentConfig["database_type", "dsn"]

    attr_reader :db

    def connect
      @db = Sequel.connect(dsn)
    end
  end
end
