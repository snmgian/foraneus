require 'spec_helper'

describe Foraneus do

  let(:converter) { Foraneus::Converters::Integer.new }

  let(:form_spec) {
    c = converter
    Class.new(Foraneus) do
      form :address do
        string :street
        field :number, c
      end
    end
  }

  describe '.parse' do
    describe 'with parseable data' do
      subject { form_spec.parse(:address => { :street => 'Main Bv.', :number => '550' }) }

      it 'parses the nested form' do
        assert_equal 550, subject.address.number
        assert_equal 'Main Bv.', subject.address.street

        assert_equal 550, subject.address.data[:number]
        assert_equal 'Main Bv.', subject.address.data[:street]

        assert_equal({ :street => 'Main Bv.', :number => 550 }, subject.address.data)

        assert_equal '550', subject.address[:number]
        assert_equal 'Main Bv.', subject.address[:street]

        assert_equal({ :street => 'Main Bv.', :number => '550' }, subject.address[])

        assert subject.address.valid?

        assert_empty subject.address.errors
      end

      it 'treats the field as a regular one from the point of view of the parent form' do
        assert_equal({ :address => { :street => 'Main Bv.', :number => 550 } }, subject.data)

        assert_equal({ :address => { :street => 'Main Bv.', :number => '550' } }, subject[])

        assert subject.valid?

        assert_empty subject.errors
      end
    end

    describe 'with nil nested data' do
      subject { form_spec.parse(:address => nil) }

      it 'parses' do
        assert_nil subject.address.street
        assert_nil subject.address.number

        assert_equal({ :address => {} }, subject.data)

        assert_equal({ :address => nil }, subject[])
      end
    end

    describe 'with empty nested data' do
      subject { form_spec.parse(:address => {}) }

      it 'parses' do
        assert_nil subject.address.street
        assert_nil subject.address.number

        assert_equal({ :address => {} }, subject.data)

        assert_equal({ :address => {} }, subject[])
      end
    end

    describe 'with absent enclosing param' do
      subject { form_spec.parse }

      it 'parses' do
        assert_nil subject.address.street
        assert_nil subject.address.number

        assert_empty subject.data

        assert_empty subject[]
      end
    end

    describe 'with non parseable data' do
      subject { form_spec.parse(:address => { :number => 'FIVE' }) }

      it 'sets corresponding data as nil' do
        assert_nil subject.address.number

        assert_equal 'FIVE', subject.address[:number]

        refute subject.address.valid?

        assert_includes subject.address.errors, :number
      end

      describe 'an error' do
        let(:error) { subject.address.errors.values.first }

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


      #TODO test with :coords => 'INVALID' instead of a hash
      describe 'the parent form' do
        it 'is marked as invalid with errors' do
          refute subject.valid?

          assert_includes subject.errors, :address
        end

        describe 'the error' do
          let(:error) { subject.errors[:address] }

          it 'provides a key' do
            assert_equal error.key, 'InvalidNestedFormError'
          end

          it 'provides a message' do
            assert_equal error.message, 'Invalid nested form: address'
          end
        end
      end
    end
  end

  describe '.raw' do
    subject { form_spec.raw(:address => { :street => 'Main Bv.', :number => 550 }) }

    it 'parses' do
      assert_equal 550, subject.address.data[:number]
      assert_equal 550, subject.address.number

      assert_equal '550', subject.address[:number]
      assert_equal '550', subject.address[][:number]

      assert subject.address.valid?

      assert_empty subject.address.errors
    end

    describe 'parent form' do
      it 'parses' do
        assert_equal 550, subject.data[:address][:number]

        assert_equal '550', subject[:address][:number]
        assert_equal '550', subject[][:address][:number]

        assert subject.valid?

        assert_empty subject.errors
      end
    end

    describe 'when nested data is nil' do
      subject { form_spec.raw(:address => nil) }

      it 'parses' do
        assert_nil subject.address

        assert_nil subject.data[:address]
        assert_nil subject[:address]
        assert_nil subject[][:address]
      end
    end

    describe 'when nested data is empty' do
      subject { form_spec.raw(:address => {}) }

      it 'parses' do
        assert_nil subject.address.data[:number]
        assert_nil subject.address.number

        assert_nil subject.address[:number]
        assert_nil subject.address[][:number]
      end
    end
  end

end
