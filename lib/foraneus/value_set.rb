module Foraneus

  class ValueSet

    def self.build(params = {})
      Foraneus::ValueSetBuilder.build(self, @meta, params)
    end

    def self.build!(*args)
      value_set = self.build(*args)
      if value_set.kind_of?(Foraneus::InvalidValueSet)
        raise Foraneus::ValueSetError.new(value_set)
      end

      value_set
    end

    def self.raw(form_or_params)
      Foraneus::RawValueSetBuilder.build(self, @meta, form_or_params)
    end

  end
end
