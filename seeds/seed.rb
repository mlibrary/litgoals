require 'sequel'



module GoalsViz
  class Seed

    STATUS = [
        'Not started',
        'On hold',
        'In progress',
        'Completed',
        'Abandoned'
    ]

    PLATFORM = {
        create: 'Create',
        scale:  'Scale',
        build:  'Build'
    }

    def initialize(db)
      @db = db
    end

    def seed
      clear_it_out
      seed_statuses
      seed_units
      seed_people
      seed_goals
    end

    def clear_it_out
      [:goalowner, :status, :goal, :goaltogoal].each {|table| @db[table].delete}
    end

    def seed_statuses
      @db[:status].delete
      STATUS.map do |status|
        @db[:status].insert(name: status)
      end
    end

    # Load up the units with its hierarchy

    def seed_units
      File.open('seeds/units.txt').each do |ln|
        abbrev, name, parent = ln.chomp.split(/\s*\|\s*/)
        next unless abbrev
        @db[:goalowner].insert(uniqname:        abbrev,
                              lastname:        name,
                              parent_uniqname: parent,
                              is_unit:         true
        )
      end
    end


    # Add the people
    # Adler	Richard	rcadler	ASSOC LIBRARIAN	LibraryInfoTech	Digital Content & Collections
    def seed_people
      File.open('seeds/staff.tsv').each do |l|
        last, first, uniqname, title, _, unitname, isadmin = l.chomp.split(/\t/).map(&:strip)
        uabbrev = @db[:goalowner].where(:lastname => unitname).get(:uniqname)
        err = @db[:goalowner].insert(uniqname:        uniqname,
                                    lastname:        last,
                                    firstname:       first,
                                    parent_uniqname: uabbrev,
                                    is_unit:         false,
                                    is_admin: (isadmin == 'TRUE')
        )
      end
    end

    def seed_goals
      require_relative '../lib/sql_dbh'
      GoalsViz::DB.db=@db
      require_relative '../lib/sql_models'

      File.open("seeds/unit_goals.txt").each do |l|
        goaltitle, ownername = l.chomp.match(/\A(.*)\s+(.*)\Z/).captures
        owner = GoalsViz::Unit.find(uniqname: ownername)
        puts "Owner is #{owner} (based on #{ownername}) for #{goaltitle}"
        goal = GoalsViz::Goal.new(title: goaltitle, description: "Lorum whatever")
        goal.owner = owner
        goal.save
      end
    end

  end
end




