Encoding.default_external = 'utf-8'

require 'roda'
require 'pry'
require 'sequel'
require 'forme'

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


def get_uniqname_from_env
  'dueberb'
end


def goal_form_locals(user, goal=nil)
  goal     ||= GoalsViz::Goal.new

  goal = GoalsViz::Goal.first
  gforme = Forme::Form.new(goal)

  forme    = Forme::Form.new
  units    = GoalsViz::Unit.all.sort { |a, b| a.lastname <=> b.lastname }
  statuses = GoalsViz::Status.order_by(:id).map {|x| [x.name, x.name]}

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

class LITGoalsApp < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']


  plugin :render, cache: false, engine: 'erb'
  plugin :json, :classes => [Array, Hash, Sequel::Model, GoalsViz::Person]
  plugin :public
  plugin :flash

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
        view "new_goal", locals: goal_form_locals(user)
      end

      r.post do
        r.params.to_json
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

