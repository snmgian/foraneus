require 'spec_helper'

describe Foraneus::Converters::Decimal do

  let(:converter) { Foraneus::Converters::Decimal.new }

  describe '#parse' do
    it 'parses a decimal representation' do
      s = '1234.56'
      n = BigDecimal.new('1234.56')

      assert_equal n, converter.parse(s)
    end

    it 'parses a decimal representation when no integer part' do
      s = '.56'
      n = BigDecimal.new('0.56')

      assert_equal n, converter.parse(s)
    end

    describe 'when separator and delimiter are given' do
      let(:converter) {
        Foraneus::Converters::Decimal.new(:delimiter => '.', :separator => ',')
      }

      it 'parses a decimal representation' do
        s = '1.234.567,89'
        n = BigDecimal.new('1234567.89')

        assert_equal n, converter.parse(s)
      end

      it 'parses a decimal representation when no integer part' do
        s = ',56'
        n = BigDecimal.new('0.56')

        assert_equal n, converter.parse(s)
      end
    end
  end

  describe '#raw' do
    let(:n) { BigDecimal.new('1234567.89') }

    it 'returns a decimal representation' do
      s = '1234567.89'

      assert_equal s, converter.raw(n)
    end

    describe 'when separator and delimiter are given' do
      let(:converter) {
        Foraneus::Converters::Decimal.new(:delimiter => '.', :separator => ',')
      }

      it 'returns a decimal representation' do
        s = '1.234.567,89'

        assert_equal s, converter.raw(n)
      end
    end

    describe 'when precision is given' do
      let(:converter) {
        Foraneus::Converters::Decimal.new(:precision => 2)
      }

      it 'fills with zeros when value precision is smaller than converter precision' do
        n = BigDecimal.new('3.1')
        assert_equal '3.10', converter.raw(n)
      end

      it 'does not affect the representation when precision and converter precision are both equal' do
        n = BigDecimal.new('3.14')
        assert_equal '3.14', converter.raw(n)
      end

      it 'does not truncate the representation when precision is larger than converter precision' do
        n = BigDecimal.new('3.145')
        assert_equal '3.145', converter.raw(n)
      end
    end
  end

end
