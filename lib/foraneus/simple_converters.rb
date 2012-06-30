require 'delegate'

module Foraneus

  module Converters

    class Boolean < AbstractConverter
      def code_name
        :boolean
      end

      def parse(value)
        if value == true
          true
        elsif value == 'true'
          true
        else
          false
        end
      end
    end

    class Float < AbstractConverter

      def code_name
        :float
      end

      def parse(value)
        Kernel.Float(value)
      end
    end

    class String < AbstractConverter

      def code_name
        :string
      end

      def parse(value)
        if value.is_a?(::String)
          value
        else
          value.to_s
        end
      end
    end

  end
end

