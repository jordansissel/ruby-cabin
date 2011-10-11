require "logging"
require "json"

# Wrap Ruby stdlib's logger. This allows you to output to a normal ruby logger
# with Logging. Since Ruby's Logger has a love for strings alone, this 
# wrapper will convert the data/event to json before sending it to Logger.
class Logging::Outputs::StdlibLogger
  public
  def initialize(logger)
    @logger = logger
  end # def initialize

  # Receive an event
  public
  def <<(data)
    method = data[:level] || "info"
    # This will call @logger.info(data) or something similar.
    @logger.send(method, data.to_json)
  end # def <<
end # class Logging::Outputs::StdlibLogger
