class Foraneus
  module Converters

    class String

      # @return [String]
      def parse(s)
        s.to_s
      end

      def raw(v)
        v.to_s
      end
    end

  end
end
