require 'spec_helper'

    class ConverterDecorator < SimpleDelegator
      def initialize(converter)
        super(converter)
        @source = converter
      end

      def parse(value)
        return nil if value.nil?

        begin
          @source.parse(value)
        rescue
          raise Foraneus::ConverterError.new(value, @source.code_name)
        end
      end
    end

describe Foraneus::Converters::ConverterDecorator do

  let(:converter) do
    double(:converter)
  end

  subject { Foraneus::Converters::ConverterDecorator.new(converter) }

  it "delegates #name" do
    converter.stub(:name).and_return(:converter_name)

    subject.name.should == :converter_name
  end

  describe "parse" do
    context "with sth" do
      it "delegates to #parse" do
        converter.stub(:parse).with(anything).and_return(:parsed_value)

        subject.parse(:v).should == :parsed_value
      end
    end

    context "with nil" do
      it "returns nil when value is nil" do
        subject.parse(nil).should be_nil
      end

      it "doesn't delegate to #parse" do
        converter.should_not_receive(:parse).with(anything)

        subject.parse(nil).should be_nil
      end
    end

    context "when converter raises a StandardError" do
      before(:each) do
        converter.stub(:name).and_return(:code_name)
        converter.stub(:parse).and_raise(StandardError)
      end

      it "raises a ConverterError" do
        expect {
          subject.parse(:value)
        }.to raise_error(Foraneus::ConverterError)
      end

      describe "the raised error" do
        it "tracks the original value" do
          begin
            subject.parse(:value)
          rescue StandardError => e
          end

          e.value.should == :value
        end

        it "tracks the converter's name" do
          begin
            subject.parse(:value)
          rescue StandardError => e
          end

          e.converter_name.should == converter.name
        end
      end
    end
  end
end

