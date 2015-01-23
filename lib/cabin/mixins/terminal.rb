require "cabin/namespace"

module Cabin::Mixins::Terminal

  def terminal(message)
    publish(message) do |output, event|
      output.respond_to?(:tty?) && output.tty?
    end
  end

end
