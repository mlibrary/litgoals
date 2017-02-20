require 'date'

module GoalsViz
  class FiscalYear

    attr_accessor :year

    def initialize(year = current_fiscal_year)
      @year = year.to_i
    end

    def to_s
      "#{year}"
    end

    def range_string
      "FY July #{year} -- June #{year + 1}"
    end

    def range_string_html
      range_string.gsub(/--/, '—')
    end

    def goals_url
      "/litgoals/goals/#{year}"
    end

    def next(i = 1)
      self.class.new(year + i)
    end

    def select_list(n = 2)
      (0..(n-1)).map{|i| y =self.next(i); [y.range_string, y.year]}
    end

    def current_fiscal_year
      d = DateTime.now
      if d.month <= 6
        d.year - 1
      else
        d.year
      end
    end

  end
end
