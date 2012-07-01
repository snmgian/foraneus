module Foraneus

  @registry = {}

  def self.registry
    @registry
  end

  def self.register(converter_class)

    decorated = Converters::ConverterDecorator.new(converter_class.new)
    @registry[decorated.code_name] = decorated 

    Foraneus::Base.singleton_class.send :define_method, decorated.code_name do |field|
      self.send :attr_reader, field

      @meta ||= {}
      @meta[field] = :float
    end
  end

end

[
  :arrayable,
  :base,
  :converters,
  :errors,
  :form_builder,
  :markers,
  :raw_form_builder,
  :simple_converters,
].each { |f| require_relative "foraneus/#{f}" }

Foraneus.register(Foraneus::Converters::Float)
