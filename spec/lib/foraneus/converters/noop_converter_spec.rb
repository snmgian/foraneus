require 'spec_helper'

describe Foraneus::Converters::Noop do

  let(:converter) { Foraneus::Converters::Noop.new }

  describe '#parse' do
    it 'returns the given object' do
      o = Object.new

      assert_equal(o, converter.parse(o))
    end
  end

  describe '#raw' do
    it 'returns the given object' do
      o = Object.new

      assert_equal(o, converter.raw(o))
    end
  end
end
