require "cabin/namespace"
require "cabin/inspectable"
require "thread"

class Cabin::Metrics::Histogram
  include Cabin::Inspectable

  # A new Histogram. 
  public
  def initialize
    @lock = Mutex.new
    @inspectables = [ :@total, :@min, :@max, :@count, :@mean ]

    # Histogram should track many things, including:
    # - percentiles (50, 75, 90, 95, 99?)
    # - median
    # - max
    # - min
    # - total sum
    #
    # Sliding values of all of these?
    @total = 0
    @min = 0
    @max = 0
    @count = 0
    @mean = 0.0
  end # def initialize

  public
  def record(value)
    @lock.synchronize do
      @count += 1
      @total += value
      @min = value if value < @min
      @max = value if value > @max
      @mean = @total / @count
      # TODO(sissel): median
      # TODO(sissel): percentiles
    end
  end # def record

  # This is a very poor way to access the metric data.
  # TODO(sissel): Need to figure out a better interface.
  public
  def value
    return @lock.synchronize { @count }
  end # def value

  public
  def to_hash
    return @lock.synchronize do
      { 
        :count => @count,
        :total => @total,
        :min => @min,
        :max => @max,
        :mean => @mean,
      }
    end
  end # def to_hash
end # class Cabin::Metrics::Histogram
