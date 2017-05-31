require_relative 'sql_models'

class Filter
  KEYS = %w[whose year unit status person]

  def initialize(params, user)
    @f = {}
    @user = user
    KEYS.each {|k| @f[k] = Array(params[k])}
    @unit_objects = GoalsViz::Unit.where(uniqname: self.unit)
  end

  def checked_for(key, value)
    @f[key.to_s].include?(value.to_s) ? 'checked="checked"' : ""
  end

  # Create the accessors for the arrays
  KEYS.each do |k|
    define_method(k.to_sym) { @f[k.to_s] }
  end

  def whose_selected_description_pair
    whose.empty? ? nil : %w(owner me)
  end

  def year_selected_description_pair
    year.empty? ? nil : ["year",  year.join(',')]
  end

  def unit_selected_description_pair
    unit.empty? ? nil : ["unit", unit.sort.join(',')]
  end

  def status_selected_description_pair
    status.empty? ? nil : ["status", status.join(',')]
  end

  def selected_description_pairs
    [whose_selected_description_pair, year_selected_description_pair, unit_selected_description_pair, status_selected_description_pair].compact
  end


  # Build up the set of goals
  def filtered_goals
    # do the easy stuff -- year and status
    goals = GoalsViz::Goal.where(year_filterhash.merge(status_filterhash))

    # Now the personal / division stuff. How should that work? Creator? Owner?
    # Steward? All of the above?
    goals = filter_by_mine(goals)
    goals = filter_by_unit(goals)
    # goals = filter_by_person(goals)
    goals
  end

  def filter_by_mine(goals)
    if whose.include? @user.uniqname
      goals.where(associated_owners: @user).or(associated_stewards: @user)
    else
      goals
    end
  end

  def filter_by_unit(goals)
    if unit.empty?
      goals
    else
      goals.where(associated_owners: @unit_objects)
    end
  end


  def sequel_filter
    KEYS.inject({}) {|acc, k| acc[k.to_sym] = @f[k.to_s] unless @f[k.to_s].empty?; acc}
  end


  def year_filterhash
    if year.empty?
      {}
    else
      {goal_year: year}
    end
  end

  def status_filterhash
    if status.empty?
      {}
    else
      {status: status}
    end
  end

end
