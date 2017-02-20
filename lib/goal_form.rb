require_relative 'sql_models'

module GoalsViz
  class GoalForm
    def self.goal_from_params
      # Pull out the goal id,
      goal_id = begin
        g = params.delete('goal_id').strip
        g = Integer(g)
        Goal[g]
      rescue
        Goal.new
      end

      new_associated_goal_ids = params.delete('associated_owner').split(/\s*,\s*/).delete_if(&:empty).map(&:to_i)
      new_associated_goals    = Goals.where(id: new_associated_goal_ids)



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
