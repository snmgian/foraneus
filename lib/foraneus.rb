module Foraneus

  @registry = {}

  def self.registry
    @registry
  end

  def self.register(converter_class)

    decorated = Converters::ConverterDecorator.new(converter_class.new)
    @registry[decorated.name] = decorated 

    self.define_type_method(decorated.name)
  end

  def self.define_type_method(name)
    Foraneus::ValueSet.singleton_class.send :define_method, name do |field|
      self.send :attr_reader, field

      @meta ||= {}
      @meta[field] = :float
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

Foraneus.register(Foraneus::Converters::Float)
