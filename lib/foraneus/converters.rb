require 'delegate'

module Foraneus

  module Converters

    class ConverterDecorator < SimpleDelegator
      def initialize(converter)
        super(converter)
        @source = converter
      end

      def parse(value)
        return nil if value.nil?

        begin
          @source.parse(value)
        rescue
          raise Foraneus::ConverterError.new(value, @source.name)
        end
      end
    end

    class AbstractConverter

      def code_name
        raise NotImplementedError
      end

      def parse
        raise NotImplementedError
      end
    end
  end
end
