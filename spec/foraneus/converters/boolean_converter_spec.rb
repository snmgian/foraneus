require 'spec_helper'

describe Foraneus::Converters::Boolean do

  its(:code_name) { should be(:boolean) }

  describe 'parse' do
    it "returns true with true" do
      parsed = subject.parse(true)

      parsed.should be_true
    end

    it "returns true with 'true'" do
      parsed = subject.parse('true')

      parsed.should be_true
    end

    it "returns false with sth else" do
      parsed = subject.parse('false')
      
      parsed.should be_false
    end
  end
end
