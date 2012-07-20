# Foraneus is library for parsing external data.
#
# It allows to define value_sets that specify how the external data is structured and how should be parsed.
module Foraneus

  @registry = {}

  # Returns the converters registry
  # @return [Hash<Symbol, ConverterDecorator>] A hash of registered converters
  def self.registry
    @registry
  end

  # Registers a converter.
  #
  # @param [Class<? extends Converters::AbstractConverter>] converter_class The converter
  def self.register(converter_class)

    decorated = Converters::ConverterDecorator.new(converter_class.new)
    @registry[decorated.name] = decorated 

    self.define_type_method(decorated.name)
  end

  # Defines a class method in {ValueSet} that corresponds to a converter.
  #
  # The defined method will be invoked when defining a value_set
  #
  # @api private
  #
  # @param [String] name The name of the converter
  def self.define_type_method(name)
    Foraneus::ValueSet.singleton_class.send :define_method, name do |field|
      self.send :attr_reader, field

      @meta ||= {}
      @meta[field] = name
    end
  end

end

[
  :converters,
  :errors,
  :hashlike,
  :markers,
  :simple_converters,
  :raw_value_set_builder,
  :value_set,
  :value_set_builder,
].each { |f| require_relative "foraneus/#{f}" }

Foraneus.register(Foraneus::Converters::Boolean)
Foraneus.register(Foraneus::Converters::Float)
Foraneus.register(Foraneus::Converters::Integer)
Foraneus.register(Foraneus::Converters::String)
