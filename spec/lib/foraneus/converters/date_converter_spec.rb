require 'spec_helper'

describe Foraneus::Converters::Date do

  subject(:converter) { Foraneus::Converters::Date.new }

  describe '#parse' do

    it 'parses a date representation' do
      s = '2012-04-13'

      result = converter.parse(s)

      result.year.should eq(2012)
      result.month.should eq(04)
      result.day.should eq(13)
    end

    context 'when format is given' do
      subject(:converter) {
        Foraneus::Converters::Date.new(:format => '%d/%m/%Y')
      }

      it 'parses a date representation' do
        s = '13/04/2012'

        result = converter.parse(s)

        result.year.should eq(2012)
        result.month.should eq(04)
        result.day.should eq(13)
      end
    end
  end

  describe '#raw' do
    let(:d) { Date.today }

    it 'returns a date representation' do
      s = d.strftime('%Y-%m-%d')

      converter.raw(d).should eq(s)
    end

    context 'when format is given' do
      let(:format) { '%m/%d/%Y' }
      subject(:converter) {
        Foraneus::Converters::Date.new(:format => format)
      }

      it 'returns a date representation' do
        s = d.strftime(format)

        converter.raw(d).should eq(s)
      end
    end
  end

end
