require 'spec_helper'

describe Foraneus::Converters::Float do

  its(:code_name) { should be(:float) }

  describe 'parse' do
    context 'with valid values' do
      let(:number) { 2.3412 }
      let(:raw_number) { number.to_s }

      it "returns a float number" do
        parsed = subject.parse(raw_number)
        
        parsed.should be_a(Float)
      end

      it "parses the number" do
        parsed = subject.parse(raw_number)

        parsed.should == number
      end

      context 'with big ones' do
        let(:big_number) { (11 ** 20) + 0.33 }
        let(:raw_big_number) { big_number.to_s }

        it "also returns a float number" do
          parsed = subject.parse(raw_big_number)
          
          parsed.should be_a(Float)
        end

        it "also parses the number" do
          parsed = subject.parse(raw_big_number)

          parsed.should == big_number
        end
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
      it "raises an error" do
        expect {
          subject.parse('')
        }.to raise_error
      end
    end
  end
end
