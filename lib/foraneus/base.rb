module Foraneus

  class Base

    @meta = {}

    def self.float(field)
      self.send :attr_reader, field

      @meta ||= {}
      @meta[field] = :float
    end

    def self.build(params = {})

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
          errors[name] = Foraneus::FieldError.new(name, value, @meta[name])
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
          include Foraneus::InvalidXForm
          include Foraneus::RawXForm
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

    def self.build!(*params)
      form = self.build(*params)
      if form.kind_of?(Foraneus::InvalidXForm)
        raise Foraneus::FormError.new(form)
      end

      form
    end

    def self.parse(name, value)
      parsed_value = nil
      error = false

      parser_code = @meta[name]
      parser = Foraneus.registry[parser_code]

      begin
        parsed_value = parser.parse(value)
      rescue StandardError => e
        error = true
      end

      [parsed_value, error]
    end

    def self.raw(form_or_params)
      if form_or_params.is_a?(Foraneus::Base)
        self.raw_form(form_or_params)
      elsif form_or_params.is_a?(Hash)
        self.raw_params(form_or_params)
      end
    end

    def self.raw_form(form)
      raw_form_class = Class.new(form.class) do
        include Foraneus::RawXForm
      end

      raw_form = raw_form_class.new
      form[:raw_values].each do |name, value|
        raw_form.instance_variable_set("@#{name}", value)
      end
      raw_form
    end

    def self.raw_params(params)
      form = self.build(params)
      raw_form(form)
    end
  end

end
