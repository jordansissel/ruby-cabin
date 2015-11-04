require "cabin/formats/base"
require "csv"

module Cabin
  module Formatter
    class CSV < Base

      def convert(obj)
        obj.values.to_csv
      end

    end
  end
end
