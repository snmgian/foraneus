module InvalidXForm; end

module RawXForm; end

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
    elsif key == :raw_values
      self.instance_variable_get(:@raw_values)
    elsif key == :as_hash
      self.instance_variable_get(:@hash_values)
    end
  end
end

module XForm

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def float(field)
      self.send :attr_reader, field

      @meta ||= {}
      @meta[field] = :float
    end

    def build(params = Hash.new)

      parsed_params = {}
      raw_params = {}
      errors = {}

      params.each do |name, value|
        next unless @meta.include?(name)

        raw_params[name] = value
        parsed_value, error = parse(name, value)
        unless error
          parsed_params[name] = parsed_value
        else
          errors[name] = FieldError.new(name, value, @meta[name])
        end
      end

      if errors.empty?
        form = self.new
        parsed_params.each do |name, value|
          form.instance_variable_set("@#{name}", value)
        end
        form.instance_variable_set(:@valid, true)
        form.instance_variable_set(:@errors, {})
        form.instance_variable_set(:@hash_values, parsed_params)
      else
        form_class = Class.new(self) do
          include InvalidXForm
          include RawXForm
        end
        form = form_class.new
        raw_params.each do |name, value|
          form.instance_variable_set("@#{name}", value)
        end
        form.instance_variable_set(:@valid, false)
        form.instance_variable_set(:@errors, errors)
      end

      form.instance_variable_set(:@raw_values, raw_params)
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

    def raw(form_or_params)
      if form_or_params.is_a?(XForm)
        self.raw_form(form_or_params)
      elsif form_or_params.is_a?(Hash)
        self.raw_params(form_or_params)
      end
    end

    def raw_form(form)
      raw_form_class = Class.new(form.class) do
        include RawXForm
      end

      raw_form = raw_form_class.new
      form[:raw_values].each do |name, value|
        raw_form.instance_variable_set("@#{name}", value)
      end
      raw_form
    end

    def raw_params(params)
      form = self.build(params)
      raw_form(form)
    end
  end
end
