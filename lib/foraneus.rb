module Foraneus

  @registry = {}

  def self.registry
    @registry
  end

  def self.register(parser)
    @registry[parser.code_name] = parser
  end
end

[
  :arrayable,
  :base,
  :errors,
  :markers,
  :types,
].each { |f| require_relative "foraneus/#{f}" }

Foraneus.register(Foraneus::Types::Float)
