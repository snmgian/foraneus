module Foraneus

  module ArrayValueSet
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
