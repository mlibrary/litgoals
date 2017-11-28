require 'sequel'
require 'dry-auto_inject'
require 'yaml'
require 'pathname'

module GoalsViz
  LOG = Logger.new(STDERR)

  dbfilepath = Pathname.new(__dir__).parent + 'config' + 'database.yml'
  YAML_Config = YAML.load_file(dbfilepath)['production']

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

    attr_reader :db
    include CurrentConfig['dsn']
      

    def connect
      @db = Sequel.connect(dsn)
    end
  end
end
