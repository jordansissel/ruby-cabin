require "logging/namespace"

class Logging::Timer
  def initialize(&block)
    @start = Time.now
    @callback = block if block_given?
  end # def initialize

  def stop
    duration = Time.now - @start
    @callback.call(duration) if @callback
    return duration
  end # def stop
end # class Logging::Timer
