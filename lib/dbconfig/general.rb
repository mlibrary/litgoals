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

      class Seed

        def seed_status(db)
          GoalsViz::STATUS.map do |status|
            db[:status].insert(name: status)
          end
        end

        def seed_units(db)
          File.open('seeds/units.txt').each do |ln|
            abbrev, name, parent = ln.chomp.split(/\s*\|\s*/)
            next unless abbrev
            db[:goalowner].insert(uniqname: abbrev,
                                  lastname: name,
                                  parent_uniqname: parent,
                                  is_unit: true
            )
          end
        end


        # Add the people
        # Adler	Richard	rcadler	ASSOC LIBRARIAN	LibraryInfoTech	Digital Content & Collections
        def seed_people(db)
          File.open('seeds/staff.tsv').each do |l|
            last, first, uniqname, title, _, unitname, isadmin = l.chomp.split(/\t/).map(&:strip)
            uabbrev = db[:goalowner].where(:lastname => unitname).get(:uniqname)
            err = db[:goalowner].insert(uniqname: uniqname,
                                        lastname: last,
                                        firstname: first,
                                        parent_uniqname: uabbrev,
                                        is_unit: false,
                                        is_admin: (isadmin == 'TRUE')
            )
          end
        end

        def call(db)
          seed_status(db)
          seed_units(db)
          seed_people(db)
        end
      end


    end
  end
end