require "logging"

# Wrap Ruby stdlib's logger. This allows you to output to a normal ruby logger
# with Logging.
class Logging::Outputs::StdlibLogger
  public
  def initialize(logger)
    @logger = logger
  end # def initialize

  public
  def subscribe(logging)
    logging.subscribe(self)
  end # def subscribe

  public
  def <<(data)
    method = data[:level] || "info"
    # This will call @logger.info(data) or something similar.
    @logger.send(method, data)
  end # def <<
end # class Logging::Outputs::StdlibLogger
