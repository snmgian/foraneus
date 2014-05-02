require 'date'

class Foraneus
  module Converters

    class Date

      DEFAULT_FORMAT = '%Y-%m-%d'

      def initialize(format = DEFAULT_FORMAT)
        @format = format
      end

      def parse(s)
        ::Date.strptime(s, @format)
      end

      def raw(v)
        v.strftime(@format)
      end
    end

  end
end
