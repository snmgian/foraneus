class Foraneus
  module Utils

    # Return the value of a key in the given hash and flag indicating whether the keys exists or not
    #
    # If the given key is not present then tries fetching key#to_sym
    #
    # @param [Hash] data
    # @param [String] field
    #
    # @return [Object, Boolean]
    def self.fetch(hash, key)
      v = nil
      is_present = true

      v = hash.fetch(key) do
        hash.fetch(key.to_sym) do
          is_present = false
          nil
        end
      end

      [v, is_present]
    end

    # Parses a raw value.
    #
    # @param [String, Symbol] field
    # @param [String] s Raw value.
    # @param converter
    #
    # @raise [KeyError] if converter requires a value but no one is given.
    #
    # @return [Object, nil] when parsing succeeds
    # @return [nil, Foraneus::Error] when parsing fails
    def self.parse_datum(field, s, converter)
      if s == '' && converter.opts.fetch(:blanks_as_nil, true)
        s = nil
      end

      if s.nil? && converter.opts[:required]
        raise KeyError, "required parameter not found: #{field.inspect}"
      end

      result = if s.nil?
        converter.opts[:default]

      else
        converter.parse(s)
      end

      [result, nil]

    rescue
      error = Foraneus::Error.new($!.class.name, $!.message)

      [nil, error]
    end

    # Obtains a raw representation of a value and assigns it to the corresponding field.
    #
    # @param [Object] v
    # @param [Converter] converter
    #
    # @return [String]
    def self.raw_datum(v, converter)
      converter.raw(v) unless v.nil?
    end

    # Creates a singleton attribute accessor on an instance.
    #
    # @param [Foraneus] instance
    # @param [Symbol] attribute
    # @param initial_value
    def self.singleton_attr_accessor(instance, attribute, initial_value = nil)
      spec = instance.class

      instance.singleton_class.send(:attr_accessor, spec.accessors[attribute])

      instance.instance_exec do
        instance.instance_variable_set(:"@#{spec.accessors[attribute]}", initial_value)
      end
    end

  end
end
