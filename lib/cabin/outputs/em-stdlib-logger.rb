require "cabin"
require "json"
require "eventmachine"

# Wrap Ruby stdlib's logger. This allows you to output to a normal ruby logger
# with Cabin. Since Ruby's Logger has a love for strings alone, this
# wrapper will convert the data/event to json before sending it to Logger.
class Cabin::Outputs::EmStdlibLogger
  public
  def initialize(logger)
    @logger_queue = EM::Queue.new
    @logger = logger
    consumer # consume messages from a queue and send them to logger
  end # def initialize

  def consumer
    line_sender = Proc.new do |line|
      # This will call @logger.info(data) or something similar.
      @logger.send(line[:method], line[:message])
      EM.next_tick do
        @logger_queue.pop(&line_sender)
      end
    end
    @logger_queue.pop(&line_sender)
  end

  # Receive an event
  public
  def <<(data)
    line = Hash.new
    line[:method] = data[:level] || "info"
    line[:message] = "#{data[:message]} #{data.to_json}"
    @logger_queue.push(line)
  end # def <<
end # class Cabin::Outputs::EmStdlibLogger
