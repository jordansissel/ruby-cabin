require "cabin/namespace"
require "thread"

class Cabin::Metrics::Meter
  # A new Meter 
  #
  # Counters can be incremented and decremented only by 1 at a time..
  public
  def initialize
    @value = 0
    @lock = Mutex.new
  end # def initialize

  # Mark an event
  def mark
    @lock.synchronize do
      @value += 1
      # TODO(sissel): Keep some moving averages?
    end
  end # def mark

  # Get the value of this metric.
  public
  def value
    return @lock.synchronize { @value }
  end # def value

  public
  def to_hash
    return @lock.synchronize do
      { :value => @value }
    end
  end # def to_hash
end # class Cabin::Metrics::Meter
