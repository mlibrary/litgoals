
class Filter
  KEYS = [:whose, :year, :unit, :status, :person]

  def initialize(params)
    @f = {}
    KEYS.each {|k| @f[k] = {}}
  end

  def method_missing(m, *args)
    @f[m][args.first] ? "checked" : ""
  end
end
