require 'bigdecimal'

class Foraneus
  module Converters

    class Decimal
      DEFAULT_DELIMITER = ','
      DEFAULT_SEPARATOR = '.'

      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      def initialize(delimiter = DEFAULT_DELIMITER, separator = DEFAULT_SEPARATOR)
        @delimiter = delimiter
        @separator = separator
      end

      def parse(s)
        parts = s.split(@separator)

        integer_part = (parts[0] || '0').gsub(@delimiter, '')
        fractional_part = parts[1] || '0'

        BigDecimal.new("#{integer_part}.#{fractional_part}")
      end

      def raw(v)
        left, right = v.to_s('F').split('.')

        left.gsub!(DELIMITED_REGEX) { "#{$1}#{@delimiter}" }

        "#{left}#{@separator}#{right}"
      end
    end

  end
end