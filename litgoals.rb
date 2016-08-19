Encoding.default_external = 'utf-8'

require 'roda'
require 'pry'
require 'sequel'
require 'forme'
require 'dry-validation'
require 'logger'

LOG = Logger.new(STDERR)

require 'dotenv'
Dotenv.load

# Set up the DB connection

module GoalsViz
  DB = Sequel.connect(adapter:  ENV['litgoals_adapter'],
                      database: ENV['litgoals_database'],
                      user:     ENV['litgoals_user'],
                      host:     ENV['litgoals_host'],
                      password: ENV['litgoals_password']
  )

  PLATFORM_SELECT = ['Create', 'Scale', 'Build', 'N/A']
end

# Load up the models

Sequel::Model.plugin :json_serializer
require_relative 'models/sql_models'

ENV['RACK_ENV'] = "development"

DATEFORMAT = /\d{4}\/\d{2}/

GoalSchema = Dry::Validation.Form do

  required(:title).filled
  required(:description).filled
  required(:target_date).filled(format?: DATEFORMAT)
end

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
  statuses                = GoalsViz::Status.order_by(:id).map { |x| [x.name, x.name] }
  interesting_goal_owners = SORTED_UNITS.dup.unshift(user)

  {
      forme:                             forme,
      user:                              user,
      units:                             units,
      platform:                          GoalsViz::PLATFORM_SELECT,
      statuses:                          statuses,
      goal:                              goal,
      gforme:                            gforme,
      goalowners_to_show_goals_for:      interesting_goal_owners,
      selectize_associated_goal_options: goal_list_for_selectize(interesting_goal_owners)


  }

end


# Turn a form submission into a goal

def goal_from_params(params)
  goal_id  = params.delete('goal_id')
  ags      = params.delete('associated-goals')
  bad_date = params.delete('target_date') unless (DATEFORMAT.match params['target_date'])
  goal     = goal_id ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new(params)
  goal.id  = goal_id

  goal

end


def all_unit_goals
  GoalsViz::Goal.where(owner_uniqname: GoalsViz::Unit.map(:uniqname)).all
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
        'goal-associated': g.owner.name,
        'goal-target-date': td,
        'goal-target-date-timestamp':td,
        'goal-title': g.title,
        'goal-description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        'goal-my-goal': g.owner == user ? 'My Goal' : '',
        'goal-edit-show': (user.is_admin or g.owner == user) ?  '' : 'display: none;',
        'goal-edit-href': (user.is_admin or g.owner == user) ? "/edit_goal/#{g.id}" : ''
    }
  end.to_json

end

# "Unit Name" => [list,of,goals]
def division_goal_tree

  h = Hash.new { [] }

  all_unit_goals.each do |g|
    h[UNITS[g.owner_uniqname].name] << g
  end

  h
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
    my_orgchart_goals = user.my_orgchart_goals


    r.root do
      # view "about", locals: {user: user}
      r.redirect '/goals'
    end

    r.get 'goals' do
      @title = "#{user.name} and LIT/Department goals"
      locals = {
          user:                         user,
          goalowners_to_show_goals_for: SORTED_UNITS.dup.unshift(user),
          goal_list_for_display: goal_list_for_display(SORTED_UNITS.dup.unshift(user), user)
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
        r.params.to_json
        # validation = GoalSchema.(r.params)
        # errors     = validation.messages(full: true)
        # ags      = r.params.delete('associated-goals')
        # g          = goal_from_params(r.params)
        # LOG.warn("Goal from params is #{g}")
        # if errors.size > 0
        #   flash['error_msg'] = errors.values
        #   flash.to_json
        #   r.redirect
        # else
        #   g.save
        #   ags and Array(ags).each { |ag| LOG.warn("Adding parent goal #{ag}"); g.add_parent_goal(GoalsViz::Goal[ag.to_i]);  }
        #   g.save
        #   flash['goal_added_msg'] = "Goal '#{g.title}' with parent(s) '#{g.parent_goals.map(&:title).join(" / ")}' added"
        #   r.redirect
        # end
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

