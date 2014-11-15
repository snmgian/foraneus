require 'spec_helper'

describe Foraneus::Converters::Boolean do

  let(:converter) { Foraneus::Converters::Boolean.new }

  describe '#parse' do
    it 'returns true with true' do
      parsed = converter.parse('true')

      assert_equal true, parsed
    end

    it 'returns false with sth else' do
      parsed = converter.parse('false')

      assert_equal false, parsed
    end
  end

  describe '#raw' do
    it 'returns "true" with true' do
      assert_equal 'true', converter.raw(true)
    end

    it 'returns "false" with false' do
      assert_equal 'false', converter.raw(false)
    end

    it 'returns "false" with nil' do
      assert_equal 'false', converter.raw(nil)
    end

    it 'returns "true" with everything else' do
      assert_equal 'true', converter.raw(:default)
    end
  end
end
