require 'spec_helper'

describe Foraneus::Converters::String do

  describe '#parse' do
    it 'returns the string' do
      parsed = subject.parse('string')

      parsed.should eq('string')
    end

    it 'returns a string representation' do
      parsed = subject.parse(1)

      parsed.should eq('1')
    end
  end

  describe '#raw' do
    it 'returns the string' do
      subject.raw('a string').should eq('a string')
    end

    it 'returns a string representation' do
      subject.raw(1).should eq('1')
    end
  end
end
