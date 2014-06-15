class Foraneus
  module Converters

    # Noop converter.
    #
    # It does not perform any conversion at all. Useful when its needed to have a field but
    # conversion is handled at another level.
    class Noop
      # @return [Object]
      def parse(o)
        o
      end

      def raw(o)
        o
      end
    end

  end
end
