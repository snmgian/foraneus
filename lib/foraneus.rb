# TODO refactor
class NestedFormError < StandardError
end

if RUBY_VERSION == '1.8.7'
  require 'foraneus/compatibility/ruby-1.8.7'
end

require 'foraneus/converters/boolean'
require 'foraneus/converters/date'
require 'foraneus/converters/decimal'
require 'foraneus/converters/float'
require 'foraneus/converters/integer'
require 'foraneus/converters/nested'
require 'foraneus/converters/noop'
require 'foraneus/converters/string'
require 'foraneus/errors'
require 'foraneus/utils'

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

  # Declares a nested form field
  #
  # @param [Symbol] name The name of the field.
  # @yield Yields to a nested foraneus spec.
  def self.form(name, &block)
    converter = Class.new(Foraneus::Converters::Nested, &block)
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

    __singleton_attr_reader(instance, :data, {})
    __singleton_attr_reader(instance, :errors, {})

    instance
  end

  # Parses data coming from an external source.
  #
  # @param [Hash<Symbol, String>] data External data.
  #
  # @return [Foraneus] An instance of a form.
  def self.parse(data = {})
    instance = self.create_instance

    fields.each do |field, converter|
      # TODO refactor, get rid of is_present
      is_present = true
      v = data.fetch(field) do
        field = field.to_sym
        data.fetch(field) do
          is_present = false
          nil
        end
      end

      __parse_raw_datum(field, v, instance, converter, is_present)
    end

    # try to remove the nedd of having an instance variable so it will not clash
    instance.instance_variable_set(:'@_', data.dup)

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

      __raw_datum(given_key, v, instance, converter)
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
  # @param [Boolean] is_present
  #
  # # TODO refactor
  def self.__parse_raw_datum(k, v, foraneus, converter, is_present)
    v = __parse(k, v, converter)

    foraneus.send("#{k}=", v)

    if !v.nil? && Foraneus::Utils.nested_converter?(converter)
      foraneus.send(self.accessors[:data])[k] = v.data if is_present

      unless v.valid?
        error = Foraneus::Error.new('NestedFormError', "Invalid nested form: #{k}")
        foraneus.send(self.accessors[:errors])[k] = error
      end

    else
      foraneus.send(self.accessors[:data])[k] = v if is_present
    end

  rescue
    error = Foraneus::Error.new($!.class.name, $!.message)
    foraneus.send(self.accessors[:errors])[k] = error
  end
  private_class_method :__parse_raw_datum

  # @api private
  #
  # Parses a raw value.
  #
  # @param [String, Symbol] field
  # @param [String] v Raw value.
  # @param converter
  #
  # @raise [KeyError] if converter requires a value but no one is given.
  #
  # @return [Object]
  def self.__parse(field, v, converter)
    if v == '' && converter.opts.fetch(:blanks_as_nil, true)
      v = nil
    end

    if v.nil? && converter.opts[:required]
      raise KeyError, "required parameter not found: #{field.inspect}"

    elsif v.nil? && converter.opts.include?(:default)
      converter.opts[:default]

    elsif v.nil? && Foraneus::Utils.nested_converter?(converter)
      nil

    elsif Foraneus::Utils.nested_converter?(converter) && !(Hash === v)
      raise NestedFormError, "Invalid nested form: #{field}"

    elsif v.nil?
      nil

    else
      converter.parse(v)
    end
  end
  private_class_method :__parse

  # @api private
  #
  # Obtains a raw representation of a value and assigns it to the corresponding field.
  #
  # It also registers errors if the conversion fails.
  #
  # @param [String, Symbol] k
  # @param [String] v
  # @param [Foraneus] foraneus
  # @param [Converter] converter
  def self.__raw_datum(k, v, foraneus, converter)
    foraneus.send("#{k}=", v)
    foraneus.send(self.accessors[:data])[k] = v

    if v.nil?
      v = converter.opts[:default]
    end

    s = unless v.nil?
      converter.raw(v)
    end

    if Foraneus::Utils.nested_converter?(converter)
      foraneus.send("#{k}=", s)
    end

    foraneus[k] = s
  end
  private_class_method :__raw_datum

  # @api private
  #
  # Creates a singleton attribute reader on an instance.
  #
  # @param [Foraneus] instance
  # @param [Symbol] attribute
  # @param initial_value
  def self.__singleton_attr_reader(instance, attribute, initial_value = nil)
    spec = instance.class

    instance.singleton_class.send(:attr_reader, spec.accessors[attribute])

    instance.instance_exec do
      instance.instance_variable_set(:"@#{spec.accessors[attribute]}", initial_value)
    end
  end
  private_class_method :__singleton_attr_reader

end
