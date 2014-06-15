require 'bigdecimal'

class Foraneus
  module Converters

    class Decimal
      DEFAULT_SEPARATOR = '.'

      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      # @param [Hash] opts
      # @option opts [String] delimiter Thousands delimiter.
      # @option opts [String] separator Decimal separator.
      # @option opts [Integer] precision Minimum precision.
      def initialize(opts = {})
        @delimiter = opts[:delimiter]
        @precision = opts[:precision]
        @separator = opts[:separator] || DEFAULT_SEPARATOR
      end

      # @return [BigDecimal]
      def parse(s)
        parts = s.split(@separator)

        integer_part = (parts[0] || '0')

        if @delimiter
          integer_part.gsub!(@delimiter, '')
        end

        fractional_part = parts[1] || '0'

        BigDecimal.new("#{integer_part}.#{fractional_part}")
      end

      def raw(v)
        left, right = v.to_s('F').split('.')

        if @precision && right.length < @precision
          right = add_trailing_zeros(right, @precision - right.length)
        end

        if @delimiter
          left.gsub!(DELIMITED_REGEX) { "#{$1}#{@delimiter}" }
        end

        "#{left}#{@separator}#{right}"
      end

      private
      def add_trailing_zeros(s, n)
        zeros = '0' * n

        "#{s}#{zeros}"
      end
    end

  end
end
