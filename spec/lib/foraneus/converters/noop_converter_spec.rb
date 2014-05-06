require 'spec_helper'

describe Foraneus::Converters::Noop do

  describe '#parse' do
    it 'returns the given object' do
      o = Object.new

      subject.parse(o).should be(o)
    end
  end

  describe '#raw' do
    it 'returns the given object' do
      o = Object.new

      subject.raw(o).should be(o)
    end
  end
end
