require "cabin/mixins/logger"
require "cabin/namespace"
require "cabin/timer"
require "cabin/context"
require "cabin/outputs/stdlib-logger"
require "logger"

# A wonderful channel for logging.
#
# You can log normal messages through here, but you should be really
# shipping structured data. A message is just part of your data.
# "An error occurred" - in what? when? why? how?
#
# Logging channels support the usual 'info' 'warn' and other logger methods
# provided by Ruby's stdlib Logger class
#
# It additionally allows you to store arbitrary pieces of data in it like a
# hash, so your call stack can do be this:
#
#     @logger = Cabin::Channel.new
#     rubylog = Logger.new(STDOUT) # ruby's stlib logger
#     @logger.subscribe(rubylog)
#
#     def foo(val)
#       context = @logger.context()
#       context[:foo] = val
#       context[:example] = 100
#       bar()
#
#       # Clear any context we just wanted bar() to know about
#       context.clear()
#
#       @logger.info("Done in foo")
#     end
#
#     def bar
#       @logger.info("Fizzle")
#     end
#
# The result:
#
#     I, [2011-10-11T01:00:57.993200 #1209]  INFO -- : {:timestamp=>"2011-10-11T01:00:57.992353-0700", :foo=>"Hello", :example=>100, :message=>"Fizzle", :level=>:info}
#     I, [2011-10-11T01:00:57.993575 #1209]  INFO -- : {:timestamp=>"2011-10-11T01:00:57.993517-0700", :message=>"Done in foo", :level=>:info}
#
class Cabin::Channel
  include Cabin::Mixins::Logger

  # Create a new logging channel.
  # The default log level is 'info'
  public
  def initialize
    @outputs = []
    @data = {}
    @level = :info
  end # def initialize

  # Subscribe a new input
  public
  def subscribe(output)
    # Wrap ruby stdlib Logger if given.
    if output.is_a?(::Logger)
      output = Cabin::Outputs::StdlibLogger.new(output)
    end
    @outputs << output
    # TODO(sissel): Return a method or object that allows you to easily
    # unsubscribe?
  end # def subscribe
 
  # Set some contextual map value
  public
  def []=(key, value)
    @data[key] = value
  end # def []= 

  # Get a context value by name.
  public
  def [](key)
    @data[key]
  end # def []

  # Remove a context value by name.
  public
  def remove(key)
    @data.delete(key)
  end # def remove

  # Publish data to all outputs. The data is expected to be a hash or a string. 
  #
  # A new hash is generated based on the data given. If data is a string, then
  # it will be added to the new event hash with key :message.
  #
  # A special key :timestamp is set at the time of this method call. The value
  # is a string ISO8601 timestamp with microsecond precision.
  public
  def publish(data)
    event = {
      :timestamp => Time.now.strftime("%Y-%m-%dT%H:%M:%S.%6N%z")
    }
    event.merge!(@data)
    # TODO(sissel): need to refactor string->hash shoving.
    if data.is_a?(String)
      event[:message] = data
    else
      event.merge!(data)
    end

    @outputs.each do |out|
      out << event
    end
  end # def publish

  # Start timing something.
  # Returns an instance of Cabin::Timer bound to this Cabin::Channel.
  # To stop the timer and immediately emit the result to this channel, invoke
  # the Cabin::Timer#stop method.
  public
  def time(data, &block)
    # TODO(sissel): need to refactor string->hash shoving.
    if data.is_a?(String)
      data = { :message => data }
    end

    data[:level] = @level

    timer = Cabin::Timer.new do |duration|
      # TODO(sissel): Document this field
      data[:duration] = duration
      publish(data)
    end

    if block_given?
      block.call
      return timer.stop
    else
      return timer
    end
  end # def time

  public
  def context
    ctx = Cabin::Context.new(self)
    return ctx
  end # def context
end # class Cabin::Channel
