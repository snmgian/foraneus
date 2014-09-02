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

      its(:data) { should include(:delay => 5) }

      its([:delay]) { should eq('5') }

      its(['delay']) { should be_nil }

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

      context 'when empty strings' do
        let(:converter) { Foraneus::Converters::String.new }

        subject(:form) { form_spec.parse(:delay => '') }

        its(:delay) { should eq(nil) }

        its(:data) { should include(:delay => nil) }

        it { should be_valid }
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

    context 'with unexpected data' do
      subject(:form) { form_spec.parse(:position => 'north') }

      it 'does not have a getter for the received param' do
        expect {
          form.position
        }.to raise_error(NoMethodError)
      end

      its(:data) { should_not include(:position) }

      its([:position]) { should eq('north') }

      its([]) { should include(:position => 'north') }

      it { should be_valid }
    end

    context 'when a field is declared as blanks_as_nil = true' do
      let(:converter) { Foraneus::Converters::String.new(:blanks_as_nil => true) }

      subject(:form) { form_spec.parse(:delay => '') }

      its(:delay) { should be_nil }

      its(:data) { should include(:delay => nil) }

      its([:delay]) { should eq('') }

      its([]) { should include(:delay => '') }
    end

    context 'when a field is declared as blanks_as_nil = false' do
      let(:converter) { Foraneus::Converters::String.new(:blanks_as_nil => false) }

      subject(:form) { form_spec.parse(:delay => '') }

      its(:delay) { should eq('') }

      its(:data) { should include(:delay => '') }
    end

    shared_examples 'an absent parameters value handler' do |missing_value|
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
      it_behaves_like 'an absent parameters value handler', nil
    end

    context 'with empty values' do
      it_behaves_like 'an absent parameters value handler', ''
    end

    context 'when required field' do
      let(:converter) { Foraneus::Converters::Integer.new(:required => true) }

      context 'when missing input parameter' do
        subject(:form) { form_spec.parse }

        it { should_not be_valid }

        its(:delay) { should be_nil }

        its([:delay]) { should be_nil }
      end
    end

    context 'when default value' do
      let(:converter) { Foraneus::Converters::Integer.new(:default => 1) }

      subject(:form) { form_spec.parse }

      it { should be_valid }

      its(:delay) { should eq(1) }

      its(:data) { should include(:delay => 1) }

      its([:delay]) { should be_nil}

      its([]) { should include(:delay => nil) }

      its([:errors]) { should_not include(:delay) }

      context 'when missing required field' do
        let(:converter) { Foraneus::Converters::Integer.new(:default => 1, :required => true) }

        subject(:form) { form_spec.parse }

        it { should_not be_valid }

        its(:delay) { should be_nil }

        its([:delay]) { should be_nil }
      end
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

    context 'when default value' do
      let(:converter) { Foraneus::Converters::Integer.new(:default => 1) }

      subject(:form) { form_spec.raw }

      its(:delay) { should be_nil }

      its([:delay]) { should eq('1') }

      its([]) { should include(:delay => '1') }
    end
  end
end
