require_relative 'foraneus/errors'
require_relative 'foraneus/simple_converters'

# Foraneus is library for parsing external data.
#
# It allows to define value_sets that specify how the external data is structured
#   and how it should be parsed.

class Foraneus

  def initialize(data = {})
    @errors = {}

    @data = data.dup
  end

  def self.integer(name)
    converter = Foraneus::Converters::Integer.new
    field(name, converter)
  end

  def self.field(name, converter)
    fields[name] = converter
    self.send(:attr_accessor, name)
  end

  def self.fields
    @fields ||= {}
  end

  def self.parse(data)
    instance = self.new(data)

    data.each do |k, v|
      converter = fields[k]
      if converter
        begin
          v = converter.parse(v)
          instance.send("#{k}=", v)
        rescue
          error = Foraneus::Error.new($!.class.name, $!.message)
          instance.instance_variable_get(:@errors)[k] = error
        end
      else
        instance.send("#{k}=", v)
      end
    end

    instance
  end

  def self.raw(data)
    instance = self.new

    data.each do |k, v|
      instance.send("#{k}=", v)
      converter = fields[k]
      if converter
        s = converter.raw(v)
        instance[k] = s
      end
    end

    instance
  end

  def [](m)
    if m == :errors
      @errors
    else
      @data[m]
    end
  end

  def []=(k, v)
    @data[k] = v
  end

  def valid?
    @errors.empty?
  end
end
