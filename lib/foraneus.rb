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


  # @api private
  def initialize
    @_ = {}
  end

  # Declares a boolean field.
  #
  # @param [Symbol] name The name of the field.
  def self.boolean(name, *args)
    converter = Foraneus::Converters::Boolean.new(*args)
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
  def self.noop(name, *args)
    converter = Foraneus::Converters::Noop.new(*args)
    field(name, converter)
  end

  # Declares a string field.
  #
  # @param [Symbol] name The name of the field.
  def self.string(name, *args)
    converter = Foraneus::Converters::String.new(*args)
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

  def self.accessors
    @accessors ||= {
      :data => :data,
      :errors => :errors
    }
  end

  def self.create_instance
    instance = self.new
    spec = self

    instance.singleton_class.send(:attr_reader, self.accessors[:data])

    instance.instance_exec do
      instance.instance_variable_set(:"@#{spec.accessors[:data]}", {})
    end

    instance.singleton_class.send(:attr_reader, self.accessors[:errors])
    instance.instance_exec do
      instance.instance_variable_set(:"@#{spec.accessors[:errors]}", {})
    end

    instance
  end

  # Parses data coming from an external source.
  #
  # @param [Hash<Symbol, String>] data External data.
  #
  # @return [Foraneus] An instance of a form.
  def self.parse(data = {})
    instance = self.create_instance

    parsed_keys = []

    fields.each do |field, converter|
      given_key = field
      v = data.fetch(given_key) do
        given_key = field.to_sym
        data.fetch(given_key, nil)
      end

      parsed_keys << given_key
      __parse_raw_datum(given_key, v, instance, converter)
    end

    data.each do |k, v|
      unless parsed_keys.include?(k)
        instance[k] = v
      end
    end

    instance
  end

  # Converts data into an external representation.
  #
  # @param [Hash<Symbol, Object>] data
  #
  # @return [Foraneus] An instance of a form.
  def self.raw(data = {})
    instance = self.create_instance

    fields.each do |field, converter|
      given_key = field

      v = data.fetch(given_key) do
        given_key = field.to_sym
        data.fetch(given_key, nil)
      end

      instance.send("#{field}=", v)

      if v.nil?
        v = converter.opts[:default]
      end

      s = if v.nil?
        nil
      else
        converter.raw(v)
      end

      instance[given_key] = s
      instance.send(self.accessors[:data])[given_key] = v
    end

    instance
  end

  # @return [Hash] raw data when m == nil.
  # @return [Array<Error>] errors when m == :errors.
  # @return [String] raw data value for the field m.
  def [](m = nil)
    if m.nil?
      @_
    else
      @_.fetch(m) do
        @_[m.to_s]
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
    #raw_data = @_

    #raw_data[k] = v
    @_[k] = v
  end

  # Returns true if no conversion errors occurred. false otherwise.
  def valid?
    @errors.empty?
  end

  # @api private
  #
  # Parses a value and assigns it to the corresponding field.
  #
  # It also registers errors if the conversion fails.
  #
  # @param [String, Symbol] k
  # @param [String] v
  # @param [Foraneus] foraneus
  # @param [Converter] converter
  def self.__parse_raw_datum(k, v, foraneus, converter)
    field = k.to_s

    foraneus[k] = v

    if v == '' && converter.opts.fetch(:blanks_as_nil, true)
      v = nil
    end

    if v.nil? && converter.opts[:required]
      raise KeyError, "required parameter not found: #{field.inspect}"
    elsif v.nil?
      v = converter.opts[:default]
    else
      v = converter.parse(v)
    end

    foraneus.send("#{field}=", v)
    foraneus.send(self.accessors[:data])[k] = v

  rescue
    error = Foraneus::Error.new($!.class.name, $!.message)
    foraneus.send(self.accessors[:errors])[k] = error
  end
  private_class_method :__parse_raw_datum

end
