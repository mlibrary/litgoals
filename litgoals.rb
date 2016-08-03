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


def goal_from_params(params)
  _, goal_id              = params.delete('goal_id')
  _, ags                  = params.delete('associated-goals')
  bad_date = params.delete('target_date') unless (DATEFORMAT.match params['target_date'])
  goal = GoalsViz::Goal.new(params)
  goal.id = goal_id
  goal

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
    uniqname = get_uniqname_from_env()
    user     = GoalsViz::Person.find(uniqname: uniqname)


    r.root do
      render "goals_list"
    end


    r.on "new_goal" do
      r.get do
        locals = goal_form_locals(user, flash['bad_goal'])
        @title = 'Create a new goal'
        view "new_goal", locals: locals
      end

      r.post do
        validation = GoalSchema.(r.params)
        errors = validation.messages(full: true)
        if errors.size > 0
          g                       = goal_from_params(r.params)
          flash['bad_goal']       = g
          flash['goal_rejected_msg'] = errors.values
          flash.to_json
          r.redirect
        else
          g = goal_from_params(r.params)
          flash['goal_added_msg'] = "Goal '#{g.title}' added"
          g.save
          r.redirect
        end
      end
    end

    r.on "edit_goal/:goalid" do |goalid|
      r.get do
        goal   = GoalsViz::Goal.find(id: goalid.to_i)
        locals = goal_form_locals(user, goal)
        @title = "Edit '#{goal.title}'"
        view "new_goal", locals: locals
      end
    end


    r.on 'api' do

      r.get 'user/:uniqname' do |uniqname|
        u = GoalsViz::Person.find(uniqname: uniqname)
        u.to_json
      end
    end

    r.public

  end
end

