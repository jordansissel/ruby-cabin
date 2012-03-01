require "cabin/namespace"

# Colorful logging.
module Cabin::Mixins::Colors
  COLORS = [ :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white ]

  MAP = {
    # ANSI terminal codes
    :normal => 0,
    :bold => 1,
    :black => 30,
    :red => 31,
    :green => 32,
    :yellow => 33,
    :blue => 34,
    :magenta => 35,
    :cyan => 36,
    :white => 37
  }

  COLORS.each do |color|
    # define the color first
    define_method(color) do |message, data={}|
      log([MAP[color]], message, data)
    end

    # then define the bold version
    define_method("#{color}!".to_sym) do
      log([MAP[:bold]], MAP[color]], message, data)
    end
  end

  private
  def log(color_attrs, message, data={})
    if message.is_a?(Hash)
      data.merge!(message)
    else
      data[:message] = message
    end
    publish(data)
  end # def log
end # module Cabin::Dragons
