
require 'sequel'


DB = Sequel.connect(:adapter=>:mysql2, :database=>"litgoals", user: 'dueberb', host: 'localhost')

seed_units unless DB[:goalowner].count > 0

class Unit < Sequel::Model(DB[:goalowner].where(is_unit: true))
  plugin :tree, :primary_key => :parent_uniqname, :key=>:parent_uniqname, :parent => {:key=>:parent_uniqname, :name => :parent_unit}
end

class Person < Sequel::Model(DB[:goalowner].where(is_unit: false))
  plugin :tree, :primary_key => :parent_uniqname, :parent => {:key=>:parent_uniqname, :name => :unit}
end

p = Person.new(lastname: 'Dueber', firstname: 'Bill', uniqname: 'dueberb', unit: Unit.find(uniqname: 'DLA'))
p.save
