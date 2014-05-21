require_relative 'foraneus/converters/boolean'
require_relative 'foraneus/converters/date'
require_relative 'foraneus/converters/decimal'
require_relative 'foraneus/converters/float'
require_relative 'foraneus/converters/integer'
require_relative 'foraneus/converters/noop'
require_relative 'foraneus/converters/string'
require_relative 'foraneus/errors'

# Foraneus is library for parsing external data.
#
# It allows to define value_sets that specify how the external data is structured
#   and how it should be parsed.
class Foraneus

  attr_accessor :data

  def initialize(data = {})
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

  def self.noop(name)
    converter = Foraneus::Converters::Noop.new
    field(name, converter)
  end

  def self.string(name)
    converter = Foraneus::Converters::String.new
    field(name, converter)
  end

  def self.field(name, converter = nil)
    converter ||= Foraneus::Converters::Noop.new

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
      __parse_raw_datum(instance, k, v)
    end

    instance
  end

  # @param [Foraneus] foraneus
  # @param [String, Symbol] k
  # @param [String] v
  def self.__parse_raw_datum(foraneus, k, v)
    field = k.to_s
    converter = fields[field]

    return unless converter

    foraneus[k] = v

    unless v.nil?
      v = converter.parse(v)
    end

    foraneus.send("#{field}=", v)
    foraneus.data[k] = v

  rescue
    error = Foraneus::Error.new($!.class.name, $!.message)
    foraneus.instance_variable_get(:@errors)[k] = error
  end
  private_class_method :__parse_raw_datum

  def self.raw(data)
    instance = self.new

    data.each do |k, v|
      next unless fields.has_key?(k.to_s)
      instance.send("#{k}=", v)
      converter = fields[k.to_s]

      s = if v.nil?
        nil
      else
        converter.raw(v)
      end

      instance[k] = s
      instance.data[k] = v
    end

    instance
  end

  def [](m = nil)
    if m == :errors
      @errors
    elsif m.nil?
      @raw_data
    else
      @raw_data.fetch(m) do
        @raw_data[m.to_s]
      end
    end
  end

  def []=(k, v)
    @raw_data[k] = v
  end

  def valid?
    @errors.empty?
  end
end
