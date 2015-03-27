# Foraneus

Foraneus allows to:
 - parse data coming from external sources (like an HTTP request).
 - convert data back to a raw representation suitable for being used at the outside, like an HTML
form.

No matter which source of data is fed into Foraneus (external or internal), any instance can return
raw and parsed data.

## Basic usage

 - Declaration:

  ``` ruby
  class MyForm < Foraneus
    integer :delay
    float :duration
  end
  ```

 - From the outside:

  ``` ruby
  form = MyForm.parse(:delay => '5', :duration => '2.14')
  ```

  ``` ruby
  form.delay    # => 5
  form[:delay]  # => '5'
  ```

  ``` ruby
  form.data   # => { :delay => 5, :duration => 2.14 }
  form[]      # => { :delay => '5', :duration => '2.14' }
  ```

 - From the inside:

  ``` ruby
  form = MyForm.raw(:delay => 5, :duration => 2.14)
  ```

  ``` ruby
  form.delay    # => 5
  form[:delay]  # => '5'
  ```

  ``` ruby
  # the parsed attributes
  form.data   # => { :delay => 5, :duration => 2.14 }

  # the received attributes
  form[]      # => { :delay => '5', :duration => '2.14' }
  ```

## Declaration

Declare source classes by inheriting from `Foraneus` base class.

  ``` ruby
  class MyForm < Foraneus
    field :delay, SomeCustomConverter.new
    float :duration
  end
  ```

Fields are declared by two ways:

 - calling `.field`
 - calling a shortcut method, like `.float`


There are shortcut methods for any of the built-in converters: boolean, date, decimal, float, integer,
noop, and string.

When no converter is passed to `.field`, `Foraneus::Converters::Noop` is assigned to the declared
field.

## Instantiation

Foraneus instances can be obtained by calling two methods: `parse` and `raw`.

Use `.parse` when:
 - data is coming from outside of the system, like an HTTP request.

Use `.raw` when:
 - data is coming from the inside of the system, like a business layer.

## Converters

Converters have two interrelated responsibilities:

 - Parse data, like the string `"3,000"`, into an object, `like 3_000`.
 - Serialize data, like integer `3_000`, into string `"3,000"`

A converter is an object that responds to `#parse(s)`, `#raw(v)`, and `#opts` methods.

When `#parse(s)` raises a StandardError exception, or any of its descendants, the exception is
rescued and a `Foraneus::Error` instance is added to `Foraneus#errors` map.

`#opts` should return the opts hash used to instantiate the converter.

Built-in converters:

 - Boolean
 - Date
 - Decimal
 - Float
 - Integer
 - Noop
 - String

## Validations

Foraneus only validates that external data can be converted to the specified types. Smart
validations, like date range inclusion, are out of the scope of this gem.

`#valid?` and `#errors` are handy methods that tell whether a Foraneus instance is valid or not.

Valid instance:

  ``` ruby
  form.valid?     # => true
  form.errors   # => {}
  ```

Invalid one:

  ``` ruby
  form = MyForm.parse(:delay => 'INVALID')

  form.valid?                     # => false

  form.errors[:delay].key       # => 'ArgumentError'
  form.errors[:delay].message   # => 'invalid value for Integer(): "INVALID"'
  ```

`#errors` is a map in which keys correspond to field names, and values are instances of
`Foraneus::Error`.

The name of the exception raised by `#parse` is the error's `key` attribute, and the exception's
message is set to the error's `message` attribute.

Data coming from the inside is assumed to be valid, so `.raw` won't return an instance having
errors neither being invalid.

## Required fields

Fields can be declared as required.

  ``` ruby
  class MyForm < Foraneus
    integer :delay, :required => true
  end
  ```

If an external value is not fed into a required field, an error with key `KeyError` will be assigned.

  ``` ruby
  form = MyForm.parse

  form.valid?                       # => false

  form.errors[:delay].key         # => 'KeyError'
  form.errors[:delay].message     # => 'required parameter not found: "delay"'
  ```

## Absence of optional fields

Absent fields are treated as `nil` when invoking accessor methods.

  ``` ruby
  MyForm = Class.new(Foraneus) { string :name }
  form = MyForm.parse

  form.name       # => nil
  ```

Data accessors don't include any absent field.

  ``` ruby
  form.data       # => {}
  form[]          # => {}
  ```

## Blank values

By default, any blank value is treated as nil.

  ``` ruby
  MyForm = Class.new(Foraneus) { string :name }

  MyForm.parse(:name => '').name
  # => nil
  ```

This behaviour can be modified by setting opt `blanks_as_nil` to false.

  ``` ruby
  MyForm = Class.new(Foraneus) { string :name, :blanks_as_nil => false }

  MyForm.parse(:name => '').name
  # => ''
  ```

## Default values

Define fields with default values:

  ``` ruby
  MyForm = Class.new(Foraneus) { string :name, :default => 'Alice' }
  ```

Parse data from the ouside:

  ``` ruby
  form = MyForm.parse

  form.name             # => 'Alice'
  form.data             # => { :name => 'Alice' }

  form[:name]           # => nil, because data from the outside
                        #    don't include any value

  form[]                # => {}
  ```

Convert values back from the inside:

  ``` ruby
  form = MyForm.raw

  form[:name]           # => 'Alice'
  form.name             # => nil, because data from the inside
                        #    don't include any value
  ```

## Prevent name clashes

