require_relative 'sql_models'

module GoalsViz
  class GoalForm
    def self.goal_from_form(params)
      # Pull out the goal id,
      goal = begin
        g = params.delete('goal_id').strip
        g = Integer(g)
        Goal[g]
      rescue ArgumentError #not an integer
        Goal.new
      end

      # Get and replace associated goals
      # Goals come in on the params as a comma-delimited list.
      # Hmmm. This should be smarter so I don't have to do this here
      new_associated_goal_ids = params.delete('associated_owner').split(/\s*,\s*/).delete_if(&:empty).map(&:to_i)
      new_associated_goals    = Goals.for_ids(new_associated_goal_ids)
      goal.replace_associated_goals(new_associated_goals)

      # Get and replace owners
      goal.replace_owners(GoalsViz::GoalOwner.where(id: params.delete('associated-owners')))
      

      # get and check date
      # get draft status
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
