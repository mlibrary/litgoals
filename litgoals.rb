Encoding.default_external = 'utf-8'

require 'roda'
require 'pry'
require 'sequel'
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
end

# Load up the models

Sequel::Model.plugin :json_serializer
require_relative 'models/sql_models'


binding.pry

puts 3

__END__

class LITGoalsApp < Roda

  plugin :render, cache: false, engine: 'erb'
  plugin :json, :classes=>[Array, Hash, Sequel::Model, GoalsViz::Person]

  route do |r|
    uniqname = get_uniqname_from_env()
    user = GoalsViz::Person.find(uniqname: uniqname)



    locals = {
        user: user,
        pagetitle: "Your goals"
    }

    r.root do
      render "goals_list", locals: {user: user}
    end

    r.get 'hello' do
      "Hi there"
    end

    r.on 'api' do

      r.get 'user/:uniqname' do |uniqname|
        u = GoalsViz::Person.find(uniqname: uniqname)
        u.to_json
      end
    end

  end
end

