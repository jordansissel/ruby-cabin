require "cabin"
require "json"

# Wrap IO objects with a reasonable log output. 
#
# If the IO instance is attached to a TTY, the output will try to be a bit more
# human-friendly in this format:
#
#     message {json data}
#
# If the IO instance is not attached to a TTY, the output will be the JSON
# representation of the event:
#
#     { "timestamp": ..., "message": message, ... }
class Cabin::Outputs::IO
  public
  def initialize(io)
    @io = io
  end # def initialize

  # Receive an event
  public
  def <<(event)
    if @io.tty?
      data = event.clone
      # delete things from the 'data' portion that's not really data.
      data.delete(:message)
      data.delete(:timestamp)
      message = "#{event[:message]} #{data.to_json}"

      @io.puts(message)
      @io.flush if @io.tty?
    else
      @io.puts(event.to_json)
    end
  end # def <<
end # class Cabin::Outputs::StdlibLogger
