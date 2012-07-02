module Foraneus
  module ValueSetBuilder

    # Builds an instance of a value_set
    #
    # @param [Class<? extends ValueSet>] vs_class ValueSet subclass from with the value_set will be instantiated
    #
    # @param [Hash<Symbol, Symbol>] meta Hash with metainformation. Each key is a field name, and each value is the name of the converter to be used
    #
    # @param [Hash<Symbol, Object>] params Parameters that will be parsed and set as attributes for the newly value_set
    #
    # @return [ValueSet] An instance of (or an instance of subclass of) vs_class
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

    # Creates a value_set marked as invalid.
    #
    # It creates a value set by creating an instance from a subclass of vs_class.
    # That subclass is mixed in with {InvalidValueSet} and {RawValueSet}
    #
    # @api private
    #
    # @param [Class<? extends ValueSet>] Subclass of ValueSet from which the invalid value_set
    #   will be instantiated
    #
    # @return [ValueSet] A kind of ValueSet, mixed with {InvalidValueSet} and {RawValueSet}
    def self.create_invalid_value_set(vs_class)
      form_class = Class.new(vs_class) do
        include Foraneus::InvalidValueSet
        include Foraneus::RawValueSet
      end
      form = form_class.new
    end

    # Parses a given value.
    #
    # The converter is selected by querying the given metadata, searching for the given name.
    # @api private
    #
    # @param [Hash<Symbol, Symbol>] meta (see .build)
    # @param [Symbol] Name of the field to be parsed
    # @param [String] Value to be parsed
    #
    # @return [Array] An array of two elements. The first of them is the result of the parsing, 
    #   and the last one is a boolean value that indicates if an error occured during the parsing.
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

    # Parses each of the given params. 
    #
    # The converter is select by searching for the param name in the metadata.
    # If a param is not expected by the metadata, then it is simply ignored.
    #
    # @api private
    #
    # @param [Hash<Symbol, Symbol>] meta (see .build)
    # @param [Hash<Symbol, Object>] params (see .build)
    #
    # @return [Array] An array consisting of three elements:
    #   - Hash { Symbol => Object } Parsed params/values
    #   - Hash { Symbol => Object } Given params/values, it only contains params that are present in the metadata.
    #   - Hash { Symbol => {ValueError} } Errors ocurred during parsing, each key is the name of a field with an associated error
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

    # Sets instance variables to an object.
    #
    # @api private
    #
    # @param [Object] o The object to set the instance variables
    # @param [Hash<Symbol, Object] A hash with the names and values of instance variables that will be set.
    #
    # @return [Object] The received object with the instance variables set
    def self.set_instance_vars(o, params)
      params.each do |name, value|
        o.instance_variable_set("@#{name}", value)
      end

      o
    end

  end
end
