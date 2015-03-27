require 'foraneus'

class Foraneus
  module Utils
    def self.nested_converter?(converter)
      Class === converter && converter.ancestors.include?(Foraneus)
    end
  end
end
