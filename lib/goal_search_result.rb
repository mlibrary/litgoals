require_relative 'sql_models'
require 'kramdown'
require_relative 'Utils/fiscal_year'
require 'forwardable'

# def to_h
#   {
#       "goal-published-status"      => goal.draft? ? "Draft" : "Published",
#       "goal-fiscal-year"           => goal.goal_year,
#       "goal-target-date-timestamp" => goal.target_date_string,
#       "goal-target-date"           => goal.target_date_string,
#       "goal-owners"                => owner_names.join("<br>"),
#       'goal-title'                 => goal.title,
#       'goal-description'           => Kramdown::Document.new(goal.description, input: 'GFM', header_offset: 4).to_html,
#       'goal-edit-href'             => "/litgoals/edit_goal/#{@goal.id}",
#       'goal-edit-show'             => editable? ? "" : "display: none",
#       'goal-my-goal'               => mygoal? ? "My Goal" : ""
#   }
# end

module GoalsViz
  class GoalSearchResult

    extend Forwardable
    def_delegators :@goal, :viewable_by?, :title, :status, :owners, :stewards, :associated_owners, :creator, :draft?, :id

    attr_reader :goal

    def editors
      @editors ||= owners.concat stewards
    end

    def editable_by?(p)
      editors.include? p
    end

    def initialize(goal)
      @goal = goal
    end

    def url
      "/litgoals/goal/#{goal.id}"
    end

    def published_status
      goal.draft? ? "Draft" : "Published"
    end

    def target_date
      goal.target_date_string
    end

    def title
      goal.title
    end

    def child_goals
      goal.child_goals.map{|ag| self.class.new(ag)}
    end

    def parent_goals
      goal.parent_goals.map{|ag| self.class.new(ag)}
    end


    def link
      %Q{<a href="/litgoals/goal/#{goal.id}">#{title}</a>}
    end


    def status
      goal.status
    end

    Scope = Struct.new(:url, :name)
    require 'cgi'
    def scope_links
      units = goal.owners.find_all{|u| u.is_unit}.map{|o| Scope.new("/litgoals/goals?unit=#{CGI.escape(o.uniqname)}", o.name)}
    end

    def owner_links
      units = goal.owners.find_all{|u| !u.is_unit}.map{|o| Scope.new("/litgoals/goals?unit=#{CGI.escape(o.uniqname)}", o.name)}
    end

    def description
      Kramdown::Document.new((goal.description or ""), input: 'GFM', header_offset: 4).to_html
    end

    def abstract
      Kramdown::Document.new((goal.description[0..100] or "").strip, input: 'GFM', header_offset: 4).to_html
    end

    def owners_list
      goal.owners.map(&:name).join("<br>")
    end

    def stewards_list
      goal.stewards.map(&:name)
    end
  end
end

