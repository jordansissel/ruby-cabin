require "cabin/namespace"

module Cabin::Logger
  attr_accessor :level
  LEVELS = {
    :fatal => 0,
    :error => 1,
    :warn => 2,
    :info => 3,
    :debug => 4
  }

  # Define the usual log methods: info, fatal, etc.
  # Each level-based method accepts both a message and a hash data.
  %w(fatal error warn info debug).each do |level|
    level = level.to_sym
    # def info, def warn, etc...
    define_method(level) do |message, data={}|
      next unless LEVELS[@level] >= LEVELS[level]
      if message.is_a?(Hash)
        data.merge!(message)
      else
        data[:message] = message
      end
      data[:level] = level
      publish(data)
    end
  end # end defining level-based log methods
end # module Cabin::Logger
