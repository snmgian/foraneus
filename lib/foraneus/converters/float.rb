class Foraneus
  module Converters

    class Float
      def parse(s)
        Kernel.Float(s)
      end

      def raw(v)
        v.to_s
      end
    end

  end
end