It is possible to rename methods `#errors` and `#data` so it will not conflict with defined fields.

  ``` ruby
  MyForm = Class.new(Foraneus) {
    field :errors
    field :data

    accessors[:errors] = :non_clashing_errors
    accessors[:data] = :non_clashing_data
  }
  ```

  ``` ruby
  form = MyForm.parse(:errors => 'some errors', :data => 'some data')

  form.errors                 # => 'some errors'
  form.data                   # => 'some data'

  form.non_clashing_errors    # []
  form.non_clashing_data      # { :errors => 'some errors', :data => 'some data' }
  ```

## Nesting
Forms can also have form fields.

  ``` ruby
  class Profile < Foraneus
    string  :email

    form    :coords do
      integer :x
      integer :y
    end
  end
  ```

  ``` ruby
  profile = Profile.parse(:email => 'mail@example.org', :coords => { :x => '1', :y => '2' })

  profile.email     # => mail@example.org

  profile.coords.x # => 1
  profile.coords.y # => 2

  profile.coords[:x] # => '1'
  profile.coords[:y] # => '2'

  ```

  ``` ruby
  profile.coords.data # => { :x => 1, :y => 2 }
  profile.coords[]    # => { :x => '1', :y => '2' }
  ```

  ``` ruby
  profile[:coords] # =>  { :x => '1', :y => '2' }
  ```

  ``` ruby
  profile.data # => { :email => 'mail.example.org', :coords => { :x => 1, :y => 2 } }
  profile[] # => { :email => 'mail@example.org', :coords => { :x => '1', :y => '2' } }
  ```

 - Absence
  ``` ruby
  profile = Profile.parse

  profile.coords # => nil
  profile.data   # => {}
  profile[]      # => {}
  ```

  - .Nullity
  ``` ruby
  profile = Profile.parse(:coords => nil)

  profile.coords # => nil
  profile.data   # => { :coords => nil }
  profile[]      # => { :coords => nil }
  ```

 - Emptiness
  ``` ruby
  profile = Profile.parse(:coords => {})

  profile.coords.x    # => nil
  profile.coords.y    # => nil

  profile.coords.data # => {}
  profile.coords[]    # => {}

  profile.data  # => { :coords => {} }
  profile[] # => { :coords => {} }
  ```

 - Validations
  ``` ruby
  profile = Profile.parse(:coords => { :x => '0', :y => '0' })

  profile.coords.valid? # => true
  profile.coords.errors # => {}
  ```

  ``` ruby
  profile = Profile.parse(:coords => { :x => 'FIVE' })

  profile.coords.x  # => nil

  profile.coords.valid? # => false

  profile.coords.errors[:x].key # => 'ArgumentError'
  profile.coords.errors[:x].message   # => 'invalid value for Integer(): "FIVE"'

  profile.valid?  # => false

  profile.errors[:coords].key # => 'NestedFormError'
  profile.errors[:coords].message # => 'Invalid nested form: coords'
  ```

  ``` ruby
  profile = Profile.parse(:coords => 'FIVE,SIX')

  profile.coords    # => nil


  profile.valid?  # => false
  profile.errors[:coords].key # => 'NestedFormError'
  profile.errors[:coords].message # => 'Invalid nested form: coords'
  ```

 - From the inside:
  ``` ruby
  profile = Profile.raw(:email => 'mail@example.org', :coords => { :x => 1, :y => 2 })
  ```

  ``` ruby
  profile.coords.x  # => 1
  profile.coords.data  # => { :x => 1, :y => 2 }

  profile.coords[:x] # => '1'
  profile.coords[]  # => { :x => '1', :y => '2' }
  ```

  ``` ruby
  profile.data # => { :email => 'email.example.org', :coords => { :x => 0, :y => 0 } }
  profile[] # => { :email => 'email@example.org', :coords => { :x => '0', :y => '0' } }
  ```
  - .Absence

  ```
  profile = Profile.raw

  profile.coords # => nil
  profile.data   # => {}
  profile[]      # => {}
  ```

  - .Nullity
  ``` ruby
  profile = Profile.raw(:coords => nil)

  profile.coords # => nil
  profile.data   # => { :coords => nil }
  profile[]      # => { :coords => nil }
  ```

  - .Emptiness
  ``` ruby
  profile = Profile.raw(:coords => {})

  profile.coords.x  # => nil
  profile.coords.y  # => nil

  profile.coords.data # => {}
  profile.coords[]    # => {}

  profile.data      # => { :coords => {} }
  profile[]      # => { :coords => {} }
  ```


## Installation

 - Install `foraneus` as a gem.

    ``` shell
    gem install foraneus
    ```

## Running tests

Tests are written in MiniTest. To run them all just execute the following from your command line:

  ``` shell
  ruby spec/runner.rb
  ```

Execute the following when ruby 1.8.7:

  ``` shell
  ruby -rubygems spec/runner.rb
  ```

To run a specific test case:

  ``` shell
    ruby -Ispec -Ilib spec/lib/foraneus_spec.rb
  ```

When running under ruby 1.8.7:

  ``` shell
    ruby -rubygems -Ispec -Ilib spec/lib/foraneus_spec.rb
  ```

## Code documentation

Documentation is written in Yard. To see it in a browser, execute this command:

  ``` shell
  yard server --reload
  ```

Then point the browser to `http://localhost:8808/`.

## Badges

[![Build Status](https://travis-ci.org/snmgian/foraneus.svg?branch=master)](https://travis-ci.org/snmgian/foraneus) [![Code Climate](https://codeclimate.com/github/snmgian/foraneus.png)](https://codeclimate.com/github/snmgian/foraneus)

## License

This software is licensed under the [LGPL][lgpl] license.

[lgpl]: https://www.gnu.org/licenses/lgpl.html
