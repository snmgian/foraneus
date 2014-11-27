require 'spec_helper'

describe Foraneus do
  let(:converter) { Foraneus::Converters::Integer.new }

  let(:form_spec) {
    c = converter
    Class.new(Foraneus) do
      field :delay, c
    end
  }

  describe 'when errors accessor is renamed' do
    let(:form_spec) {
      Class.new(Foraneus) do

        field :errors

        accessors[:errors] = :non_clashing_errors
      end
    }

    describe 'a parsed form' do
      let(:form) { form_spec.parse(:errors => 'errors') }

      it 'can return the errors field value' do
        assert_equal 'errors', form.errors
      end

      it 'can return the raw errors value' do
        assert_equal 'errors', form[:errors]
      end

      it 'responds to the new accessor' do
        assert_equal({}, form[:non_clashing_errors])
      end
    end
  end

  describe 'when data accessor is renamed' do
    let(:form_spec) {
      Class.new(Foraneus) do

        field :delay
        field :data

        accessors[:data] = :non_clashing_data
      end
    }

    describe 'a parsed form' do
      let(:form) { form_spec.parse(:delay => 5, :data => 'value') }

      it 'can return the data field value' do
        assert_equal 'value', form.data
      end

      it 'responds to the new accessor' do
        assert_equal({:delay => 5, :data => 'value'}, form.non_clashing_data)
      end

    end

    describe 'when obtaining a raw representation' do
      let(:form) { form_spec.raw(:delay => 5, :data => 'value') }

      it 'allows access to the data field value' do
        assert_equal 'value', form[:data]
      end

      it 'allows access to whole data set' do
        assert_equal({:delay => 5, :data => 'value'}, form[])
      end
    end
  end

  describe '.parse' do
    describe 'with parseable data' do
      subject { form_spec.parse(:delay => '5') }

      it 'parses' do

        assert_equal 5, subject.delay
        assert_equal 5, subject.data[:delay]

        assert_equal '5', subject[:delay]
        assert_nil subject['delay']
        assert_equal({ :delay => '5' }, subject[])

        assert subject.valid?
        assert subject[:valid?]

        assert_empty subject[:errors]
        assert_equal(subject.errors, subject[:errors])
      end

      describe 'when strings as keys' do
        subject { form_spec.parse('delay' => '5') }

        it 'parses given data' do
          assert_equal '5', subject['delay']
          assert_equal '5', subject[:delay]
          assert_equal 5, subject.data['delay']

          assert_equal({ 'delay' => '5' }, subject[])
        end
      end

      describe 'when empty strings' do
        subject { form_spec.parse(:delay => '') }

        it 'parses' do
          assert_nil subject.delay

          assert_nil subject.data[:delay]

          assert subject.valid?
        end
      end

      describe 'with non parseable data' do
        subject { form_spec.parse(:delay => 'FIVE') }

        it 'sets corresponding data as nil' do
          assert_nil subject.delay

          assert_equal 'FIVE', subject[:delay]

          refute subject.valid?
          refute subject[:valid?]

          assert_includes subject[:errors], :delay
          assert_equal(subject.errors, subject[:errors])
        end

        describe 'an error' do
          let(:error) { subject[:errors].values.first }

          let(:converter_exception) do
            begin
              converter.parse('FIVE')
            rescue
              e = $!
            end

            e
          end

          it 'provides a key' do
            assert_equal error.key, converter_exception.class.name
          end

          it 'provides a message' do
            assert_equal error.message, converter_exception.message
          end
        end
      end

      describe 'with unexpected data' do
        subject { form_spec.parse(:position => 'north') }

        it 'does not have a getter for the received param' do
          assert_raises(NoMethodError) {
            subject.position
          }
        end

        it 'parses' do
          refute_includes subject.data, :position

          assert_equal 'north', subject[:position]

          assert_equal 'north', subject[][:position]

          assert subject.valid?
        end
      end

      describe 'when a field is declared as blanks_as_nil = true' do
        let(:converter) { Foraneus::Converters::String.new(:blanks_as_nil => true) }

        subject { form_spec.parse(:delay => '') }

        it 'parses' do
          assert_nil subject.delay

          assert_equal({ :delay => nil }, subject.data)
          assert_equal '', subject[:delay]
          assert_equal({ :delay => '' }, subject[])
        end
      end

      describe 'when a field is declared as blanks_as_nil = false' do
        let(:converter) { Foraneus::Converters::String.new(:blanks_as_nil => false) }

        subject { form_spec.parse(:delay => '') }

        it 'parses' do
          assert_equal '', subject.delay
          assert_equal '', subject.data[:delay]
        end
      end

      an_absent_parameters_value_handler = ->(missing_value) do
        subject { form_spec.parse(:delay => missing_value) }

        it 'parses' do
          assert subject.valid?

          assert_nil subject.delay

          assert_equal missing_value, subject[:delay]
          assert_equal missing_value, subject[][:delay]
        end

        describe 'when required field' do
          let(:converter) { Foraneus::Converters::Integer.new(:required => true) }

          it 'parses' do
            refute subject.valid?

            assert_nil subject.delay

            refute_includes subject.data, :delay

            assert_equal missing_value, subject[][:delay]

            assert_includes subject[:errors], :delay
            assert_equal(subject.errors, subject[:errors])
          end

          describe 'an error' do
            let(:error) { subject[:errors].values.first }

            it 'has key = KeyError' do
              assert_equal 'KeyError', error.key
            end
          end
        end
      end

      describe 'with nil values' do
        instance_exec(nil, &an_absent_parameters_value_handler)
      end

      describe 'with empty values' do
        instance_exec('', &an_absent_parameters_value_handler)
      end

      describe 'when required field' do
        let(:converter) { Foraneus::Converters::Integer.new(:required => true) }

        describe 'when missing input parameter' do
          subject { form_spec.parse }

          it 'parses' do
            refute subject.valid?

            assert_nil subject.delay
            assert_nil subject[:delay]
          end
        end
      end

      describe 'when default value' do
        let(:converter) { Foraneus::Converters::Integer.new(:default => 1) }

        subject { form_spec.parse }

        it 'parses' do
          assert subject.valid?

          assert_equal 1, subject.delay

          assert_equal 1, subject.data[:delay]

          assert_nil subject[:delay]

          assert_nil subject[][:delay]

          refute subject[:errors].include?(:delay)
        end

        describe 'when missing required field' do
          let(:converter) { Foraneus::Converters::Integer.new(:default => 1, :required => true) }

          subject { form_spec.parse }

          it 'parses' do
            refute subject.valid?

            assert_nil subject.delay

            assert_nil subject[:delay]
          end
        end
      end
    end
  end

  describe '.raw' do
    subject { form_spec.raw(:delay => 5) }

    it 'parses' do
      assert_equal 5, subject.data[:delay]

      assert_equal 5, subject.delay

      assert_equal '5', subject[:delay]

      assert_equal '5', subject[][:delay]

      assert subject.valid?
      assert subject[:valid?]

      assert_empty subject[:errors]
      assert_equal(subject.errors, subject[:errors])
    end

    describe 'when strings as keys' do
      subject { form_spec.raw('delay' => 5) }

      it 'parses' do
        assert_equal 5, subject.data['delay']

        assert_equal '5', subject['delay']

        assert_equal '5', subject[:delay]

        assert_equal '5', subject[]['delay']

        assert subject.valid?

        assert_empty subject[:errors]
      end
    end

    describe 'with nil values' do
      subject { form_spec.raw('delay' => nil) }

      it 'parses' do
        assert_nil subject.data['delay']

        assert_nil subject['delay']

        assert_nil subject[:delay]

        assert_nil subject[]['delay']
      end
    end

    describe 'when default value' do
      let(:converter) { Foraneus::Converters::Integer.new(:default => 1) }

      subject { form_spec.raw }

      it 'parses' do
        assert_nil subject.delay

        assert_equal '1', subject[:delay]
        assert_equal '1', subject[][:delay]
      end
    end
  end

end
