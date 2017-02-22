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
      goal.target_date = d.date


      if d.draft?
        goal.draft!
      else
        goal.publish!
      end

      goal.set_all(d.unahandled_args.to_h)

    end


  end

  class FormFillObject
    def initialize(goal)
      @goal = goal
    end

    def goal_published_status

    end

    def to_json

    end



  end
end

# {
#   "goal-published-status" : "Not started",
#   "goal-fiscal-year" : 2015,
#   "goal-target-date-timestamp" : "2016/6",
#   "goal-owners" : "Architecture & Engineering<br/>Learning Technologies Incubation Group",
#   "goal-target-date" : "2016/6",
#   "goal-title" : "Library Credential Badging Investigation Team ",
#   "goal-edit-show" : "",
#   "goal-description" : "Lorum whatever",
#   "goal-edit-href" : "/litgoals/edit_goal/19",
#   "goal-my-goal" : ""
# }

# {
#   forme: forme,
#   user: user,
#   units: units,
#   status_options: status_options,
#   selected_status: goal.status.nil? ? status_options[0][0] : goal.status,
#   goal: goal,
#   gforme: gforme,
#   goalowners_to_show_goals_for: interesting_goal_owners,
#   selectize_associated_goal_options: goal_list_for_selectize(interesting_goal_owners),
#   parent_goal_ids: goal.parent_goals.map(&:id)
#
#
# }
# Turn a form submission into a goal
#
#
# # noinspection RubyInterpreterInspection
# def goal_from_params(params)
#   LOG.warn params
#   goal_id   = params.delete('goal_id')
#   ags       = params.delete('associated-goals')
#   newowners = params.delete('associated_owners')
#   bad_date  = params.delete('target_date') unless (GoalsViz::DATEFORMAT.match params['target_date'])
#   goal      = (goal_id.strip =~ /\A\d+\Z/) ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new
#
#   draft = params.delete('draft')
#
#   if (draft.nil? or draft.empty?)
#     goal.publish!
#   else
#     LOG.warn "Saving as a draft"
#     goal.draft!
#   end
#
#   goal.set_all(params)
#   goal
# end
