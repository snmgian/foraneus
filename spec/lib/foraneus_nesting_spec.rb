require 'spec_helper'

describe Foraneus do

  let(:converter) { Foraneus::Converters::Integer.new }

  let(:form_spec) {
    c = converter
    Class.new(Foraneus) do
      string :email

      form :coords do
        field :x, c
        integer :y
      end
    end
  }

  describe '.parse' do
    describe 'with parseable data' do
      subject { form_spec.parse(:email => 'mail@example.org', :coords => { :x => '1', :y => '2' }) }

      it 'parses the nested form' do
        assert_equal 'mail@example.org', subject.email

        assert_equal 1, subject.coords.x
        assert_equal 2, subject.coords.y

        assert_equal '1', subject.coords[:x]
        assert_equal '2', subject.coords[:y]

        assert_equal({ :x => 1, :y => 2 }, subject.coords.data)

        assert_equal({ :x => '1', :y => '2' }, subject.coords[])

        assert subject.coords.valid?

        assert_empty subject.coords.errors
      end

      it 'treats the field as a regular one from the point of view of the parent form' do
        assert_equal({ :email => 'mail@example.org', :coords => { :x => 1, :y => 2 } }, subject.data)

        assert_equal({ :x => '1', :y => '2' }, subject[:coords])
        assert_equal({ :email => 'mail@example.org', :coords => { :x => '1', :y => '2' } }, subject[])

        assert subject.valid?

        assert_empty subject.errors
      end
    end

    describe 'with absent data' do
      subject { form_spec.parse }

      it 'parses' do
        assert_nil subject.coords

        refute_includes subject.data, :coords
        refute_includes subject[], :coords
      end
    end

    describe 'with nil data' do
      subject { form_spec.parse(:coords => nil) }

      it 'parses' do
        assert_nil subject.coords

        assert_equal({ :coords => nil }, subject.data)
        assert_equal({ :coords => nil }, subject[])
      end
    end

    describe 'with empty data' do
      subject { form_spec.parse(:coords => {}) }

      it 'parses' do
        assert_nil subject.coords.x
        assert_nil subject.coords.y

        assert_empty subject.coords.data
        assert_empty subject.coords[]

        assert_equal({ :coords => {} }, subject.data)
        assert_equal({ :coords => {} }, subject[])
      end
    end


    describe 'with unparseable nested data' do
      subject { form_spec.parse(:coords => { :x => 'FIVE' }) }

      it 'parses' do
        assert_nil subject.coords.x

        assert_equal 'FIVE', subject.coords[:x]
        assert_equal({ :x => 'FIVE' }, subject.coords[])


        refute subject.coords.valid?
        assert_includes subject.coords.errors, :x
      end

      describe 'an error' do
        let(:error) { subject.coords.errors.values.first }

        let(:converter_exception) do
          begin
            converter.parse('FIVE')
          rescue
            e = $!
          end

          e
        end

        it 'provides a key' do
          assert_equal converter_exception.class.name, error.key
        end

        it 'provides a message' do
          assert_equal converter_exception.message, error.message
        end
      end

      describe 'the parent form' do
        it 'is marked as invalid with errors' do
          refute subject.valid?

          assert_includes subject.errors, :coords
        end

        describe 'the error' do
          let(:error) { subject.errors[:coords] }

          it 'provides a key' do
            assert_equal 'NestedFormError', error.key
          end

          it 'provides a message' do
            assert_equal 'Invalid nested form: coords', error.message
          end
        end
      end
    end

    describe 'with non enclosing parseable data' do
      subject { form_spec.parse(:coords => 'FIVE,SIX') }

      it 'parses' do
        assert_nil subject.coords

        refute subject.valid?
      end

      describe 'the error' do
        let(:error) { subject.errors[:coords] }

        it 'provides a key' do
          assert_equal 'NestedFormError', error.key
        end

        it 'provides a message' do
          assert_equal 'Invalid nested form: coords', error.message
        end
      end
    end
  end

  describe '.raw' do
    subject { form_spec.raw(:email => 'mail@example.org', :coords => { :x => 1, :y => 2 }) }

    it 'parses' do
      assert_equal 1, subject.coords.x
      assert_equal 2, subject.coords.y

      assert_equal({ :x => 1, :y => 2 }, subject.coords.data)

      assert_equal '1', subject.coords[:x]
      assert_equal '2', subject.coords[:y]

      assert_equal({ :x => '1', :y => '2' }, subject.coords[])
    end

    describe 'parent form' do
      it 'parses' do
        assert_equal({:email => 'mail@example.org', :coords => {:x => 1, :y => 2}}, subject.data)

        assert_equal({ :email => 'mail@example.org', :coords => { :x => '1', :y => '2' } }, subject[])
      end
    end

    describe 'with absent data' do
      subject { form_spec.raw }

      it 'parses' do
        assert_nil subject.coords

        assert_empty subject.data
        assert_empty subject[]
      end
    end

    describe 'with nil data' do
      subject { form_spec.raw(:coords => nil) }

      it 'parses' do
        assert_nil subject.coords

        assert_equal({ :coords => nil }, subject.data)
        assert_equal({ :coords => nil }, subject[])
      end
    end

    describe 'with empty data' do
      subject { form_spec.parse(:coords => {}) }

      it 'parses' do
        assert_nil subject.coords.x
        assert_nil subject.coords.y

        assert_empty subject.coords.data
        assert_empty subject.coords[]

        assert_equal({ :coords => {} }, subject.data)
        assert_equal({ :coords => {} }, subject[])
      end
    end

  end

    #describe 'when nested data is nil' do
      #subject { form_spec.raw(:address => nil) }

      #it 'parses' do
        #assert_nil subject.address

        #assert_nil subject.data[:address]
        #assert_nil subject[:address]
        #assert_nil subject[][:address]
      #end
    #end

    #describe 'when nested data is empty' do
      #subject { form_spec.raw(:address => {}) }

      #it 'parses' do
        #assert_nil subject.address.data[:number]
        #assert_nil subject.address.number

        #assert_nil subject.address[:number]
        #assert_nil subject.address[][:number]
      #end
    #end
  #end

end
