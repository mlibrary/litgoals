Encoding.default_external = 'utf-8'

require 'roda'
require 'pry'
require 'sequel'
require 'forme'
require 'dry-validation'

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

UNITS = GoalsViz::Goals.all.reduce(Hash.new { [] }) do |acc, u|
  acc[u.uniqname] << u
end


def get_uniqname_from_env
  'dueberb'
end


def goal_form_locals(user, goal=nil)
  goal ||= GoalsViz::Goal.new

  gforme = Forme::Form.new(goal)

  forme    = Forme::Form.new
  units    = GoalsViz::Unit.all.sort { |a, b| a.lastname <=> b.lastname }
  statuses = GoalsViz::Status.order_by(:id).map { |x| [x.name, x.name] }

  {
      forme:    forme,
      user:     user,
      units:    units,
      platform: GoalsViz::PLATFORM_SELECT,
      statuses: statuses,
      goal:     goal,
      gforme:   gforme
  }

end



# Turn a form submission into a goal

def goal_from_params(params)
  _, goal_id = params.delete('goal_id')
  _, ags     = params.delete('associated-goals')
  bad_date   = params.delete('target_date') unless (DATEFORMAT.match params['target_date'])
  goal       = GoalsViz::Goal.new(params)
  goal.id    = goal_id
  goal

end


def all_unit_goals
  GoalsViz::Goal.where(owner_uniqname: GoalsViz::Unit.map(:uniqname)).all
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
    "Oh No! #{e}"
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
          user: user,
          user_goals: user.goals,
          division_goals: division_goal_tree
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
        validation = GoalSchema.(r.params)
        errors     = validation.messages(full: true)
        if errors.size > 0
          g                  = goal_from_params(r.params)
          flash['error_msg'] = errors.values
          flash.to_json
          r.redirect
        else
          g                       = goal_from_params(r.params)
          flash['goal_added_msg'] = "Goal '#{g.title}' added"
          g.save
          r.redirect
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

