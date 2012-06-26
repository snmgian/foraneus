module Foraneus
end

[
  :arrayable,
  :base,
  :errors,
  :markers,
].each { |f| require_relative "foraneus/#{f}" }
