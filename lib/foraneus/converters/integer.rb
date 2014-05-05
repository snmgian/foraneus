class Foraneus
  module Converters

    class Integer
      DELIMITED_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

      def initialize(opts = {})
        @delimiter = opts[:delimiter]
      end

      def parse(s)
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
