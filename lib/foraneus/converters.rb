module Foraneus

  class TypeException < StandardError
    attr_accessor :value, :type_name

    def initialize(value, type_name)
      @value = value
      @type_name = type_name
    end
  end

  module Converters

    class ConverterDecorator
      def self.decorate(converter)
        def converter.parse(value)

        end
      end
    end

    c = ConverterDelegator.new(FloatC.new)
    require 'delegate'
    class ConverterDelegator < SimpleDelegator
      def initialize(converter)
        super(converter)
        @source = converter
      end

      def parse(value)
        return nil if value.nil?

        begin
          @source.parse(value)
        #rescue
          #raise Foraneus::TypeException.new(value, self.code_name)
        end
      end
    end

    class AbstractConverter

      def code_name
        raise 'Not implemented'
      end

      def parse
        raise 'Not implemented'
      end

      def register
      end
    end

    class FloatC < AbstractConverter

      def code_name
        :float
      end

      def parse(value)
        Float(value)
      end
    end
  end
end
