require_relative 'foraneus/converters/boolean'
require_relative 'foraneus/converters/date'
require_relative 'foraneus/converters/decimal'
require_relative 'foraneus/converters/float'
require_relative 'foraneus/converters/integer'
require_relative 'foraneus/converters/noop'
require_relative 'foraneus/converters/string'
require_relative 'foraneus/errors'

# Foraneus base class used to declare a data set, aka 'form'.
class Foraneus


  # @return [Hash] Parsed data.
  attr_accessor :data

  # @api private
  def initialize
    @data = {}
    @raw_data = {}

    @errors = {}
  end

  # Declares a boolean field.
  #
  # @param [Symbol] name The name of the field.
  def self.boolean(name)
    converter = Foraneus::Converters::Boolean.new
    field(name, converter)
  end

  # Declares a date field.
  #
  # @param [Symbol] name The name of the field.
  # @param (see Foraneus::Converters::Date#initialize)
  def self.date(name, *args)
    converter = Foraneus::Converters::Date.new(*args)
    field(name, converter)
  end

  # Declares a decimal field.
  #
  # @param [Symbol] name The name of the field.
  # @param (see Foraneus::Converters::Decimal#initialize)
  def self.decimal(name, *args)
    converter = Foraneus::Converters::Decimal.new(*args)
    field(name, converter)
  end

  # Declares a float field.
  #
  # @param [Symbol] name The name of the field.
  # @param (see Foraneus::Converters::Float#initialize)
  def self.float(name, *args)
    converter = Foraneus::Converters::Float.new(*args)
    field(name, converter)
  end

  # Declares an integer field.
  #
  # @param [Symbol] name The name of the field.
  # @param (see Foraneus::Converters::Integer#initialize)
  def self.integer(name, *args)
    converter = Foraneus::Converters::Integer.new(*args)
    field(name, converter)
  end

  # Declares a noop field.
  #
  # @param [Symbol] name The name of the field.
  def self.noop(name)
    converter = Foraneus::Converters::Noop.new
    field(name, converter)
  end

  # Declares a string field.
  #
  # @param [Symbol] name The name of the field.
  def self.string(name)
    converter = Foraneus::Converters::String.new
    field(name, converter)
  end

  # Declares a field.
  #
  # When no converter is given, noop is assigned.
  #
  # @param [Symbol] name The name of the field.
  # @param [#parse, #raw] converter The converter.
  def self.field(name, converter = nil)
    converter ||= Foraneus::Converters::Noop.new

    fields[name.to_s] = converter
    self.send(:attr_accessor, name)
  end

  # Map of fields and their corresponding converters.
  #
  # @return [Hash<String, Converter>]
  def self.fields
    @fields ||= {}
  end

  # Parses data coming from an external source.
  #
  # @param [Hash<Symbol, String>] raw_data
  #
  # @return [Foraneus] An instance of a form.
  def self.parse(raw_data)
    instance = self.new

    raw_data.each do |k, v|
      __parse_raw_datum(instance, k, v)
    end

    instance
  end

  # Converts data into an external representation.
  #
  # @param [Hash<Symbol, Object>] data
  #
  # @return [Foraneus] An instance of a form.
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

  # @return [Hash] raw data when m == nil.
  # @return [Array<Error>] errors when m == :errors.
  # @return [String] raw data value for the field m.
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

  # @api private
  #
  # Sets a raw value.
  #
  # @param [Symbol] k Field name.
  # @param [String] v Raw value.
  def []=(k, v)
    @raw_data[k] = v
  end

  # Returns true if no conversion errors occurred. false otherwise.
  def valid?
    @errors.empty?
  end

  # @api private
  #
  # Parses a raw value and assigns it to the corresponding field.
  #
  # It also registers errors if the conversion fails.
  #
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

end
