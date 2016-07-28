Encoding.default_external = 'utf-8'


require 'roda'
require_relative 'models'




class LITGoals < Roda

  plugin :render, cache: false, engine: 'slim'
  plugin :assets

  route do |r|
    r.root do

      r.is do
        view "layout"
      end

      # Basic form entry page needs
      # all the goals for the units plus
      # goals for this individual






    end
  end

end

