require "cabin/formats/base"
require "json"

module Cabin
  module Formatter
    class Null < Base

      def convert(obj)
        obj
      end

    end
  end
end
