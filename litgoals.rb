Encoding.default_external = 'utf-8'

require 'roda'
require 'forme'
require 'json'
require 'date'
require 'logger'

require_relative "lib/sql_models"
require_relative "lib/json_graph"
require_relative 'lib/constants'
require_relative 'lib/Utils/fiscal_year'
require_relative 'lib/goal_form'
require_relative 'lib/goal_search_result'
require_relative 'lib/filter'

Sequel::Model.plugin :json_serializer


# Set up logging and defaults for testing

LOG                   = Logger.new(STDERR)
DEFAULT_USER_UNIQNAME = 'dueberb'
# DEFAULT_USER_UNIQNAME = 'rsteg'

#
UNITS                 = GoalsViz::Unit.abbreviation_to_unit_map
SORTED_UNITS          = UNITS.values.sort {|a, b| a.abbreviation <=> b.abbreviation}
STATUS_OPTIONS        = GoalsViz::Status.order_by(:id).map {|s| [s.name, s.name]}
STATUS_LIST           = STATUS_OPTIONS.map(&:first)


def goal_form_locals(user, goal=nil)
  goal ||= GoalsViz::Goal.new

  gforme = Forme::Form.new(goal)

  forme                   = Forme::Form.new
  units                   = GoalsViz::Unit.all.sort {|a, b| a.lastname <=> b.lastname}
  interesting_goal_owners = SORTED_UNITS + [user]
  status_options          = GoalsViz::Status.order_by(:id).map {|s| [s.name, s.name]}

  {
      forme:                             forme,
      user:                              user,
      units:                             SORTED_UNITS,
      status_options:                    status_options,
      selected_status:                   goal.status.nil? ? status_options[0][0] : goal.status,
      goal:                              goal,
      gforme:                            gforme,
      goalowners_to_show_goals_for:      interesting_goal_owners,
      selectize_associated_goal_options: goal_list_for_selectize(interesting_goal_owners),
      parent_goal_ids:                   goal.parent_goals.map(&:id)


  }

end


# restrict to those of the currently-selected year.
def goal_list_for_selectize(list_of_owners)

  list_of_owners.map(&:reload).map(&:goals).flatten.uniq.map do |g|
    {
        title:       g.title,
        uid:         g.id,
        year:        g.goal_year,
        domain:      g.owner_names.join(', '),
        description: g.description || "[no description given]"
    }
  end.to_json
end


class LITGoalsApp < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']


  plugin :render, cache: false, engine: 'erb', layout_opts: {merge_locals: true}
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
    r.root do
      r.redirect '/litgoals/goals'
    end


    r.on "litgoals" do

      # Set up some useful data for later on
      uniqname  = r.env['HTTP_X_REMOTE_USER'] || DEFAULT_USER_UNIQNAME
      user      = GoalsViz::Person.find(uniqname: uniqname)
      currentFY = GoalsViz::FiscalYear.new

      common_locals= {
          user:                user,
          current_fiscal_year: currentFY
      }

      # Redirect to current year of goals if no year given.
      r.is do
        r.redirect "goals"
      end

      # Give the full graph if asked for
      r.on "jsongraph" do
        GoalsViz::JSONGraph.simple_graph
      end

      r.on 'goal' do
        r.get /(\d+)/ do |id|
          g = GoalsViz::GoalSearchResult.new(GoalsViz::Goal[id.to_i])
          if g.viewable_by?(user)
            view 'goal/single_page', locals: common_locals.merge(goal: g)
          else
            response.status = 404
          end

        end
      end

      r.on 'goals' do
        r.is do
          f = Filter.new(r.params, user)
          goals  = f.filtered_goals.find_all{|g| g.viewable_by?(user)}
          locals = common_locals.merge ({
              goals:    goals.map {|g| GoalsViz::GoalSearchResult.new(g)},
              units:    SORTED_UNITS,
              statuses: STATUS_LIST,
              filter:   f
          })
          view 'goals', locals: locals
        end

      end


      r.on "create" do
        r.get do
          locals                           = common_locals.merge goal_form_locals(user, flash[:bad_goal])
          locals[:two_years_of_fy_options] = currentFY.select_list(2)

          @pagetitle = 'Create a new goal'
          view "create", locals: locals
        end

        # Submit for saving
        r.post do

          validation = GoalsViz::GoalSchema.(r.params)
          errors     = validation.messages(full: true)


          is_newgoal = r.params['goal_id'].nil?

          g                  = GoalsViz::GoalForm.goal_from_form(r.params)
          g.creator_uniqname ||= user.uniqname

          if errors.size > 0
            LOG.warn "Problem: #{errors.values}"
            flash[:error_msg] = errors.values
            flash[:bad_goal]  = g
            r.redirect
          else
            g.save
            action                 = is_newgoal ? "added" : "edited"
            flash[:goal_added_msg] = "Goal \"#{g.title}\" #{action}"
            sleep 0.5
            r.redirect currentFY.goals_url
          end
        end
      end

      r.on "edit_goal/:goalid" do |goalid|
        gid = goalid.to_i
        unless user.is_admin or user.goals.map(&:id).include? gid
          flash[:error_msg] = "You're not allowed to edit that goal (must be owner/creator or admin)"
          r.redirect currentFY.goals_url
        end

        r.get do
          goal                             = GoalsViz::Goal.find(id: goalid.to_i)
          locals                           = common_locals.merge goal_form_locals(user, goal)
          locals[:two_years_of_fy_options] = currentFY.select_list(2)
          @pagetitle                       = "Edit '#{goal.title}'"
          view "create", locals: locals
        end
      end


      r.on 'api' do
        r.on 'env' do
          "<pre>" + r.env.keys.sort.map {|k| "#{k} => #{r.env[k]}"}.join("\n") + "</pre>"
        end

        r.get 'user/:uniqname' do |uniqname|
          u = GoalsViz::Person.find(uniqname: uniqname)
          u.name
        end
      end

      r.public
    end

  end
end
