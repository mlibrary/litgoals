require 'sequel'

DB = Sequel.connect(adapter: 'mysql2', database: 'goalsviz', user: 'dueberb', host: 'localhost')

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


# Put in the statuses
DB[:status].delete
STATUS.map do |status|
  DB[:status].insert(name: status)
end

# Load up the units with its hierarchy

def seed_units
  File.open('seeds/units.txt').each do |ln|
    abbrev, name, parent = ln.chomp.split(/\s*\|\s*/)
    next unless abbrev
    DB[:goalowner].insert(uniqname:        abbrev,
                          lastname:        name,
                          parent_uniqname: parent,
                          is_unit:         true
    )
  end
end


# Add the people
# Adler	Richard	rcadler	ASSOC LIBRARIAN	LibraryInfoTech	Digital Content & Collections
def add_people
  File.open('seeds/staff.tsv').each do |l|
    last, first, uniqname, title, _, unitname = l.chomp.split(/\t/).map(&:strip)
    uabbrev = DB[:goalowner].where(:lastname => unitname).get(:uniqname)
    DB[:goalowner].insert(uniqname:        uniqname,
                          lastname:        last,
                          firstname:       first,
                          parent_uniqname: uabbrev,
                          is_unit:         false
    )
  end
end

DB.run('SET FOREIGN_KEY_CHECKS=0')
DB[:goalowner].truncate
seed_units
add_people
DB.run('SET FOREIGN_KEY_CHECKS=1')

