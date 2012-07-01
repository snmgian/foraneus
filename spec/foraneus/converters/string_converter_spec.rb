require 'spec_helper'

describe Foraneus::Converters::String do

  its(:name) { should be(:string) }

  describe 'parse' do
    it "returns the string" do
      parsed = subject.parse('string')

      parsed.should == 'string'
    end

    it "returns a string that represents the value" do
      parsed = subject.parse(1)

      parsed.should == '1'
    end
  end
end
