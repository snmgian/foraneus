require 'delegate'

module Foraneus
  module Converters

    # Boolean converter. 
    class Boolean < AbstractConverter

      # @see {AbstractConverter#see}
      def name
        :boolean
      end

      # @see AbstractConverter#parse
      # @param [String] value The value to be parsed
      # @return [Boolean] Returns true only if value == 'true'
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

    # Float converter.
    class Float < AbstractConverter

      # @see {AbstractConverter#see}
      def name
        :float
      end

      # @see AbstractConverter#parse
      # @return [Float] Returns a float number
      def parse(value)
        Kernel.Float(value)
      end
    end

    # Integer converter.
    class Integer < AbstractConverter

      # @see {AbstractConverter#see}
      def name
        :integer
      end

      # @see AbstractConverter#parse
      # @return [Integer] Returns an integer number
      def parse(value)
        Kernel.Integer(value)
      end
    end

    # String converter.
    class String < AbstractConverter

      # @see {AbstractConverter#see}
      def name
        :string
      end

      # @see AbstractConverter#parse
      # @return [String] Returns a String reprensentation of the given value.
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

