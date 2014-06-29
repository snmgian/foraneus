class Foraneus
  module Converters

    class String

      attr_reader :opts

      def initialize(opts = {})
        @opts = opts
      end

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
