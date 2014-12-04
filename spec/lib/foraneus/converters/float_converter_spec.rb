require 'spec_helper'

describe Foraneus::Converters::Float do

  subject { Foraneus::Converters::Float.new }

  describe '#parse' do
    describe 'with valid values' do
      let(:number) { 1234.5678 }
      let(:raw_number) { number.to_s }

      it 'returns a float number' do
        parsed = subject.parse(raw_number)

        assert_kind_of Float, parsed
      end

      it 'parses the number' do
        parsed = subject.parse(raw_number)

        assert_equal number, parsed
      end

      describe 'with big ones' do
        let(:big_number) { (11 ** 11) + 0.33 }
        let(:raw_big_number) { big_number.to_s }

        it 'also returns a float number' do
          parsed = subject.parse(raw_big_number)

          assert_kind_of Float, parsed
        end

        it 'also parses the number' do
          parsed = subject.parse(raw_big_number)

          assert_equal big_number, parsed
        end
      end
    end

    describe 'when separator and delimiter are given' do
      let(:converter) {
        Foraneus::Converters::Float.new(:delimiter => '.', :separator => ',')
      }

      it 'parses a float representation' do
        s = '1.234.567,89'
        n = 1_234_567.89

        assert_equal n, converter.parse(s)
      end

      it 'parses a float representation when no integer part' do
        s = ',56'
        n = 0.56

        assert_equal n, converter.parse(s)
      end
    end

    describe 'with invalid values' do
      let(:raw_invalid) { 'INVALID' }

      it 'raises an error' do
        assert_raises(ArgumentError) {
          subject.parse(raw_invalid)
        }
      end
    end
  end

  describe '#raw' do
    it 'returns a string representation' do
      assert_equal '2.34', subject.raw(2.34)
    end

    describe 'when separator and delimiter are given' do
      let(:converter) {
        Foraneus::Converters::Float.new(:delimiter => '.', :separator => ',')
      }

      it 'returns a float representation' do
        n = 1_234_567.89
        s = '1.234.567,89'

        assert_equal s, converter.raw(n)
      end
    end

    describe 'when precision is given' do
      let(:converter) {
        Foraneus::Converters::Float.new(:precision => 2)
      }

      it 'fills with zeros when value precision is smaller than converter precision' do
        n = 3.1
        assert_equal '3.10', converter.raw(n)
      end

      it 'does not affect the representation when precision and converter precision are both equal' do
        n = 3.14
        assert_equal '3.14', converter.raw(n)
      end

      it 'does not truncate the representation when precision is larger than converter precision' do
        n = 3.145
        assert_equal '3.145', converter.raw(n)
      end
    end

  end
end
