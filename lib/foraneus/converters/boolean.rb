class Foraneus
  module Converters

    # Boolean converter.
    #
    # When parsing, the string 'true' is converted to true, otherwise false is returned.
    #
    # When converting to a raw value, a true value => 'true', a false value => 'false'.
    class Boolean

      # @return [Boolean]
      def parse(s)
        if s == 'true'
          true
        else
          false
        end
      end

      def raw(v)
        if v
          'true'
        else
          'false'
        end
      end
    end

  end
end
