module Foraneus

  # Module for building raw value_sets.
  module RawValueSetBuilder

    # Builds a RawValueSet.
    #
    # @param [Class] form_class A ValueSet class
    # @param [Hash] meta Meta information about fields and converters
    # @param [ValueSet, Hash] params ValueSet or Hash that will be used to build a RawValueSet
    #
    # @return [RawValueSet]
    def self.build(form_class, meta, params)
      if params.is_a?(Foraneus::ValueSet)
        self.raw_form(params)
      elsif params.is_a?(Hash)
        self.raw_params(form_class, meta, params)
      end
    end

    # Builds a RawValueSet from a ValueSet object.
    # @api private
    #
    # @param [ValueSet] value_set
    #
    # @return [RawValueSet]
    def self.raw_form(value_set)
      raw_vs_class = Class.new(value_set.class) do
        include Foraneus::RawValueSet
      end

      raw_vs = raw_vs_class.new
      value_set[:raw_values].each do |name, value|
        raw_vs.instance_variable_set("@#{name}", value)
      end
      raw_vs
    end

    # Builds a value_set and returns a RawValueSet.
    # @api private
    def self.raw_params(form_class, meta, params)
      form = Foraneus::ValueSetBuilder.build(form_class, meta, params)
      raw_form(form)
    end

  end
end
