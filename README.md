# Foraneus

## Usage

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

  ``` ruby
  form.valid?   # => true
  form.errors   # => {}
  ```

 - From the inside:

  ``` ruby
  form = MyForm.new
  ```

  ``` ruby
  form.delay    # => nil
  form[:delay]  # => nil
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
  form.data   # => { :delay => 5, :duration => 2.14 }
  form[]      # => { :delay => '5', :duration => '2.14' }
  ```

## Installation

 - Install `foraneus` as a gem.

    ``` shell
    gem install foraneus
    ```

## Running tests

Tests are written in RSpec. To run them all just execute the following from your command line:

  ``` shell
  rspec
  ```

## Badges

[![Build Status](https://travis-ci.org/snmgian/foraneus.svg?branch=master)](https://travis-ci.org/snmgian/foraneus) [![Code Climate](https://codeclimate.com/github/snmgian/foraneus.png)](https://codeclimate.com/github/snmgian/foraneus)

## License

This software is licensed under the [LGPL][lgpl] license.

[lgpl]: https://www.gnu.org/licenses/lgpl.html
