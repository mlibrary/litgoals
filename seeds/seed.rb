require 'sequel'

database = ENV['litgoals_database']
host     = ENV['litgoals_host']
user     = ENV['litgoals_user']
adapter  = ENV['litgoals_adapter']
password = ENV['litgoals_password']


DB = Sequel.connect(adapter:  adapter,
                    database: database,
                    user:     user,
                    host:     host,
                    password: password)

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
STATUS.map do |status|
  DB[:status].insert(name: status)
end

# Load up the units with its hierarchy

def seed_units
  File.open('units.txt').each do |ln|
    abbrev, name, parent = ln.chomp.split(/\s*\|\s*/)
    next unless abbrev
    DB[:goalowner].insert(uniqname:        abbrev,
                          lastname:  name,
                          parent_uniqname: parent,
                          is_unit:   true
    )
  end
end

# Let's get all the units

require 'sequel'
DB = Sequel.connect(:adapter=>:mysql2, :database=>"litgoals", user: 'dueberb', host: 'localhost')

class Unit < Sequel::Model(DB[:goalowner].where(is_unit: true))
  plugin :tree, :primary_key => :parent_uniqname, :key=>:parent_uniqname, :parent => {:key=>:parent_uniqname, :name => :parent_unit}
  alias_method :abbreviation, :uniqname
  alias_method :name, :lastname

  def self.[](abbrev)
    find(uniqname: abbrev)
  end
end

class Person < Sequel::Model(DB[:goalowner].where(is_unit: false))
  plugin :tree, :primary_key => :parent_uniqname, :parent => {:key=>:parent_uniqname, :name => :unit}
end

# Load up the units with its hierarchy

def seed_units
  File.open('units.txt').each do |ln|
    abbrev, name, parent = ln.chomp.split(/\s*\|\s*/)
    next unless abbrev
    Unit.new(uniqname:        abbrev,
                          lastname:  name,
                          parent_uniqname: parent,
                          is_unit:   true
    ).save
  end
end


# Load up people
