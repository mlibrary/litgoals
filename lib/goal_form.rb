require_relative 'sql_models'
require 'kramdown'

module GoalsViz

  class FormData
    DEFAULT_DATE = '2017/06'

    attr_reader :goal_id, :associated_goal_ids, :owner_ids, :date, :id

    def initialize(params_orig)
      @errors              = []
      params               = params_orig.dup
      @associated_goal_ids = parse_associated_goal_ids(params.delete('associated-goals'))
      @owner_ids           = params.delete('associated-owners')
      @draft               = params.delete('draft')
      @id                  = params.delete('goal_id')

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
      !(@draft.nil? or @draft.empty? or @draft == 0)
    end

    def parse_associated_goal_ids(str = "")
      return [] unless str =~ /\d/
      str.split(/\s*,\s*/).delete_if(&:empty?).map(&:to_i)
    end

    def associated_goals
      Goal.where(id: associated_goal_ids)
    end

    def owners
      GoalOwner.where(id: owner_ids)
    end

    def is_new?
      id.nil? or id.empty?
    end


  end


  class GoalForm

    attr_reader :goal, :user
    def initialize(goal: goal, user: user)

    end

    def self.goal_from_form(params)

      d    = FormData.new(params)

      # Pull out the goal id,
      goal = if d.is_new?
               Goal.new
             else
               Goal[d.id.to_i]
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
      goal

    end




  end

  class GoalListDisplay
    DEFAULT_DATE = '2017/06'

    attr_reader :goal, :user
    def initialize(goal, user)
      @goal = goal
      @user = user
    end

    def goal_published_status
      goal.draft? ? "Draft" : ""
    end


    def owner_names
      @goal.owners.map(&:name)
    end

    def editable?
      goal.editable_by?(user)
    end

    def mygoal?

      goal.owners.include?(user)
    end

    def to_h
      {
          "goal-published-status" => goal.draft? ? "Draft" : "Published",
          "goal-fiscal-year" => goal.goal_year,
          "goal-target-date-timestamp" => goal.target_date_string,
          "goal-target-date" => goal.target_date_string,
          "goal-owners" => owner_names.join("<br>"),
          'goal-title' => goal.title,
          'goal-description' => Kramdown::Document.new(goal.description, input: 'GFM', header_offset: 4).to_html,
          'goal-edit-href' => "/litgoals/edit_goal/#{@goal.id}",
          'goal-edit-show' => editable? ? "" : "display: none",
          'goal-my-goal' => mygoal? ? "My Goal" : ""
      }

    end



  end
end

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
