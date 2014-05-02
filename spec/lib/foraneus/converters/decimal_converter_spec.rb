require 'spec_helper'

describe Foraneus::Converters::Decimal do

  subject(:converter) { Foraneus::Converters::Decimal.new }

  describe '#parse' do
    let(:s) { '1,234.56' }

    it 'parses a decimal representation' do
      s = '1,234.56'
      n = BigDecimal.new('1234.56')

      converter.parse(s).should eq(n)
    end

    it 'parses a decimal representation when no integer part' do
      s = '.56'
      n = BigDecimal.new('0.56')

      converter.parse(s).should eq(n)
    end

    context 'when separator and delimiter are given' do
      subject(:converter) { Foraneus::Converters::Decimal.new('.', ',') }

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
      s = '1,234,567.89'

      converter.raw(n).should eq(s)
    end

    context 'when separator and delimiter are given' do
      subject(:converter) { Foraneus::Converters::Decimal.new('.', ',') }

      it 'returns a decimal representation' do
        s = '1.234.567,89'

        converter.raw(n).should eq(s)
      end
    end
  end

end
