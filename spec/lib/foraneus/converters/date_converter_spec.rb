require 'spec_helper'

describe Foraneus::Converters::Date do

  let(:converter) { Foraneus::Converters::Date.new }

  describe '#parse' do

    it 'parses a date representation' do
      s = '2012-04-13'

      result = converter.parse(s)

      assert_equal 2012, result.year
      assert_equal 4, result.month
      assert_equal 13, result.day
    end

    describe 'when format is given' do
      let(:converter) {
        Foraneus::Converters::Date.new(:format => '%d/%m/%Y')
      }

      it 'parses a date representation' do
        s = '13/04/2012'

        result = converter.parse(s)

        assert_equal 2012, result.year
        assert_equal 4, result.month
        assert_equal 13, result.day
      end
    end
  end

  describe '#raw' do
    let(:d) { Date.new(2012, 4, 13) }

    it 'returns a date representation' do
      assert_equal '2012-04-13', converter.raw(d)
    end

    describe 'when format is given' do
      let(:format) { '%m/%d/%Y' }
      let(:converter) {
        Foraneus::Converters::Date.new(:format => format)
      }

      it 'returns a date representation' do
        assert_equal '04/13/2012', converter.raw(d)
      end
    end
  end

end
