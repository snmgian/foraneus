require 'bigdecimal'
require 'foraneus/converters/float'

class Foraneus
  module Converters

    class Decimal < Foraneus::Converters::Float

      # @return [BigDecimal]
      def parse(s)
        integer_part, fractional_part = split(s)

        BigDecimal.new("#{integer_part}.#{fractional_part}")
      end

      def raw(v)
        left, right = v.to_s('F').split('.')

        join(left, right)
      end

      private
      def add_trailing_zeros(s, n)
        zeros = '0' * n

        "#{s}#{zeros}"
      end
    end

  end
end
