require_relative 'sql_models'

class Filter
  ARRAY_KEYS = %w[whose year unit status]
  SCALAR_KEYS = %w[person searchkeywords]

  def initialize(params, user)
    @f    = {}
    @user = user
    ARRAY_KEYS.each {|k| @f[k] = Array(params[k])}
    SCALAR_KEYS.each {|k| @f[k] = params[k]}
    @unit_objects = GoalsViz::Unit.where(uniqname: self.unit)
  end

  def checked_for(key, value)
    @f[key.to_s].include?(value.to_s) ? 'checked="checked"' : ""
  end

  # Create the accessors for the arrays
  [ARRAY_KEYS, SCALAR_KEYS].flatten.each do |k|
    define_method(k.to_sym) {@f[k.to_s]}
  end


  def whose_selected_description_pair
    whose.empty? ? nil : %w(owner me)
  end

  def year_selected_description_pair
    year.empty? ? nil : ["year", year.join(',')]
  end

  def unit_selected_description_pair
    unit.empty? ? nil : ["unit", unit.sort.join(',')]
  end

  def status_selected_description_pair
    status.empty? ? nil : ["status", status.join(',')]
  end

  def selected_description_pairs
    [whose_selected_description_pair,
     year_selected_description_pair,
     unit_selected_description_pair,
     status_selected_description_pair].compact
  end

  def filter_pairs
    sd =      selected_description_pairs

    if searchkeywords and searchkeywords =~ /\S/
      sd.unshift(['keywords', searchkeywords])
    end

    if person and person =~ /\S/
      sd.unshift ['owner', GoalsViz::Person.where(uniqname: person).first.name]
    end

    sd
  end


  # Build up the set of goals

  # a little helper
  def ilike_person(str)
    Sequel.ilike(:people, '%' + str + '%')
  end

  def filtered_goals
    # do the easy stuff -- year and status and keyword


    goals = GoalsViz::Goal


    # If we've got keywords, build up a search of the fulltext index as well
    # as the people
    if searchkeywords =~ /\S/
      words = searchkeywords.split(/\s+/)
      firstword = words.first
      peoplesearch = words.inject(goals.db[:goalsearch].select(:id).where(ilike_person(firstword))) {|acc, k| acc.or(ilike_person(k))}
      goals        = goals.where(keyword_filter(searchkeywords)).or(id: peoplesearch)
    end


    # Now the personal / division stuff. How should that work? Creator? Owner?
    # Steward? All of the above?
    goals = goals.where(year_filterhash)
    goals = goals.where(status_filterhash)
    goals = filter_by_unit(goals)
    goals = filter_by_person(goals)
    goals = filter_by_mine(goals)
    puts goals.sql
    goals
  end

  def filter_by_person(goals)
    puts "Person is #{person}"
    # Are we restricted to a particular person?
    if person and person =~ /\S/
      p = GoalsViz::Person.where(uniqname: person)
      # goals.all.find_all{|g| g.owners.map(&:uniqname).concat(g.stewards.map(&:uniqname)).include? person}
      goals.where(associated_owners: p).or(associated_stewards: p)
    else
      goals
    end
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
      valid_owners = GoalsViz::GoalOwner.where(parent_uniqname: unit).or(uniqname: unit)
      goals.where(associated_owners: valid_owners)
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

  def keyword_filter(kw)
    if kw and kw =~ /\S/
      Sequel.lit("match (title, description) against(? in natural language mode)", kw)
    else
      {} # null search
    end

  end

end
