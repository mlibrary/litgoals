require 'sequel'

module GoalsViz

  # Pre-declare everything so the associations work
  class GoalOwner < Sequel::Model; end
  class Goal < GoalOwner; end
  class Unit < GoalOwner; end
  class Person < GoalOwner; end

  class GoalOwner < Sequel::Model
    set_dataset DB[:goalowner]
    plugin :after_initialize

    one_to_many :goals, class: Goal, primary_key: :uniqname, key: :owner_uniqname

    def parent
      self.class.find(uniqname: parent_uniqname)
    end

    def lowest_unit
      self.is_unit ? self : self.parent
    end


    def ancestors
      case parent_uniqname
        when nil
          []
        else
          self.parent.ancestors.unshift self.class.find(uniqname: parent_uniqname)
      end
    end

    def self_and_ancestors
      self.ancestors.unshift self
    end

    def people
      Person.where(parent_uniqname: self.uniqname).all
    end



  end

  class Unit < GoalOwner
    set_dataset DB[:goalowner].where(is_unit: true)

    one_to_many :subunits,   class: Unit,   primary_key: :uniqname,        key: :parent_uniqname
    many_to_one :parent_unit,class: Unit,   primary_key: :parent_uniqname, key: :uniqname
    one_to_many :people,     class: Person, primary_key: :uniqname,        key: :parent_uniqname
    one_to_many :goals,      class: Goal,   primary_key: :owner_uniqname,  key: :uniqname

    def after_initialize # or after_initialize
      super
      self.is_unit = true if self.is_unit.nil?
    end

    alias_method :abbreviation, :uniqname
    alias_method :name, :lastname
    alias_method :parent_unit, :parent

  end

  class Person < GoalOwner
    set_dataset DB[:goalowner].where(is_unit: false)

    one_to_many :children, class: self, primary_key: :uniqname, key: :parent_uniqname
    many_to_one :parent, class: self, primary_key: :parent_uniqname, key: :uniqname


    def parent
      GoalsViz::Unit.find(uniqname: parent_uniqname)
    end

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

    one_to_many :goals,      class: Goal,   primary_key: :owner_uniqname,  key: :uniqname

    def target_date_string
      return '' unless t = target_date
      '%4d/%02d' % [t.year, t.month]
    end

    def owner
      Person.find(uniqname: owner_uniqname) || Unit.find(uniqname: owner_uniqname)
    end

    def creator
      Person.find(uniqname: owner_uniqname)
    end


    def unit_key
      lowest_unit.abbreviation
    end

  end
end
