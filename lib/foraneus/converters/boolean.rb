class Foraneus
  module Converters

    class Boolean
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
