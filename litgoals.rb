Encoding.default_external = 'utf-8'

require 'roda'

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


class LITGoalsApp < Roda

  plugin :render, cache: false, engine: 'erb'
  plugin :json, :classes=>[Array, Hash, Sequel::Model, GoalsViz::Person]

  route do |r|
    r.root do
      view "test", locals: {greeting: "Hi Bill"}
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

