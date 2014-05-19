require 'spec_helper'

describe Foraneus::Converters::Integer do

  describe '#parse' do
    context 'with valid values' do
      let(:number) { 1234 }
      let(:raw_number) { number.to_s }

      it 'returns an integer number' do
        parsed = subject.parse(raw_number)

        parsed.should be_a(Integer)
      end

      it 'parses the number' do
        parsed = subject.parse(raw_number)

        parsed.should == number
      end

      context 'with big ones' do
        let(:big_number) { (11 ** 20) }
        let(:raw_big_number) { big_number.to_s }

        it 'also returns an integer' do
          parsed = subject.parse(raw_big_number)

          parsed.should be_a(Integer)
        end

        it 'also parses the number' do
          parsed = subject.parse(raw_big_number)

          parsed.should == big_number
        end
      end
    end

    context 'when delimiter is given' do
      subject(:converter) {
        Foraneus::Converters::Integer.new(:delimiter => '.')
      }

      it 'parses an integer representation' do
        s = '1.234.567'
        n = 1_234_567

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
      subject.raw(2).should eq('2')
    end

    context 'when delimiter is given' do
      subject(:converter) {
        Foraneus::Converters::Integer.new(:delimiter => '.')
      }

      it 'parses an integer representation' do
        n = 1_234_567
        s = '1.234.567'

        converter.raw(n).should eq(s)
      end
    end

  end

end
