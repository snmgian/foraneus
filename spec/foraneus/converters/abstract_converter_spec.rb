require 'spec_helper'

describe Foraneus::Converters::AbstractConverter do

  describe 'code_name' do
    it "raises a NotImplementedError" do
      expect {
        subject.name
      }.to raise_error(NotImplementedError)
    end
  end

  describe 'parse' do
    it "raises a NotImplementedError" do
      expect {
        subject.parse(nil)
      }.to raise_error(NotImplementedError)
    end
  end

end

