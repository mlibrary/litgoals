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

Sequel::Model.plugin :json_serializer


# Set up logging and defaults for testing

LOG = Logger.new(STDERR)
DEFAULT_USER_UNIQNAME = 'dueberb'

#
UNITS = GoalsViz::Unit.abbreviation_to_unit_map
SORTED_UNITS = UNITS.values.sort { |a, b| a.abbreviation <=> b.abbreviation }



def goal_form_locals(user, goal=nil)
  goal ||= GoalsViz::Goal.new

  gforme = Forme::Form.new(goal)

  forme = Forme::Form.new
  units = GoalsViz::Unit.all.sort { |a, b| a.lastname <=> b.lastname }
  interesting_goal_owners = allunits.unshift(user)
  status_options = GoalsViz::Status.order_by(:id).map { |s| [s.name, s.name] }

  {
      forme: forme,
      user: user,
      units: units,
      status_options: status_options,
      selected_status: goal.status.nil? ? status_options[0][0] : goal.status,
      goal: goal,
      gforme: gforme,
      goalowners_to_show_goals_for: interesting_goal_owners,
      selectize_associated_goal_options: goal_list_for_selectize(interesting_goal_owners),
      parent_goal_ids: goal.parent_goals.map(&:id)


  }

end


# Turn a form submission into a goal

# noinspection RubyInterpreterInspection
def goal_from_params(params)
  LOG.warn params
  goal_id = params.delete('goal_id')
  ags = params.delete('associated-goals')
  newowners = params.delete('associated_owners')
  bad_date = params.delete('target_date') unless (GoalsViz::DATEFORMAT.match params['target_date'])
  goal = (goal_id.strip =~ /\A\d+\Z/) ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new

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


def goal_list_for_selectize(list_of_owners)

  list_of_owners.map(&:reload).map(&:goals).flatten.uniq.map do |g|
    {
        title: g.title,
        uid: g.id,
        domain: g.owner_names.join(', '),
        description: g.description || "[no description given]"
    }
  end.to_json
end


def goal_list_for_display(list_of_owners, user)
  LOG.warn "list_of_owners is nil" if list_of_owners.nil?
  LOG.warn "user is nil" if user.nil?

  # ownergoals = list_of_owners.map(&:reload).map(&:goals)
  # mygoals = GoalsViz::Goal.where(creator_uniqname: user.uniqname).to_a
  # allgoals = (ownergoals.concat(mygoals)).flatten.uniq.sort { |a, b| a.id <=> b.id }

  goals = GoalsViz::Goal.all_viewable_by(user)

  LOG.warn "User #{user.uniqname} is an admin" if user.is_admin

  goals.map do |g|
    td = g.target_date ? [g.target_date.year, g.target_date.month].join('/') : '2017/06'
    is_editor = (user.is_admin or g.owners.include?(user) or g.creator_uniqname == user.uniqname)
    {
        'goal-owners' => g.owners.map(&:name).join('<br/>'),
        'goal-target-date' => td,
        'goal-target-date-timestamp' => td,
        'goal-title' => g.title,
        'goal-description' => g.description,
        'goal-my-goal' => g.owners.include?(user) ? 'My Goal' : '',
        'goal-edit-show' => is_editor ? '' : 'display: none;',
        'goal-edit-href' => is_editor ? "/litgoals/edit_goal/#{g.id}" : '',
        'goal-published-status' => g.draft? ? 'Draft' : g.status,
        'goal-fiscal-year' => g.goal_year
    }
  end
end

def save_goal(goal, associated_goals, associated_owners)

  goal.save
  ags = Array(associated_goals)
  unless ags.empty?
    goal.remove_all_parent_goals
    ags.each {|x| goal.add_parent_goal(x)}
    goal.save
  end

  unless associated_owners.empty?
    goal.owners = associated_owners
    goal.save
  end
end

def allunits
  SORTED_UNITS
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
      r.redirect '/litgoals/'
    end


    r.on "litgoals" do

      # Set up some useful data for later on
      uniqname = r.env['HTTP_X_REMOTE_USER'] || DEFAULT_USER_UNIQNAME
      user = GoalsViz::Person.find(uniqname: uniqname)
      currentFY = GoalsViz::FiscalYear.new

      common_locals= {
          user: user,
          current_fiscal_year: currentFY
      }

      # Redirect to current year of goals if no year given.
      r.root do
        r.redirect currentFY.goals_url
      end

      # Give the full graph if asked for
      r.on "jsongraph" do
        GoalsViz::JSONGraph.simple_graph
      end

      r.on 'goals' do

        # Show the archive page is no year given
        r.is do
          view 'archive', locals: common_locals
        end


        r.get /(\d+)/ do |yearstring|
          year = yearstring.to_i

          locals = common_locals.merge({year: year})

          goals = goal_list_for_display(interesting_owners, user)
          LOG.debug goals.map{|g| "#{g['goal-id']} -- #{g['goal-fiscal-year']}: #{g['goal-title']}"}

          # Filter to just the wanted year
          goals = goals.select { |g| g['goal-fiscal-year'] == year }

          locals[:goal_list_for_display] = goals.to_json
          locals[:goal_year_string] = "#{year}"
          view 'goals', locals: locals
        end

      end


      r.on "create" do
        r.get do
          locals = common_locals.merge goal_form_locals(user, flash[:bad_goal])
          locals[:two_years_of_fy_options] = currentFY.select_list(2)

          @pagetitle = 'Create a new goal'
          view "create", locals: locals
        end

        # Submit for saving
        r.post do
          validation = GoalsViz::GoalSchema.(r.params)
          errors = validation.messages(full: true)

          agIDString = r.params.delete('associated-goals')
          ags = agIDString.split(/\s*,\s*/).delete_if(&:empty?).map { |agid| GoalsViz::Goal[agid.to_i] }
          ownerIDs = r.params.delete('associated-owners')
          owners = GoalsViz::GoalOwner.where(id: ownerIDs).all

          g = goal_from_params(r.params)
          g.creator_uniqname ||= user.uniqname
          is_newgoal = g.id.nil?

          if errors.size > 0
            LOG.warn "Problem: #{errors.values}"
            flash[:error_msg] = errors.values
            flash[:bad_goal] = g
            r.redirect
          else
            LOG.warn "Saving goal #{g.id}"
            save_goal(g, ags, owners)
            action = is_newgoal ? "added" : "edited"
            flash[:goal_added_msg] = "Goal <span class=\"goal-title\">#{g.title}</span> #{action}"
            sleep 0.5
            r.redirect currentFY.goals_url
          end
        end
      end

      r.on "edit_goal/:goalid" do |goalid|
        gid = goalid.to_i
        unless user.is_admin or user.goals.map(&:id).include? gid
          flash[:error_msg] = "You're not allowed to edit that goal (must be owner or admin)"
          r.redirect currentFY.goals_url
        end

        r.get do
          goal = GoalsViz::Goal.find(id: goalid.to_i)
          locals = common_locals.merge goal_form_locals(user, goal)
          locals[:two_years_of_fy_options] = currentFY.select_list(2)
          @pagetitle = "Edit '#{goal.title}'"
          view "create", locals: locals
        end
      end


      r.on 'api' do
        r.on 'env' do
          "<pre>" + r.env.keys.sort.map { |k| "#{k} => #{r.env[k]}" }.join("\n") + "</pre>"
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
