class Foraneus
  module Converters

    class String
      def parse(s)
        s.to_s
      end

      def raw(v)
        v.to_s
      end
    end

  end
end
