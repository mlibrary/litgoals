Encoding.default_external = 'utf-8'

require 'dotenv'
Dotenv.load

require 'roda'
require 'pry'
require 'sequel'
require 'forme'

require 'logger'
LOG = Logger.new(STDERR)

require_relative "lib/constants"
require_relative "lib/sql_dbh"


# Need to set the GoalsViz::DB before requiring the models
GoalsViz::DB.setup_from_environment

# Now that we've got GoalsViz::DB, we can...
require_relative "lib/sql_models"

Sequel::Model.plugin :json_serializer

UNITS = GoalsViz::Unit.each_with_object({}) do |u, acc|
  acc[u.uniqname] = u
end
SORTED_UNITS = UNITS.to_a.map { |a| a[1] }.sort { |a, b| a.name <=> b.name }



def get_uniqname_from_env
  'dueberb'
end


def goal_form_locals(user, goal=nil)
  goal ||= GoalsViz::Goal.new

  gforme = Forme::Form.new(goal)

  forme                   = Forme::Form.new
  units                   = GoalsViz::Unit.all.sort { |a, b| a.lastname <=> b.lastname }
  interesting_goal_owners = SORTED_UNITS.dup.unshift(user)

  statuses = GoalsViz::Status.order_by(:id).map do |gs|
    checked = gs.name == goal.status ? true : false
    [gs.name, gs.name, checked]
  end

  unless goal.status
    statuses[0][2] = true; # default the first one
  end


  {
      forme:                             forme,
      user:                              user,
      units:                             units,
      platform:                          GoalsViz::PLATFORM_SELECT,
      status_triples:                    statuses,
      goal:                              goal,
      gforme:                            gforme,
      goalowners_to_show_goals_for:      interesting_goal_owners,
      selectize_associated_goal_options: goal_list_for_selectize(interesting_goal_owners),
      parent_goal_ids:                   goal.parent_goals.map(&:id)


  }

end


# Turn a form submission into a goal

def goal_from_params(params)
  goal_id  = params.delete('goal_id')
  ags      = params.delete('associated-goals')
  bad_date = params.delete('target_date') unless (GoalsViz::DATEFORMAT.match params['target_date'])
  goal     = (goal_id != '') ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new
  LOG.warn(params)
  goal.set_all(params)
  goal
end





def goal_list_for_selectize(list_of_owners)
  list_of_owners.map(&:goals).flatten.uniq.map do |g|
    {
        title:       g.title,
        uid:         g.id,
        domain:      g.owner.name,
        description: g.description || "[no description given]"
    }
  end.to_json
end

def goal_list_for_display(list_of_owners, user)
  list_of_owners.map(&:goals).flatten.uniq.map do |g|
    td = g.target_date ? [g.target_date.year, g.target_date.month].join('/') : '2016/12'
    {
        'goal-associated':            g.owner.name,
        'goal-target-date':           td,
        'goal-target-date-timestamp': td,
        'goal-title':                 g.title,
        'goal-description':           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        'goal-my-goal':               g.owner.id == user.id ? 'My Goal' : '',
        'goal-edit-show':             (user.is_admin or g.owner == user) ? '' : 'display: none;',
        'goal-edit-href':             (user.is_admin or g.owner == user) ? "/edit_goal/#{g.id}" : ''
    }
  end.to_json

end

# "Unit Name" => [list,of,goals]
def division_goal_tree

  h = Hash.new { [] }

  GoalsViz::Goals.all_unit_goals.each do |g|
    h[UNITS[g.owner_uniqname].name] << g
  end

  h
end

def save_goal(goal, associated_goals)
  goal.save
  ags = Array(associated_goals).delete_if(&:empty?)
  unless ags.empty?
    goal.remove_all_parent_goals
    goal.save
    ags.each { |ag| LOG.warn("Adding parent goal #{ag}"); goal.add_parent_goal(GoalsViz::Goal[ag.to_i]); }
    goal.save
  end

end


class LITGoalsApp < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']


  plugin :render, cache: false, engine: 'erb'
  plugin :json, :classes => [Array, Hash, Sequel::Model, GoalsViz::Person]
  plugin :public
  plugin :flash
  plugin :slash_path_empty

  plugin :error_handler do |e|
    "<pre>Oh No!
      #{e.message}
    #{e.backtrace.join "\n"}</pre>"

  end

  route do |r|
    uniqname          = get_uniqname_from_env()
    user              = GoalsViz::Person.find(uniqname: uniqname)
    user.is_admin     = true
    my_orgchart_goals = user.my_orgchart_goals


    r.root do
      # view "about", locals: {user: user}
      r.redirect '/goals'
    end

    r.get 'goals' do
      interesting_owners = SORTED_UNITS.dup.unshift(user)

      locals = {
          user:                  user,
          goal_list_for_display: goal_list_for_display(interesting_owners, user)
      }
      view 'goals', locals: locals
    end


    r.on "new_goal" do
      r.get do
        locals = goal_form_locals(user, flash['bad_goal'])
        @title = 'Create a new goal'
        view "new_goal", locals: locals
      end

      r.post do
        LOG.warn(r.params)
        validation = GoalsViz::GoalSchema.(r.params)
        errors     = validation.messages(full: true)
        ags        = r.params.delete('associated-goals')
        g          = goal_from_params(r.params)
        is_newgoal = g.id.nil?
        LOG.warn("Goal from params is #{g}")
        if errors.size > 0
          LOG.warn "Problem: #{errors.values}"
          flash['error_msg'] = errors.values
          r.redirect
        else
          LOG.warn "Saving goal #{g.id}"
          save_goal(g, ags)
          action = is_newgoal ? "added" : "edited"
          flash['goal_added_msg'] = "Goal <em>#{g.title}</em> #{action}"
          r.redirect("/edit_goal/#{g.id}")
        end
      end
    end

    r.on "edit_goal/:goalid" do |goalid|
      gid = goalid.to_i
      unless user.is_admin or user.goals.map(&:id).include? gid
        flash[:error_msg] = "You're not allowed to edit that goal (must be owner or admin)"
        r.redirect "/new_goal"
      end
      r.get do
        goal   = GoalsViz::Goal.find(id: goalid.to_i)
        locals = goal_form_locals(user, goal)
        @title = "Edit '#{goal.title}'"
        view "new_goal", locals: locals
      end
    end

    # r.get "goal/:goalid" do |goalid|
    #   gid  = goalid.to_i
    #   goal = GoalsViz::Goal[gid]
    #   unless user.is_admin or goal.owner.is_admin or user.goals.include?(goal)
    #     flash[:error_msg] = "You're not allowed to view that goal (must be owner or admin)"
    #     r.redirect "/goals"
    #   end
    #
    #   view "goal", locals: {goal: goal}
    #
    # end


    r.on 'api' do

      r.get 'user/:uniqname' do |uniqname|
        u = GoalsViz::Person.find(uniqname: uniqname)
        u.to_json
      end
    end

    r.public

  end
end
