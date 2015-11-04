require "cabin/formats/base"
require "json"

module Cabin
  module Formatter
    class JSON < Base

      def convert(obj)
        obj.to_json
      end

    end
  end
end
