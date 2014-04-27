require 'delegate'

module Foraneus

  # A converter is intended for parsing a string and returning a value.
  module Converters

    # A decorator for concrete converters.
    #
    # It prevents nil values and manages errors raised by {AbstractConverter#parse}
    class ConverterDecorator < SimpleDelegator

      # @param [AbstractConverter] converter The converter to be decorated
      def initialize(converter)
        super(converter)
        @source = converter
      end

      # Invokes {AbstractConverter#parse}. Manages errors raised by the converter.
      # Also, it returns nil if value.nil?
      #
      # @param [String] value Value to be parsed
      #
      # @return [Object] Parsed value
      #
      # @raise [Foraneus::ConverterError] if the concrete converter raises an error
      def parse(value)
        return nil if value.nil?

        begin
          @source.parse(value)
        rescue
          raise Foraneus::ConverterError.new(value, @source.name)
        end
      end
    end

    # @abstract Converters should inherit from this class and override #{code_name} and #{parse}
    class AbstractConverter

      # Returns the name of this converter.
      #
      # @return [String]
      def name
        raise NotImplementedError
      end

      # Parses a value and returns the obtained parsed value.
      #
      # @param [String] value Value to be parsed
      #
      # @return [Object]
      def parse(value)
        raise NotImplementedError
      end
    end
  end
end
