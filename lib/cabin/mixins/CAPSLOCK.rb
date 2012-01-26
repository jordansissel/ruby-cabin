require "cabin/namespace"

# ALL CAPS MEANS SERIOUS BUSINESS
module Cabin::Mixins::CAPSLOCK
  def log(level, message, data={})
    if message.is_a?(Hash)
      data.merge!(message)
    else
      data[:message] = message
    end

    # CAPITALIZE ALL THE STRINGS
    data.each do |key, value|
      value.upcase! if value.respond_to?(:upcase!)
    end

    # Add extra debugging bits (file, line, method) if level is debug.
    debugharder(caller.collect { |c| c.upcase }, data) if @level == :debug

    data[:level] = level.upcase

    publish(data)
  end # def log
end # module Cabin::Mixins::CAPSLOCK
