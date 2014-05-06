class Foraneus
  module Converters

    class Noop
      def parse(o)
        o
      end

      def raw(o)
        o
      end
    end

  end
end
