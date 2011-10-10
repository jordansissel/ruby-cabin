require "logging/logger"
require "logging/namespace"
require "logging/timer"

# TODO(sissel): 
class Logging::Channel
  include Logging::Logger

  public
  def initialize
    @outputs = []
    @data = {}
    @level = :info
  end # def initialize

  public
  def subscribe(output)
    @outputs << output
  end # def subscribe
 
  # Set some context
  public
  def []=(key, value)
    @data[key] = value
  end # def []= 

  # Publish data to all outputs
  public
  def publish(data)
    context = {}
    context.merge!(@data)
    if data.is_a?(String)
      context[:message] = data
    else
      context.merge!(data)
    end

    # TODO(sissel): Document this field
    context[:timestamp] = Time.now.strftime("%Y-%m-%dT%H:%M:%S.%6N%z")
    @outputs.each do |out|
      out << context
    end
  end # def publish

  # Start timing something
  public
  def time(data)
    if data.is_a?(String)
      data = { :message => data }
    end

    timer = Logging::Timer.new do |duration|
      # TODO(sissel): Document this field
      data[:duration] = duration
      publish(data)
    end
  end # def time
end # class Logging
