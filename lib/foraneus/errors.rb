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

  class ConverterError < StandardError
    attr_accessor :value, :converter_name

    def initialize(value, converter_name)
      @value = value
      @converter_name = converter_name
    end
  end

end
