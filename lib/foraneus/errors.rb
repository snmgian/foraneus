module Foraneus

  # An error during the parsing of a value.
  class ValueError

    # @!attribute name
    #   @return [String] Name of the field value
    attr_accessor :name

    # @!attribute value
    #   @return [String] Value attempted to be parsed
    attr_accessor :value

    # @!attribute expected_type
    #   @return [String] The expected type to be parsed
    attr_accessor :expected_type

    # @param [String] name The name of the field in the value_set
    # @param [String] value The value attempted to be parsed
    # @param [Symbol] expected_type The expected type to be parsed
    def initialize(name, value, expected_type)
      @name = name
      @value = value
      @expected_type = expected_type
    end
  end

  # Raised on an attempt to create a value_set from invalid value
  class ValueSetError < StandardError

    # @!attribute value_set
    #   @return [ValueSet] ValueSet with errors
    attr_accessor :value_set

    # @param [Foraneus::ValueSet] value_set ValueSet with errors
    def initialize(value_set)
      @value_set = value_set
    end
  end

  # Raised on an attempt to parse an invalid value
  class ConverterError < StandardError

    # @!attribute value
    #   @return [String] Value attempted to be parsed
    attr_accessor :value
    
    # @!attribute value
    #   @return [String] Name of the converter that raised the error
    attr_accessor :converter_name

    # @param [String] value The value attempted to be parsed
    # @param [Symbol] converter_name Name of the converter
    def initialize(value, converter_name)
      @value = value
      @converter_name = converter_name
    end
  end

end
