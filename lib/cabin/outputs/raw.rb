require 'cabin'
require 'thread'

# Wrap IO objects and log only the raw message
#
# This is added for particularly difficult use cases, such as
# wanting to fork and exec a child procss, implicitly log the
# data, and simultaneously capture it in a pipe for further
# manipulation/analyzation

class Cabin::Outputs::Raw
  def initialize(io)
    @io   = io
    @lock = Mutex.new
  end # def initialize(io)

  def <<(event)
    @lock.synchronize do
      @io.puts event[:message]
    end
  end # def <<(event)
end # class Cabin::Outputs::Raw

