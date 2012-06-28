module Foraneus

  class FieldError
    attr_accessor :field_name
    attr_accessor :field_value
    attr_accessor :expected_type

    def initialize(field_name, field_value, expected_type)
      @field_name = field_name
      @field_value = field_value
      @expected_type = expected_type
    end
  end

  class FormError < StandardError
    attr_accessor :invalid_form

    def initialize(invalid_form)
      @invalid_form = invalid_form
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
