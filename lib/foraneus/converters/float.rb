class Foraneus
  module Converters

    class Float

      DEFAULT_SEPARATOR = '.'

      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      attr_reader :opts

      # @param [Hash] opts
      # @option opts [String] delimiter Thousands delimiter.
      # @option opts [String] separator Decimal separator.
      # @option opts [Integer] precision Minimum precision.
      def initialize(opts = {})
        @opts = opts

        @delimiter = opts[:delimiter]
        @precision = opts[:precision]
        @separator = opts[:separator] || DEFAULT_SEPARATOR
      end

      # @return [Float]
      def parse(s)
        integer_part, fractional_part = split(s)

        Kernel.Float("#{integer_part}.#{fractional_part}")
      end

      def raw(v)
        left, right = v.to_s.split('.')

        join(left, right)
      end

      protected
      # Joins both integer and fractional parts.
      #
      # It adds trailing zeros according to the current precision.
      #
      # @param [Integer] left Integer part
      # @param [Integer] right Fractional part
      #
      # @return [String]
      def join(left, right)
        if @precision && right.length < @precision
          right = add_trailing_zeros(right, @precision - right.length)
        end

        if @delimiter
          left.gsub!(DELIMITED_REGEX) { "#{$1}#{@delimiter}" }
        end

        "#{left}#{@separator}#{right}"
      end

      # Splits a float representation into its integer and fractional parts.
      #
      # @param [String] s
      #
      # @return [Array [integer_part, fractional_part] ]
      def split(s)
        parts = s.split(@separator)

        integer_part = parts[0] || '0'

        if @delimiter
          integer_part.gsub!(@delimiter, '')
        end

        fractional_part = parts[1] || '0'

        [integer_part, fractional_part]
      end

      private
      def add_trailing_zeros(s, n)
        zeros = '0' * n

        "#{s}#{zeros}"
      end
    end

  end
end
