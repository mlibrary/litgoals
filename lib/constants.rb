require 'dry-validation'

module GoalsViz
  PLATFORM_SELECT = ['Create', 'Scale', 'Build', 'N/A']
  DATEFORMAT = /\d{4}\/\d{2}/


  GoalSchema = Dry::Validation.Form do
    required(:title).filled
    required(:description).filled
    required(:target_date).filled(format?: DATEFORMAT)
  end

end
