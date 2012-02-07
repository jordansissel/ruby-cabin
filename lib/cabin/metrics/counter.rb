require "cabin/namespace"
require "thread"

class Cabin::Metrics::Counter
  # A new Counter. 
  #
  # Counters can be incremented and decremented only by 1 at a time..
  public
  def initialize
    @value = 0
    @lock = Mutex.new
  end # def initialize

  # increment this counter
  def incr
    @lock.synchronize { @value += 1 }
  end # def incr

  # decrement this counter
  def decr
    @lock.synchronize { @value -= 1 }
  end # def decr

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
end # class Cabin::Metrics::Counter
