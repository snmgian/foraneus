require 'spec_helper'

describe Foraneus::Converters::Decimal do

  subject(:converter) { Foraneus::Converters::Decimal.new }

  describe '#parse' do
    it 'parses a decimal representation' do
      s = '1234.56'
      n = BigDecimal.new('1234.56')

      converter.parse(s).should eq(n)
    end

    it 'parses a decimal representation when no integer part' do
      s = '.56'
      n = BigDecimal.new('0.56')

      converter.parse(s).should eq(n)
    end

    context 'when separator and delimiter are given' do
      subject(:converter) {
        Foraneus::Converters::Decimal.new(:delimiter => '.', :separator => ',')
      }

      it 'parses a decimal representation' do
        s = '1.234.567,89'
        n = BigDecimal.new('1234567.89')

        converter.parse(s).should eq(n)
      end

      it 'parses a decimal representation when no integer part' do
        s = ',56'
        n = BigDecimal.new('0.56')

        converter.parse(s).should eq(n)
      end
    end
  end

  describe '#raw' do
    let(:n) { BigDecimal.new('1234567.89') }

    it 'returns a decimal representation' do
      s = '1234567.89'

      converter.raw(n).should eq(s)
    end

    context 'when separator and delimiter are given' do
      subject(:converter) {
        Foraneus::Converters::Decimal.new(:delimiter => '.', :separator => ',')
      }

      it 'returns a decimal representation' do
        s = '1.234.567,89'

        converter.raw(n).should eq(s)
      end
    end

    context 'when precision is given' do
      subject(:converter) {
        Foraneus::Converters::Decimal.new(:precision => 2)
      }

      it 'fills with zeros when value precision is smaller than converter precision' do
        n = BigDecimal.new('3.1')
        converter.raw(n).should eq('3.10')
      end

      it 'does not affect the representation when precision and converter precision are both equal' do
        n = BigDecimal.new('3.14')
        converter.raw(n).should eq('3.14')
      end

      it 'does not truncate the representation when precision is larger than converter precision' do
        n = BigDecimal.new('3.145')
        converter.raw(n).should eq('3.145')
      end
    end
  end

end
