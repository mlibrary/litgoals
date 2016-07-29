require 'sequel'

module GoalsViz

  class Unit < Sequel::Model(DB[:goalowner].where(is_unit: true))
    plugin :tree, :primary_key => :parent_uniqname, :key => :parent_uniqname, :parent => {:key => :parent_uniqname}
    alias_method :parent_unit, :parent
    plugin :after_initialize

    def after_initialize # or after_initialize
      super
      self.is_unit = true if self.is_unit.nil?
    end

    alias_method :abbreviation, :uniqname
    alias_method :name, :lastname
    alias_method :subunits, :children

    def people
      Person.where(unit: self.subunits.push[self])
    end

  end

  class Person < Sequel::Model(DB[:goalowner].where(is_unit: false))
    plugin :tree, :primary_key => :parent_uniqname, :key => :parent_uniqname, :parent => {:key => :parent_uniqname, :name => :parent}
    alias_method :unit, :parent

    plugin :after_initialize

    def after_initialize # or after_initialize
      super
      self.is_unit = false if self.is_unit.nil?
    end


  end

end
