require_relative 'sql_models'

module GoalsViz

  class FormData
    DEFAULT_DATE = '2017/06'

    attr_reader :goal_id, :associated_goal_ids, :owner_ids, :date

    def initialize(params_orig)
      @errors              = []
      params               = params_orig.dup
      @goal_id             = params['goal_id']
      @associated_goal_ids = parse_associated_goal_ids(params.delete('associated_goals'))
      @owner_ids           = params.delete('associated-owners')
      @draft               = params.delete('draft')

      date_string = params.delete('target_date')
      if (GoalsViz::DATEFORMAT.match date_string)
        @date = date_string
      else
        @errors.push ["Illegal Date", date_string]
        @date = DEFAULT_DATE
      end

      @rest = params
    end

    def unahandled_args
      @rest
    end

    def draft?
      @draft.nil? or @draft.empty?
    end

    def parse_associated_goal_ids(str)
      str.split(/\s*,\s*/).delete_if(&:empty).map(&:to_i)
    end

    def associated_goals
      Goals.where(id: associated_goal_ids)
    end

    def owners
      GoalOwner.where(id: owner_ids)
    end

  end

  class GoalForm
    def self.goal_from_form(params)

      d    = FormData.new(params)

      # Pull out the goal id,
      goal = begin
        g = Integer(d.goal_id)
        Goal[g]
      rescue ArgumentError #not an integer
        Goal.new
      end


      goal.replace_associated_goals(d.associated_goals)
      goal.replace_owners(d.owners)

      if d.draft?
        goal.draft!
      else
        goal.publish!
      end


      goal.set_all(d.unahandled_args.to_h)


      # get and check date
      # goal.set_all(whatever_is_left_in_params_but_should_be_explicit_probably)


    end


  end
end
# Turn a form submission into a goal


# noinspection RubyInterpreterInspection
def goal_from_params(params)
  LOG.warn params
  goal_id   = params.delete('goal_id')
  ags       = params.delete('associated-goals')
  newowners = params.delete('associated_owners')
  bad_date  = params.delete('target_date') unless (GoalsViz::DATEFORMAT.match params['target_date'])
  goal      = (goal_id.strip =~ /\A\d+\Z/) ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new

  draft = params.delete('draft')

  if (draft.nil? or draft.empty?)
    goal.publish!
  else
    LOG.warn "Saving as a draft"
    goal.draft!
  end

  goal.set_all(params)
  goal
end
