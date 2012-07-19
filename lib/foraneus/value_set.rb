module Foraneus

  # Base class from which all the value_sets should inherit.
  #
  # Concrete classes model a set of params/values that are parsed from an external source (like HTTP query params)
  class ValueSet

    # Builds an instance of ValueSet that conforms with its fields specification.
    #
    # If any of the params can be parsed by its corresponding convertor then an
    # {InvalidValueSet} and {RawValueSet} is returned that holds raw_values
    #
    # @param [Hash<Symbol, String>] params Hash that holds values that will be parsed and associated
    #   with the created ValueSet instance.
    # @return [ValueSet, InvalidValueSet, RawValueSet] A value_set
    def self.build(params = {})
      Foraneus::ValueSetBuilder.build(self, @meta, params)
    end

    # Builds an instance of ValueSet and raises an {ValueSetError} if invalid params.
    # @see .build
    # @param (see .build)
    def self.build!(params = {})
      value_set = self.build(params)
      if value_set.kind_of?(Foraneus::InvalidValueSet)
        raise Foraneus::ValueSetError.new(value_set)
      end

      value_set
    end

    # Returns a {RawValueSet} that corresponds to the given argument.
    #
    # @overload raw(value_set)
    #   @param [ValueSet] value_set ValueSet whose raw value will be used to create a {RawValueSet}
    #
    # @overload raw(params)
    #   @param [Hash] params Params for creating a {RawValueSet}
    #
    # @return [RawValueSet]
    def self.raw(vs_or_params)
      Foraneus::RawValueSetBuilder.build(self, @meta, vs_or_params)
    end

  end
end
