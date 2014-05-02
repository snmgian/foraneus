require 'spec_helper'

describe Foraneus::Converters::String do

  describe '#parse' do
    it 'returns the string' do
      parsed = subject.parse('string')

      parsed.should == 'string'
    end
  end

  describe '#raw' do
    it 'returns the string' do
      subject.raw('a string').should eq('a string')
    end
  end
end
