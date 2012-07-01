module Foraneus
  module RawValueSetBuilder

    def self.build(form_class, meta, form_or_params)
      if form_or_params.is_a?(Foraneus::ValueSet)
        self.raw_form(form_or_params)
      elsif form_or_params.is_a?(Hash)
        self.raw_params(form_class, meta, form_or_params)
      end
    end

    def self.raw_form(form)
      raw_form_class = Class.new(form.class) do
        include Foraneus::RawValueSet
      end

      raw_form = raw_form_class.new
      form[:raw_values].each do |name, value|
        raw_form.instance_variable_set("@#{name}", value)
      end
      raw_form
    end

    def self.raw_params(form_class, meta, params)
      form = Foraneus::ValueSetBuilder.build(form_class, meta, params)
      raw_form(form)
    end

  end
end
