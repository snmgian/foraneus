require 'spec_helper'

describe Foraneus::Converters::Boolean do

  describe '#parse' do
    it 'returns true with true' do
      parsed = subject.parse('true')

      parsed.should be_true
    end

    it 'returns false with sth else' do
      parsed = subject.parse('false')

      parsed.should be_false
    end
  end

  describe '#raw' do
    it 'returns "true" with true' do
      subject.raw(true).should eq('true')
    end

    it 'returns "false" with false' do
      subject.raw(false).should eq('false')
    end

    it 'returns "false" with nil' do
      subject.raw(nil).should eq('false')
    end

    it 'returns "true" with everything else' do
      subject.raw(:default).should eq('true')
    end
  end
end
