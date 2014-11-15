require 'spec_helper'

describe Foraneus::Converters::Integer do

  let(:converter) { Foraneus::Converters::Integer.new }

  describe '#parse' do

    describe 'with valid values' do
      let(:number) { 1234 }
      let(:raw_number) { number.to_s }

      it 'returns an integer number' do
        parsed = converter.parse(raw_number)

        assert_kind_of Integer, parsed
      end

      it 'parses the number' do
        parsed = converter.parse(raw_number)

        assert_equal number, parsed
      end

      describe 'with big ones' do
        let(:big_number) { (11 ** 20) }
        let(:raw_big_number) { big_number.to_s }

        it 'also returns an integer' do
          parsed = converter.parse(raw_big_number)

          assert_kind_of Integer, parsed
        end

        it 'also parses the number' do
          parsed = converter.parse(raw_big_number)

          assert_equal big_number, parsed
        end
      end
    end

    describe 'when delimiter is given' do
      let(:converter) {
        Foraneus::Converters::Integer.new(:delimiter => '.')
      }

      it 'parses an integer representation' do
        s = '1.234.567'
        n = 1_234_567

        assert_equal n, converter.parse(s)
      end
    end

    describe 'with invalid values' do
      let(:raw_invalid) { 'INVALID' }

      it 'raises an error' do
        assert_raises(ArgumentError) {
          converter.parse(raw_invalid)
        }
      end
    end

    describe 'with empty values' do
      it 'raises an error' do
        assert_raises(ArgumentError) {
          converter.parse('')
        }
      end
    end

    describe 'with nil values' do
      it 'raises an error' do
        assert_raises(TypeError) {
          converter.parse(nil)
        }
      end
    end
  end

  describe '#raw' do
    it 'returns a string representation' do
      assert_equal('2', converter.raw(2))
    end

    describe 'when delimiter is given' do
      let(:converter) {
        Foraneus::Converters::Integer.new(:delimiter => '.')
      }

      it 'parses an integer representation' do
        n = 1_234_567
        s = '1.234.567'

        assert_equal(s, converter.raw(n))
      end
    end

  end

end
