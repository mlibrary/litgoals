require 'dry-container'
require 'dry-auto_inject'
require 'dotenv'
require 'sequel'

require_relative '../constants'

module GoalsViz
  module DBConfig
    class General

      TABLENAMES = %w(status goalowner goal goaltogoal goaltoowner)

      def self.drop_all_tables(db)
        TABLENAMES.each { |t| db.drop_table? t }
      end
   end
  end
end
