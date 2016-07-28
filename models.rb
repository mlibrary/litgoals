require 'neo4j'

module GoalsViz

  def self.connect!
    @@session = Neo4j::Session.open(:server_db, "http://localhost:7474", {basic_auth: {username: 'neo4j', password: 'pwd'}})
  end

  def self.seed_units(filename)
    File.open(filename).map{|x| x.strip.split(/\|/)}.each do |abbrev, name|
      u = GoalsViz::Unit.new(name: name, abbreviation: abbrev)
      u.save
    end
  end

  def self.seed_users(filename)
    File.open(filename).map(&:chomp).map{|x| x.split(/\t/)}.each do |last, first, uniqname, title, lit, dept|
      name =
      u = GoalsViz::Person.new(last: last, first: first, uniqname: uniqname)
      u.unit = GoalsViz::Unit.find_by(name: dept)
      u.save
    end
  end


  class Goal
    include Neo4j::ActiveNode
    include Neo4j::Timestamps # created_at and updated_at timestamps

    property :title
    validates :title, :presence => true

    property :description, default: "(no description)"
    property :link, default: "(no link)"
    property :enddate, type: DateTime

    has_one   :out, :parent,  type: :parent,  model_class: "GoalsViz::Goal"
    has_one   :in,  :creator, type: :creator, model_class: "GoalsViz::Person"


    has_one  :out,  :status, type: :status, model_class: "GoalsViz::Status"

    has_many :out, :platform, type: :platform,
                       model_class: 'GoalsViz::Platform'

    has_many :in,  :owners,  model_class: "GoalsViz::GoalOwner",
                             origin: :goals

  end

  class GoalOwner
    include Neo4j::ActiveNode
    include Neo4j::Timestamps # created_at and updated_at timestamps

    has_many :out, :goals, type: :has_goal, model_class: "GoalsViz::Goal"
  end

  class Person < GoalOwner
    property :last
    property :first     # note that regex matches must match the whole string
    property :uniqname
    property :manager, type: Boolean, default: false

    has_one :out, :unit, type: :member_of, model_class: "GoalsViz::Unit"

  end


  class Unit < GoalOwner
    include Neo4j::ActiveNode
    include Neo4j::Timestamps # created_at and updated_at timestamps

    property :abbreviation
    property :name

    has_one :out, :head, type: :headed_by, model_class: "GoalsViz::Person"
    has_one :out, :parent, type: :part_of, model_class: "GoalsViz::Unit"

    has_many :in, :people, model_class: "GoalsViz::Person", origin: :unit
  end


  class Platform
    include Neo4j::ActiveNode

    property :name
    has_many :in, :goals, model_class: "GoalsViz::Goal", origin: :platform

  end

  class Status
    include Neo4j::ActiveNode

    property :name
    property :intstatus, type: Integer, default: 0

    has_many :in, :goals, model_class: "GoalsViz::Goal", origin: :status

  end


end
