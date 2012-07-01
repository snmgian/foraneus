module Foraneus

  class ValueError
    attr_accessor :name
    attr_accessor :value
    attr_accessor :expected_type

    def initialize(name, value, expected_type)
      @name = name
      @value = value
      @expected_type = expected_type
    end
  end

  class ValueSetError < StandardError
    attr_accessor :value_set

    def initialize(value_set)
      @value_set = value_set
    end
  end

  # Raised on an attempt to parse an invalid value
  class ConverterError < StandardError
    attr_accessor :value, :converter_name

    # @param [String] value The value attempted to be parsed
    # @param [Symbol] converter_name Name of the converter
    def initialize(value, converter_name)
      @value = value
      @converter_name = converter_name
    end
  end

end
