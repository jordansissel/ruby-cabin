require "cabin/namespace"

# This module implements methods that act somewhat like Ruby's Logger class
# It is included in Cabin::Channel
module Cabin::Mixins::Logger
  attr_accessor :level
  LEVELS = {
    :fatal => 0,
    :error => 1,
    :warn => 2,
    :info => 3,
    :debug => 4
  }

  def level=(value)
    @level = value.to_sym
  end # def level

  # Define the usual log methods: info, fatal, etc.
  # Each level-based method accepts both a message and a hash data.
  #
  # This will define methods such as 'fatal' and 'fatal?' for each
  # of: fatal, error, warn, info, debug
  #
  # The first method type (ie Cabin::Channel#fatal) is what logs, and it takes a
  # message and an optional Hash with context.
  #
  # The second method type (ie; Cabin::Channel#fatal?) returns true if
  # fatal logs are being emitted, false otherwise.
  %w(fatal error warn info debug).each do |level|
    level = level.to_sym
    predicate = "#{level}?".to_sym

    # def info, def warn, etc...

    define_method(level) do |message, data={}|
      log(level, message, data) if send(predicate)
    end

    # def info?, def warn? ...
    # these methods return true if the loglevel allows that level of log.
    define_method(predicate) do 
      @level ||= :info
      return LEVELS[@level] >= LEVELS[level]
    end # def info?, def warn? ...
  end # end defining level-based log methods

  private
  def log(level, message, data={})
    # Invoke 'info?' etc to ask if we should act.
    if message.is_a?(Hash)
      data.merge!(message)
    else
      data[:message] = message
    end

    # Add extra debugging bits (file, line, method) if level is debug.
    debugharder(caller, data) if @level == :debug

    data[:level] = level
    publish(data)
  end # def log

  # This method is used to pull useful information about the caller
  # of the logging method such as the caller's file, method, and line number.
  private
  def debugharder(callstack, data)
    path, line, method = callstack[1].split(/(?::in `|:|')/)
    whence = $:.detect { |p| path.start_with?(p) }
    if whence
      # Remove the RUBYLIB path portion of the full file name 
      file = path[whence.length + 1..-1]
    else
      # We get here if the path is not in $:
      file = path
    end
    
    data[:file] = file
    data[:line] = line
    data[:method] = method
  end # def debugharder
end # module Cabin::Mixins::Logger
