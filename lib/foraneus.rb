require_relative 'foraneus/converters/boolean'
require_relative 'foraneus/converters/date'
require_relative 'foraneus/converters/decimal'
require_relative 'foraneus/converters/float'
require_relative 'foraneus/converters/integer'
require_relative 'foraneus/converters/string'
require_relative 'foraneus/errors'

# Foraneus is library for parsing external data.
#
# It allows to define value_sets that specify how the external data is structured
#   and how it should be parsed.
class Foraneus

  attr_accessor :data

  def initialize
    @data = {}
    @raw_data = {}

    @errors = {}
  end

  def self.boolean(name)
    converter = Foraneus::Converters::Boolean.new
    field(name, converter)
  end

  def self.date(name, *args)
    converter = Foraneus::Converters::Date.new(*args)
    field(name, converter)
  end

  def self.decimal(name, *args)
    converter = Foraneus::Converters::Decimal.new(*args)
    field(name, converter)
  end

  def self.float(name)
    converter = Foraneus::Converters::Float.new
    field(name, converter)
  end

  def self.integer(name)
    converter = Foraneus::Converters::Integer.new
    field(name, converter)
  end

  def self.string(name)
    converter = Foraneus::Converters::String.new
    field(name, converter)
  end

  def self.field(name, converter)
    fields[name.to_s] = converter
    self.send(:attr_accessor, name)
  end

  def self.fields
    @fields ||= {}
  end

  def self.parse(raw_data)
    instance = self.new

    parsed_data = {}

    raw_data.each do |k, v|
      field = k.to_s
      converter = fields[field]
      continue unless converter

      instance[k] = v
      begin
        v = converter.parse(v)
        instance.send("#{field}=", v)
        instance.data[k] = v
      rescue
        error = Foraneus::Error.new($!.class.name, $!.message)
        instance.instance_variable_get(:@errors)[k] = error
      end
    end

    instance
  end

  def self.raw(data)
    instance = self.new

    parsed_data = {}
    data.each do |k, v|
      next unless fields.has_key?(k.to_s)
      instance.send("#{k}=", v)
      converter = fields[k.to_s]
      s = converter.raw(v)
      instance[k] = s
      parsed_data[k.to_s] = v
    end

    instance.data = parsed_data
    instance
  end

  def [](m)
    if m == :errors
      @errors
    else
      @raw_data[m.to_s]
    end
  end

  def []=(k, v)
    @raw_data[k.to_s] = v
  end

  def valid?
    @errors.empty?
  end
end
