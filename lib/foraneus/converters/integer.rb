class Foraneus
  module Converters

    class Integer
      def parse(s)
        Kernel.Integer(s)
      end

      def raw(v)
        v.to_s
      end
    end

  end
end
