require 'spec_helper'

describe Foraneus::Converters::Float do

  describe '#parse' do
    context 'with valid values' do
      let(:number) { 2.3412 }
      let(:raw_number) { number.to_s }

      it 'returns a float number' do
        parsed = subject.parse(raw_number)

        parsed.should be_a(Float)
      end

      it 'parses the number' do
        parsed = subject.parse(raw_number)

        parsed.should == number
      end

      context 'with big ones' do
        let(:big_number) { (11 ** 20) + 0.33 }
        let(:raw_big_number) { big_number.to_s }

        it 'also returns a float number' do
          parsed = subject.parse(raw_big_number)

          parsed.should be_a(Float)
        end

        it 'also parses the number' do
          parsed = subject.parse(raw_big_number)

          parsed.should == big_number
        end
      end
    end

    context 'when separator and delimiter are given' do
      subject(:converter) {
        Foraneus::Converters::Float.new(:delimiter => '.', :separator => ',')
      }

      it 'parses a float representation' do
        s = '1.234.567,89'
        n = 1_234_567.89

        converter.parse(s).should eq(n)
      end

      it 'parses a float representation when no integer part' do
        s = ',56'
        n = 0.56

        converter.parse(s).should eq(n)
      end
    end

    context 'with invalid values' do
      let(:raw_invalid) { 'INVALID' }

      it 'raises an error' do
        expect {
          subject.parse(raw_invalid)
        }.to raise_error
      end
    end

    context 'with empty values' do
      it 'raises an error' do
        expect {
          subject.parse('')
        }.to raise_error
      end
    end

    context 'with nil values' do
      it 'raises an error' do
        expect {
          subject.parse(nil)
        }.to raise_error
      end
    end
  end

  describe '#raw' do
    it 'returns a string representation' do
      subject.raw(2.34).should eq('2.34')
    end

    context 'when separator and delimiter are given' do
      subject(:converter) {
        Foraneus::Converters::Float.new(:delimiter => '.', :separator => ',')
      }

      it 'returns a float representation' do
        n = 1_234_567.89
        s = '1.234.567,89'

        converter.raw(n).should eq(s)
      end
    end

    context 'when precision is given' do
      subject(:converter) {
        Foraneus::Converters::Float.new(:precision => 2)
      }

      it 'fills with zeros when value precision is smaller than converter precision' do
        n = 3.1
        converter.raw(n).should eq('3.10')
      end

      it 'does not affect the representation when precision and converter precision are both equal' do
        n = 3.14
        converter.raw(n).should eq('3.14')
      end

      it 'does not truncate the representation when precision is larger than converter precision' do
        n = 3.145
        converter.raw(n).should eq('3.145')
      end
    end

  end
end
