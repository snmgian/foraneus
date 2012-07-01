module Foraneus
  module ValueSetBuilder

    def self.build(vs_class, meta, params = {})

      parsed_params, raw_params, errors = parse_params(meta, params)

      if errors.empty?
        form = vs_class.new
        set_instance_vars(form, parsed_params)
        form.instance_variable_set(:@hash_values, parsed_params)
      else
        form = create_invalid_value_set(vs_class)
        set_instance_vars(form, raw_params)
      end

      form.instance_variable_set(:@valid, errors.empty?)
      form.instance_variable_set(:@errors, errors)
      form.instance_variable_set(:@raw_values, raw_params)
      form
    end

    def self.create_invalid_value_set(vs_class)
      form_class = Class.new(vs_class) do
        include Foraneus::InvalidValueSet
        include Foraneus::RawValueSet
      end
      form = form_class.new
    end

    def self.parse(meta, name, value)
      parsed_value = nil
      error = false

      parser_code = meta[name]
      parser = Foraneus.registry[parser_code]

      begin
        parsed_value = parser.parse(value)
      rescue StandardError => e
        error = true
      end

      [parsed_value, error]
    end

    def self.parse_params(meta, params)
      parsed_params = {}
      raw_params = {}
      errors = {}

      params.each do |name, value|
        next unless meta.include?(name)

        raw_params[name] = value
        parsed_value, error = parse(meta, name, value)
        unless error
          parsed_params[name] = parsed_value
        else
          errors[name] = Foraneus::ValueError.new(name, value, meta[name])
        end
      end

      [parsed_params, raw_params, errors]
    end

    def self.set_instance_vars(form, params)
      params.each do |name, value|
        form.instance_variable_set("@#{name}", value)
      end
    end
  end
end
