require "cabin/namespace"
require "thread"

class Cabin::Metrics::Timer
  # A new Timer metric 
  #
  # Timers behave like a combination of Meter and Histogram. Every Timer
  # invocation is metered and the duration of the timer is put into the
  # Histogram.
  public
  def initialize
    @invocations = 0
    @lock = Mutex.new
  end # def initialize

  # Start timing something.
  #
  # If no block is given
  # If a block is given, the execution of that block is timed.
  #
  public
  def time(&block)
    return time_block(&block) if block_given?

    # Return an object we can .stop
    return TimerContext.new(method(:record))
  end # def time

  private
  def time_block(&block)
    start = Time.now
    block.call
    record(Time.now - start)
  end # def time_block

  public
  def record(duration)
    @lock.synchronize do
      @invocations += 1
      # TODO(sissel): histogram the duration
    end
  end # def record

  # Get the number of times this timer has been used
  public
  def count
    return @lock.synchronize { @invocations }
  end # def value

  class TimerContext
    public
    def initialize(&stop_callback)
      @start = Time.now
      @callback = stop_callback
    end

    public
    def stop
      duration = Time.now - @start
      @callback.call(duration)
    end # def stop
  end # class TimerContext
end # class Cabin::Metrics::Counter
