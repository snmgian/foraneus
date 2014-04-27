module Foraneus

  # Adds hash read-only capabilities.
  module HashlikeValueSet

    # Returns the value associated with a key.
    #
    # Possible keys are:
    #  - valid?
    #  - errors
    #  - raw_values
    #  - as_hash
    #
    # @param [Symbol] key The key for the value to retrieve
    #
    # @return [Object, nil] The value associated with key, or nil if the key is unknown
    def [](key)
      ivar = case key
      when :valid?
        :@valid
      when :errors
        :@errors
      when :raw_values
        :@raw_values
      when :as_hash
        :@hash_values
      else
        nil
      end

      if ivar
        self.instance_variable_get(ivar)
      end
    end
  end

end
