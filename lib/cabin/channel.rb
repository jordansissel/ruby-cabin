require "cabin/mixins/logger"
require "cabin/mixins/pipe"
require "cabin/mixins/timestamp"
require "cabin/mixins/timer"
require "cabin/mixins/terminal"
require "cabin/namespace"
require "cabin/context"
require "cabin/outputs/stdlib-logger"
require "cabin/outputs/io"
require "cabin/formats/csv_format"
require "cabin/formats/json_format"
require "cabin/formats/null_format"
require "cabin/metrics"
require "logger" # stdlib
require "thread"

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
  @channel_lock = Mutex.new
  @channels = Hash.new { |h,k| h[k] = Cabin::Channel.new }

  class << self
    # Get a channel for a given identifier. If this identifier has never been
    # used, a new channel is created for it.
    # The default identifier is the application executable name.
    #
    # This is useful for using the same Cabin::Channel across your
    # entire application.
    def get(identifier=$0)
      return @channel_lock.synchronize { @channels[identifier] }
    end # def Cabin::Channel.get

    def set(identifier, channel)
      return @channel_lock.synchronize { @channels[identifier] = channel }
    end # def Cabin::Channel.set

    def each(&block)
      @channel_lock.synchronize do
        @channels.each do |identifier, channel|
          yield identifier, channel
        end
      end
    end # def Cabin::Channel.each

    # Get a list of filters included in this class.
    def filters
      @filters ||= []
    end # def Cabin::Channel.filters
    
    # Register a new filter. The block is passed the event. It is expected to
    # modify that event or otherwise do nothing.
    def filter(&block)
      @filters ||= []
      @filters << block
    end
  end # class << self

  include Cabin::Mixins::Timestamp
  include Cabin::Mixins::Logger
  include Cabin::Mixins::Pipe
  include Cabin::Mixins::Timer
  include Cabin::Mixins::Terminal

  # All channels come with a metrics provider.
  attr_accessor :metrics
  
  private

  # Create a new logging channel.
  # The default log level is 'info'
  def initialize
    @subscribers = {}
    @data = {}
    @level = :info
    @metrics = Cabin::Metrics.new
    @metrics.channel = self
    @subscriber_lock = Mutex.new
    @formatter_lock = Mutex.new
    @formatter      = Cabin::Formatter::Null.new
  end # def initialize

  # Subscribe a new input
  # New events will be sent to the subscriber using the '<<' method
  #   foo << event
  #
  # Returns a subscription id you can use later to unsubscribe
  def subscribe(output)
    # Wrap ruby stdlib Logger if given.
    if output.is_a?(::Logger)
      output = Cabin::Outputs::StdlibLogger.new(output)
    elsif output.is_a?(::IO)
      output = Cabin::Outputs::IO.new(output, @formatter)
    end
    @subscriber_lock.synchronize do
      @subscribers[output.object_id] = output
    end
    return output.object_id
  end # def subscribe

  # Add a new formatter for the output
  # New events will me using this format option
  def formatter(format)
    @formatter_lock.synchronize do
      @formatter = format
    end
    @subscriber_lock.synchronize do
      @subscribers.each do |id, output|
        output.formatter(@formatter) if output.respond_to?(:formatter)
      end
    end
  end

  # Unsubscribe. Takes a 'subscription id' as returned by the subscribe method
  def unsubscribe(id)
    @subscriber_lock.synchronize do
      @subscribers.delete(id)
    end
  end # def unsubscribe
 
  # Set some contextual map value
  def []=(key, value)
    @data[key] = value
  end # def []= 

  # Get a context value by name.
  def [](key)
    @data[key]
  end # def []

  # Remove a context value by name.
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
  def publish(data, &block)
    event = {}
    self.class.filters.each do |filter|
      filter.call(event)
    end

    if data.is_a?(String)
      event[:message] = data
    else
      event.merge!(data)
    end
    event.merge!(@data) # Merge any logger context

    @subscriber_lock.synchronize do
      @subscribers.each do |id, output|
        append =  block_given? ? block.call(output, event) : true
        output << event if append
      end
    end
  end # def publish

  def context
    ctx = Cabin::Context.new(self)
    return ctx
  end # def context

  def dataify(data)
    if data.is_a?(String)
      data = { :message => data }
    end
    return data
  end # def dataify

  public(:initialize, :context, :subscribe, :unsubscribe, :formatter, :[]=, :[], :remove, :publish, :time, :context)
end # class Cabin::Channel
