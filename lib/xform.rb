module InvalidXForm; end

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

module ArrayXForm
  def [](key)
    if key == :valid?
      self.instance_variable_get(:@valid)
    elsif key == :errors
      self.instance_variable_get(:@errors)
    end
  end
end

module XForm

  def float(field)
    self.send :attr_reader, field

    @meta ||= {}
    @meta[field] = :float
  end

  def build(params = Hash.new)

    parsed_params = {}
    errors = {}

    params.each do |name, value|
      parsed_value, error = parse(name, value)
      unless error
        parsed_params[name] = parsed_value
      else
        errors[name] = FieldError.new(name, value, @meta[name])
      end
    end

    unless !errors.empty?
      form = self.new
      parsed_params.each do |name, value|
        form.instance_variable_set("@#{name}", value)
      end
      form.instance_variable_set(:@valid, true)
      form.instance_variable_set(:@errors, {})
    else
      form_class = Class.new(self) do
        include InvalidXForm
      end
      form = form_class.new
      params.each do |name, value|
        form.instance_variable_set("@#{name}", value)
      end
      form.instance_variable_set(:@valid, false)
      form.instance_variable_set(:@errors, errors)
    end

    form
  end

  def build!(*params)
    form = self.build(*params)
    if form.kind_of?(InvalidXForm)
      raise FormError.new(form)
    end

    form
  end

  def parse(name, value)
    @meta ||= {}

    parsed_value = nil
    error = false

    meta = @meta[name]
    if meta == :float
      begin
        parsed_value = Float(value)
      rescue
        error = true
      end
    end

    [parsed_value, error]
  end
end
