require 'date'

class Foraneus
  module Converters

    class Date

      DEFAULT_FORMAT = '%Y-%m-%d'

      attr_reader :opts

      # @param [Hash] opts
      # @option opts [String] format Date format.
      def initialize(opts = {})
        @opts = opts
        @format = opts[:format] || DEFAULT_FORMAT
      end


      # @raise [ArgumentError] with message 'invalid date'
      #
      # @return [Date]
      def parse(s)
        if ::Date === s
          s
        else
          ::Date.strptime(s, @format)
        end
      end

      def raw(v)
        v.strftime(@format)
      end
    end

  end
end
