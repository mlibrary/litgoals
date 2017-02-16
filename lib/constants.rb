require 'dry-validation'

module GoalsViz
  DATEFORMAT = /\d{4}\/\d{2}/


  STATUS = [
      'Not started',
      'On hold',
      'In progress',
      'Completed',
      'Abandoned'
  ]

  GoalSchema = Dry::Validation.Form do
    required(:title).filled
    required(:description).filled
    required(:target_date).filled(format?: DATEFORMAT)
  end

end
