require 'sequel'
require_relative 'db'


module GoalsViz

  DB = new_db_connection


  # Pre-declare everything so the associations work
  class GoalOwner < Sequel::Model;
  end

  class Goal < GoalOwner;
  end

  class Unit < GoalOwner;
  end

  class Person < GoalOwner;

    def tagged_id
      "p#{self.id}"
    end


    def self.admins
      where(is_admin: true)
    end


    def admin!
      self.is_admin = true
    end


    def admin?
      self.is_admin
    end

  end

  class GoalOwner < Sequel::Model
    set_dataset DB[:goalowner]
    plugin :after_initialize

    many_to_many :goals, :class => Goal, :left_key => :goalid, :right_key => :ownerid,
                 :join_table    => :goaltoowner


    def parent
      self.class.find(uniqname: parent_uniqname)
    end


    def lowest_unit
      self.is_unit ? self : self.parent
    end


    def ancestors
      case parent
      when nil
        []
      else
        parent.ancestors.unshift(parent)
      end
    end


    def self_and_ancestors
      self.ancestors.unshift self
    end


    def people
      Person.where(parent_uniqname: self.uniqname).all
    end


    def higher_orgchart_goals
      ancestors.map(&:goals).flatten
    end


    def my_orgchart_goals
      goals + ancestors.map(&:goals).flatten
    end

  end

  class Unit < GoalOwner
    set_dataset DB[:goalowner].where(is_unit: true)

    one_to_many :subunits, class: Unit, primary_key: :uniqname, key: :parent_uniqname
    many_to_one :parent_unit, class: Unit, primary_key: :parent_uniqname, key: :uniqname
    one_to_many :people, class: Person, primary_key: :uniqname, key: :parent_uniqname


    def tagged_id
      "u#{self.id}"
    end


    def self.abbreviation_to_unit_map
      self.all.inject({}) { |h, u| h[u.abbreviation] = u; h }
    end


    def after_initialize # or after_initialize
      super
      self.is_unit = true if self.is_unit.nil?
    end


    alias_method :abbreviation, :uniqname
    alias_method :name, :lastname
    alias_method :parent_unit, :parent


    def depth_first_subunits
      case self.subunits
      when []
        []
      else
        self.subunits.reduce([]) do |acc, u|
          acc.push(u).concat(u.depth_first_subunits)
        end
      end
    end


  end

  class Person < GoalOwner
    set_dataset DB[:goalowner].where(is_unit: false)

    one_to_many :children, class: self, primary_key: :uniqname, key: :parent_uniqname
    many_to_one :parent, class: Unit, primary_key: :uniqname, key: :parent_uniqname


    alias_method :unit, :parent

    plugin :after_initialize


    def after_initialize # or after_initialize
      super
      self.is_unit = false if self.is_unit.nil?
    end


    def name
      "#{firstname} #{lastname}"
    end
  end


  class Status < Sequel::Model
    set_dataset DB[:status]
  end

  class Goal
    set_dataset DB[:goal]

    many_to_many :parent_goals, :class => Goal, :right_key => :childgoalid, :left_key => :parentgoalid,
                 :join_table           => :goaltogoal

    many_to_many :child_goals, :class => Goal, :left_key => :childgoalid, :right_key => :parentgoalid,
                 :join_table          => :goaltogoal

    many_to_many :associated_owners, :class => GoalOwner, :right_key => :goalid, :left_key => :ownerid,
                 :join_table                => :goaltoowner

    one_to_many :goals, class: Goal, primary_key: :id, key: :uniqname



    def self.goals_owned_by(goalowners)
      self.where(owner: Array[goalowners])
    end


    def self.published_unit_goals
      self.where(draft: false).find_all { |g| g.owners.any? { |x| x.kind_of? Unit } }
    end


    def self.all_viewable_by(user, year = nil)
      q = self
      q = q.where(goal_year: year) unless year.nil?
      q.all.find_all { |g| g.viewable_by? user }
    end


    def editable_by?(user)
      user.is_admin or owners.include?(user) or creator == user
    end


    def viewable_by?(user)
      return true if owners.any?{|o| o.kind_of? Unit}
      # puts "Checking #{title} against #{user.name}"
      return true if creator_uniqname == user.uniqname
      # puts "#{creator_uniqname} is not the same as #{user.uniqname}"
      return true if owners.include? user
      # puts "#{owners} does not include #{user}"
      return true if user.is_admin and !draft?
      return false
    end



    def replace_owners(new_owners)
      LOG.error("Replace owners given a nil") if new_owners.any? {|x| x.nil?}
      save if id.nil?
      remove_all_associated_owners
      goalowners = Array(new_owners)

      goalowners.each { |o| add_associated_owner(o) }
      save
      self
    end


    def replace_associated_goals(newgoals)
      save if id.nil?
      remove_all_parent_goals
      Array(newgoals).each { |g| add_parent_goal(g) }
      self
    end


    def tagged_id
      "g#{self.id}"
    end


    def person_or_unit(uniqname)
      Person.find(uniqname: uniqname) || Unit.find(uniqname: uniqname)
    end


    def owners
      self.associated_owners.map { |x| person_or_unit(x.uniqname) }
    end

    def owner_names
      self.owners.map { |x| x.name }
    end


    def creator
      person_or_unit(creator_uniqname)
    end


    def creator=(goalowner)
      self.creator_uniqname = goalowner.uniqname
    end


    def draft?
      self.draft == 1
    end


    def draft!
      self.draft = 1
    end


    def publish!
      self.draft = 0
    end


    def target_date_string
      return '' unless t = target_date
      '%4d/%02d' % [t.year, t.month]
    end


    def unit_key
      lowest_unit.abbreviation
    end

  end
end
