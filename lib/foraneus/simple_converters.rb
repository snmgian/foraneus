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

    class Float
      def parse(s)
        Kernel.Float(s)
      end

      def raw(v)
        v.to_s
      end
    end

    class Integer
      def parse(s)
        Kernel.Integer(s)
      end

      def raw(v)
        v.to_s
      end
    end

    class String
      def parse(s)
        s
      end

      def raw(v)
        v
      end
    end

  end
end

