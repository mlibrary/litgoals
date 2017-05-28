
class Filter
  KEYS = %w[whose year unit status person]

  def initialize(params)
    @f = {}
    KEYS.each {|k| @f[k] = Array(params[k])}
  end

  def method_missing(m, *args)
    k = m.to_s
    val = args.first.to_s
    @f[k].include?(val) ? 'checked="checked"' : ""
  end
end
