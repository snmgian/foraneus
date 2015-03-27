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
    @_ = {} # Hash that holds external representation data
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

  # Return the names of data and error accessors
  #
  # Returned hash contains the keys :data and :errors, where values are the proper accesor names
  #
  # @return [Hash]
  def self.accessors
    @accessors ||= {
      :data => :data,
      :errors => :errors
    }
  end

  # Create a new instance while setting up data and error accessors
  #
  # @return [Foraneus]
  def self.create_instance
    instance = self.new

    Utils.singleton_attr_accessor(instance, :data, {})
    Utils.singleton_attr_accessor(instance, :errors, {})

    instance
  end

  # Parses data coming from an external source.
  #
  # @param [Hash<Symbol, String>] data External data.
  #
  # @return [Foraneus] An instance of a form.
  def self.parse(data = {})
    instance = self.create_instance
    data = data.dup

    instance.instance_variable_set(:@_, data.dup)

    fields.each do |field, converter|
      __parse_field(data, field, converter, instance)
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
    data = data.dup

    instance.send("#{self.accessors[:data]}=", data)

    fields.each do |field, converter|
      __raw_field(data, field, converter, instance)
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
      @_.fetch(m.to_s) do
        @_[m.to_sym]
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

  def self.__parse_field(data, field, converter, instance)
    s, is_present = Utils.fetch(data, field)

    v, error = Utils.parse_datum(field, s, converter)

    if error.nil? && !v.nil? && Foraneus::Utils.nested_converter?(converter)
      instance.send(self.accessors[:data])[field.to_sym] = v.data if is_present
      instance.send("#{field}=", v)
      unless v.valid?
        error = Foraneus::Error.new('NestedFormError', "Invalid nested form: #{field}")
        instance.send(self.accessors[:errors])[field.to_sym] = error
      end

    elsif error.nil?
      instance.send("#{field}=", v)
      instance.send(self.accessors[:data])[field.to_sym] = v if is_present || converter.opts.include?(:default)
    else
      if Foraneus::Utils.nested_converter?(converter)
        error = Foraneus::Error.new('NestedFormError', "Invalid nested form: #{field}")
        instance.send(self.accessors[:errors])[field.to_sym] = error
      else
        instance.send(self.accessors[:errors])[field.to_sym] = error if error
      end
    end
  end
  private_class_method :__parse_field

  def self.__raw_field(data, field, converter, instance)
    v, is_present = Utils.fetch(data, field)

    instance.send("#{field}=", v)

    if v.nil?
      v = converter.opts[:default]
    end

    s = Utils.raw_datum(v, converter)

    if Foraneus::Utils.nested_converter?(converter)
      instance.send("#{field}=", s)
    end

    if is_present || converter.opts.include?(:default)
      if Foraneus::Utils.nested_converter?(converter) && !s.nil?
        instance[field.to_sym] = s[]
      else
        instance[field.to_sym] = s
      end
    end
  end
  private_class_method :__raw_field

end
