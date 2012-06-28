require 'spec_helper'

describe Foraneus::Converters::AbstractConverter do

  describe 'code_name' do
    it "raises a NotImplementedError" do
      expect {
        subject.code_name
      }.to raise_error(NotImplementedError)
    end
  end

  describe 'parse' do
    it "raises a NotImplementedError" do
      expect {
        subject.parse
      }.to raise_error(NotImplementedError)
    end
  end

end

