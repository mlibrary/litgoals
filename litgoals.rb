Encoding.default_external = 'utf-8'

require 'roda'
require 'forme'
require 'json'
require 'date'

require 'logger'
LOG = Logger.new(STDERR)


require_relative "lib/sql_models"
require_relative "lib/json_graph"
require_relative 'lib/constants'
require_relative 'lib/Utils/fiscal_year'


Sequel::Model.plugin :json_serializer


UNITS = GoalsViz::Unit.each_with_object({}) do |u, acc|
  acc[u.uniqname] = u
end
SORTED_UNITS = UNITS.to_a.map { |a| a[1] }.sort { |a, b| a.name <=> b.name }

COSIGN_LOGOUT="https://weblogin.umich.edu/cgi-bin/logout?http://www.lib.umich.edu/"

DEFAULT_USER_UNIQNAME = 'dueberb'


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
  goal = (goal_id != '') ? GoalsViz::Goal[goal_id.to_i] : GoalsViz::Goal.new

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

  ownergoals = list_of_owners.map(&:reload).map(&:goals)
  mygoals = GoalsViz::Goal.where(creator_uniqname: user.uniqname).to_a
  allgoals = (ownergoals.concat(mygoals)).flatten.uniq.sort { |a, b| a.id <=> b.id }

  goals = allgoals.select { |g| g.viewable_by?(user) }

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

# "Unit Name" => [list,of,goals]
def division_goal_tree

  h = Hash.new { [] }

  GoalsViz::Goal.all_unit_goals.each do |g|
    g.owners.each do |owner|
      h[UNITS[owner.uniqname].name] << g
    end

  end

  h
end

def save_goal(goal, associated_goals, associated_owners)

  goal.save
  ags = Array(associated_goals)
  unless ags.empty?
    goal.remove_all_parent_goals
    goal.save
  end

  unless associated_owners.empty?
    goal.owners = associated_owners
    goal.save
  end
end

def allunits
  GoalsViz::Unit.all.sort { |a, b| a.name <=> b.name }
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

      uniqname = r.env['HTTP_X_REMOTE_USER'] || DEFAULT_USER_UNIQNAME
      user = GoalsViz::Person.find(uniqname: uniqname)


      currentFY = GoalsViz::FiscalYear.new

      common_locals= {
          user: user,
          current_fiscal_year: currentFY
      }


      r.root do
        r.redirect currentFY.goals_url
      end

      r.on "jsongraph" do
        GoalsViz::JSONGraph.simple_graph
      end

      r.on 'goals' do
        interesting_owners = allunits.unshift(user) #SORTED_UNITS.dup.unshift(user)


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

          year_options = [currentFY, currentFY.next].map{|x| [x.range_string, x.year]}

          locals[:two_years_of_fy_options] = year_options

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
          year_options = [currentFY, currentFY.next].map{|x| [x.range_string, x.year]}

          LOG.warn "Here I am!"
          LOG.warn year_options
          puts "Whoo"
          locals[:two_years_of_fy_options] = year_options
          @pagetitle = "Edit '#{goal.title}'"
          view "create", locals: locals
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
