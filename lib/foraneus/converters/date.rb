require 'date'

class Foraneus
  module Converters

    class Date

      DEFAULT_FORMAT = '%Y-%m-%d'

      # @param [Hash] opts
      # @option opts [String] format Date format.
      def initialize(opts = {})
        @format = opts[:format] || DEFAULT_FORMAT
      end

      # return [Date]
      def parse(s)
        ::Date.strptime(s, @format)
      end

      def raw(v)
        v.strftime(@format)
      end
    end

  end
end
