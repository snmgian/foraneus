require 'spec_helper'

describe Foraneus do
  let(:converter) { Foraneus::Converters::Integer.new }

  let(:form_spec) {
    c = converter
    Class.new(Foraneus) do
      field :delay, c
    end
  }

  describe '.parse' do
    context 'with parseable data' do
      subject(:form) { form_spec.parse(:delay => '5') }

      its(:delay) { should eq(5) }

      its([:delay]) { should eq('5') }

      its(['delay']) { should be_nil }

      its(:data) { should include(:delay => 5) }

      its([]) { should include(:delay => '5') }

      it { should be_valid }

      its([:errors]) { should be_empty }

      context 'when strings as keys' do
        subject(:form) { form_spec.parse('delay' => '5') }

        its(['delay']) { should eq('5') }

        its([:delay]) { should eq('5') }

        its(:data) { should include('delay' => 5) }

        its([]) { should include('delay' => '5') }
      end
    end

    context 'with non parseable data' do
      subject(:form) { form_spec.parse(:delay => 'FIVE') }

      its(:delay) { should be_nil }

      its([:delay]) { should eq('FIVE') }

      it { should_not be_valid }

      its([:errors]) { should include(:delay) }

      describe 'an error' do
        subject(:error) { form[:errors].values.first }

        let(:converter_exception) do
          begin
            converter.parse('FIVE')
          rescue
            e = $!
          end

          e
        end

        its(:key) { should eq(converter_exception.class.name) }

        its(:message) { should eq(converter_exception.message) }
      end
    end

    shared_examples 'an absent parameters handler' do |missing_value|
      subject(:form) { form_spec.parse(:delay => missing_value) }

      it { should be_valid }

      its(:delay) { should be_nil }

      its(:data) { should include(:delay => nil) }

      its([:delay]) { should eq(missing_value) }

      its([]) { should include(:delay => missing_value) }

      context 'when required field' do
        let(:converter) { Foraneus::Converters::Integer.new(:required => true) }

        it { should_not be_valid }

        its(:delay) { should be_nil }

        its(:data) { should_not include(:delay) }

        its([:delay]) { should eq(missing_value) }

        its([]) { should include(:delay => missing_value) }

        its([:errors]) { should include(:delay) }

        describe 'an error' do
          subject(:error) { form[:errors].values.first }

          its(:key) { should eq('KeyError') }
        end
      end
    end

    context 'with nil values' do
      it_behaves_like 'an absent parameters handler', nil
    end

    context 'with empty values' do
      it_behaves_like 'an absent parameters handler', ''
    end
  end

  describe '.raw' do
    subject(:form) { form_spec.raw(:delay => 5) }

    its(:data) { should include(:delay => 5) }

    its(:delay) { should eq(5) }

    its([:delay]) { should eq('5') }

    its([]) { should include(:delay => '5') }

    it { should be_valid }

    its([:errors]) { should be_empty }

    context 'when strings as keys' do
      subject(:form) { form_spec.raw('delay' => 5) }

      its(:data) { should include('delay' => 5) }

      its(['delay']) { should eq('5') }

      its([:delay]) { should eq('5') }

      its([]) { should include('delay' => '5') }
    end

    context 'with nil values' do
      subject(:form) { form_spec.raw('delay' => nil) }

      its(:data) { should include('delay' => nil) }

      its(['delay']) { should eq(nil) }

      its([:delay]) { should eq(nil) }

      its([]) { should include('delay' => nil) }
    end
  end
end
