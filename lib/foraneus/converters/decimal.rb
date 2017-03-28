require 'bigdecimal'
require 'foraneus/converters/float'

class Foraneus
  module Converters

    class Decimal < Foraneus::Converters::Float

      def initialize(opts = {})
        super

        @rounding = opts[:rounding]
        @rounding_mode = opts[:rounding_mode] || BigDecimal::ROUND_HALF_EVEN
      end

      # @return [BigDecimal]
      def parse(s)
        integer_part, fractional_part = split(s.to_s)

        v = BigDecimal.new("#{integer_part}.#{fractional_part}")

        apply_rounding(v)
      end

      def raw(v)
        v = apply_rounding(v)

        left, right = v.to_s('F').split('.')

        join(left, right)
      end

      private

      # @param [BigDecimal] v
      def apply_rounding(v)
        if @rounding
          v.round(@rounding, @rounding_mode)
        else
          v
        end
      end
    end

  end
end
