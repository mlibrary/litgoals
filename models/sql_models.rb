require 'sequel'

module GoalsViz

  class GoalOwner < Sequel::Model
    plugin :after_initialize

    def parent
      self.class.find(uniqname: parent_uniqname)
    end

    def children
      self.class.where(parent_uniqname: parent_uniqname)
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

    def after_initialize # or after_initialize
      super
      self.is_unit = true if self.is_unit.nil?
    end

    alias_method :abbreviation, :uniqname
    alias_method :name, :lastname
    alias_method :parent_unit, :parent
    alias_method :subunits, :children

  end

  class Person < GoalOwner
    set_dataset DB[:goalowner].where(is_unit: false)

    def parent
      GoalsViz::Unit.find(uniqname: parent_uniqname)
    end

    alias_method :unit, :parent

    plugin :after_initialize

    def after_initialize # or after_initialize
      super
      self.is_unit = false if self.is_unit.nil?
    end


  end

end
