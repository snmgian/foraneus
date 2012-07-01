module Foraneus
  module RawXFormBuilder

    def self.build(form_class, meta, form_or_params)
      if form_or_params.is_a?(Foraneus::Base)
        self.raw_form(form_or_params)
      elsif form_or_params.is_a?(Hash)
        self.raw_params(form_class, meta, form_or_params)
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

    def self.raw_params(form_class, meta, params)
      form = Foraneus::FormBuilder.build(form_class, meta, params)
      raw_form(form)
    end

  end
end
