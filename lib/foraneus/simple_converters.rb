require 'delegate'

module Foraneus

  module Converters

    class Float < AbstractConverter

      def code_name
        :float
      end

      def parse(value)
        Kernel.Float(value)
      end
    end

  end
end

