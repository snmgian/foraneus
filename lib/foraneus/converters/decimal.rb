require 'bigdecimal'

class Foraneus
  module Converters

    class Decimal
      DEFAULT_DELIMITER = ','
      DEFAULT_SEPARATOR = '.'

      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      def initialize(opts = {})
        @delimiter = opts[:delimiter] || DEFAULT_DELIMITER
        @separator = opts[:separator] || DEFAULT_SEPARATOR
        @precision = opts[:precision]
      end

      def parse(s)
        parts = s.split(@separator)

        integer_part = (parts[0] || '0').gsub(@delimiter, '')
        fractional_part = parts[1] || '0'

        BigDecimal.new("#{integer_part}.#{fractional_part}")
      end

      def raw(v)
        left, right = v.to_s('F').split('.')

        if @precision && right.length < @precision
          right = add_trailing_zeros(right, @precision - right.length)
        end

        left.gsub!(DELIMITED_REGEX) { "#{$1}#{@delimiter}" }

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
