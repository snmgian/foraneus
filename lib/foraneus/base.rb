module Foraneus

  class Base

    def self.build(params = {})
      Foraneus::FormBuilder.build(self, @meta, params)
    end

    def self.build!(*args)
      form = self.build(*args)
      if form.kind_of?(Foraneus::InvalidXForm)
        raise Foraneus::FormError.new(form)
      end

      form
    end

    def self.raw(form_or_params)
      Foraneus::RawXFormBuilder.build(self, @meta, form_or_params)
    end

  end
end
