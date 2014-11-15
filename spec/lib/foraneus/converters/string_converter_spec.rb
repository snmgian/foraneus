require 'spec_helper'

describe Foraneus::Converters::String do

  subject { Foraneus::Converters::String.new }

  describe '#parse' do
    it 'returns the string' do
      parsed = subject.parse('string')

      assert_equal 'string', parsed
    end

    it 'returns a string representation' do
      parsed = subject.parse(1)

      assert_equal '1', parsed
    end
  end

  describe '#raw' do
    it 'returns the string' do
      assert_equal 'string', subject.raw('string')
    end

    it 'returns a string representation' do
      assert_equal '1', subject.raw(1)
    end
  end
end
