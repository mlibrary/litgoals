# Create a json object representing the current goals and org-chart
# We have three types of objects:
#  * Unit
#  * Person
#  * Goal
#
# And four types of links
#  * unit is_a_subunit_of other_unit
#  * person is_a_member_of unit
#  * goal is_a_subgoal_of other_goal
#  * goal belongs_to person_or_unit
#
# The structure is as follows
#
# {
#   "person": [list of person objects, ids start with 'p']
#   "unit": [list of unit objects, ids start with 'u']
#   "goal": [list of goal objects, ids start with 'g']
#   "is_subunit_of": [[u_sub_id, u_super_id], [u_sub_id, u_super_id], ...]
#   "is_member_of": [[p_id, u_id], [p_id, u_id], ...]
#   "is_subgoal_of": [[g_sub_id, g_super_id], [g_sub_id, g_super_id], ...]
#   "is_goal_of": [[gid, person_or_unit_id],[gid, person_or_unit_id],...]
# }

class GoalsViz::JSONGraph

  def self.simple_graph

    person = GoalsViz::Person.all.map do |p|
      {
          id:        p.tagged_id,
          uniqname:  p.uniqname,
          lastname:  p.lastname,
          firstname: p.firstname
      }
    end

    unit = GoalsViz::Unit.all.map do |u|
      {
          id:           u.tagged_id,
          abbreviation: u.abbreviation,
          name:         u.name,
      }
    end

    goal = GoalsViz::Goal.all.map do |g|
      {
          id:          g.tagged_id,
          title:       g.title,
          description: g.description,
          status:      g.status,
          notes:       g.notes,
          is_draft:    g.draft?
      }
    end

    is_subunit_of = GoalsViz::Unit.all.map do |u|
      u.parent ? [u.tagged_id, u.parent.tagged_id] : nil
    end.compact

    is_member_of = GoalsViz::Person.all.map do |p|
      p.unit ? [p.tagged_id, p.unit.tagged_id] : nil
    end.compact

    is_subgoal_of = GoalsViz::Goal.all.flat_map do |g|
      g.parent_goals.map { |pg| [g.tagged_id, pg.tagged_id] }
    end

    is_goal_of = GoalsViz::Goal.all.flat_map do |g|
      g.owners.map do |go|
        [g.tagged_id, go.tagged_id]
      end
    end

    {
        person:        person,
        goal:          goal,
        unit:          unit,
        is_subunit_of: is_subunit_of,
        is_goal_of:    is_goal_of,
        is_member_of:  is_member_of,
        is_subgoal_of: is_subgoal_of
    }

  end
end
