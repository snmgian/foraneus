class Foraneus
  module Converters

    class Integer
      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      attr_reader :opts

      # @param [Hash] opts
      # @option opts [String] delimiter Thousands delimiter.
      def initialize(opts = {})
        @opts = opts
        @delimiter = opts[:delimiter]
      end

      # @raise [TypeError] with message 'invalid value for Integer(): ...'
      #
      # @return [Integer]
      def parse(s)
        raise TypeError, "can't convert nil into Integer" if s.nil?

        s = s.gsub(@delimiter, '') if @delimiter

        Kernel.Integer(s)
      end

      def raw(v)
        s = v.to_s

        if @delimiter
          s.gsub!(DELIMITED_REGEX) { "#{$1}#{@delimiter}" }
        end

        s
      end
    end

  end
end
