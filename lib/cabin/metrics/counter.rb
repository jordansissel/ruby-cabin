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
    @lock.synchronize do
      @value += 1
    end
  end # def incr

  # decrement this counter
  def decr
    @lock.synchronize do
      @value -= 1
    end
  end # def decr

  # Get the value of this metric.
  public
  def get
    @lock.synchronize do
      value = @value
    end
    return value
  end # def get
end # class Cabin::Metrics::Counter
