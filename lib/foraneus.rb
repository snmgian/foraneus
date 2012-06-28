module Foraneus

  @registry = {}

  def self.registry
    @registry
  end

  def self.register(converter_class)

    decorated = Converters::ConverterDecorator.new(converter_class.new)
    @registry[decorated.code_name] = decorated 
  end
end

[
  :arrayable,
  :base,
  :converters,
  :errors,
  :markers,
  :simple_converters,
].each { |f| require_relative "foraneus/#{f}" }

Foraneus.register(Foraneus::Converters::Float)
