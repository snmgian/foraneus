require 'spec_helper'

describe Foraneus::Base do

  let(:form_class) do
    Class.new(Foraneus::Base) do
      include Foraneus::ArrayXForm

      float :cost
      float :duration
    end
  end

  let(:invalid_form_class) do
    Class.new(form_class) do
      include Foraneus::InvalidXForm
    end
  end

  let(:invalid_form) do
    invalid_form_class.new
  end

  let(:cost) { Math::PI }
  let(:invalid_raw_cost) { 'invalid' }
  let(:raw_cost) { cost.to_s }

  it "should define a form class" do
    form_class.should be
  end

  describe '.build' do

    context 'when valid' do
      it "returns a form instance" do
        form_class.build.should be_instance_of(form_class)
      end

      it "holds the parsed form param" do
        form = form_class.build(:cost => raw_cost)

        p form
        form.cost.should == cost
      end

      it "holds nil for not given params" do
        form = form_class.build

        form.cost.should be_nil
      end
    end

    context 'when invalid' do

      it "returns a subclass of the form" do
        form = form_class.build(:cost => invalid_raw_cost)

        form.should be_a_kind_of(form_class)
      end

      it "returns a kind of InvalidXForm" do
        form = form_class.build(:cost => invalid_raw_cost)

        form.should be_a_kind_of(Foraneus::InvalidXForm)
      end

      it "returns a kind of RawXForm" do
        form = form_class.build(:cost => invalid_raw_cost)

        form.should be_a_kind_of(Foraneus::RawXForm)
      end

      it "holds the invalid cost" do
        form = form_class.build(:cost => invalid_raw_cost)

        form.cost.should be(invalid_raw_cost)
      end

      it "holds nil for not given params" do
        form = form_class.build(:cost => invalid_raw_cost)

        form.duration.should be_nil
      end
    end
  end

  describe '.build!' do
    let(:params) { Hash.new }

    it "invokes .build" do
      form_class.should_receive(:build).with(params)

      form_class.build!(params)
    end

    context 'when valid' do
      it "returns the result of build" do
        form_class.stub(:build).and_return(:form)

        form = form_class.build!

        form.should == :form
      end
    end

    context 'when invalid' do
      before(:each) do
        form_class.stub(:build).and_return(invalid_form)
      end

      it "raises a FormError" do
        expect {
          form_class.build!
        }.to raise_error(Foraneus::FormError)
      end

      describe 'raised error' do
        it "invalid_form attr it's the same as the result of .build" do
          error = nil
          begin
            form_class.build!
          rescue StandardError => e
            error = e
          end

          error.invalid_form.should == invalid_form
        end
      end
    end
  end

  describe '[:valid?]' do
    context 'when valid' do
      let(:form) {form_class.build(:cost => raw_cost)}

      it "is true when valid params" do
        form[:valid?].should be_true
      end

      it "is true when no params" do
        form[:valid?].should be_true
      end
    end

    context 'when invalid' do
      let(:form) {form_class.build(:cost => invalid_raw_cost)}

      it "is false when invalid params" do
        form[:valid?].should == false
      end
    end
  end

  describe '[:errors]' do
    context 'when valid' do
      let(:form) {form_class.build(:cost => raw_cost)}

      it "is empty" do
        form[:errors].should be_empty
      end
    end

    context 'when invalid' do
      let(:form) {form_class.build(:cost => invalid_raw_cost)}

      it "is not empty" do
        form[:errors].should_not be_empty
      end

      it "includes an error for cost attribute" do
        form[:errors].should include(:cost)
      end

      describe 'each error' do
        subject { form[:errors][:cost] }

        its(:field_name) { should == :cost }
        its(:field_value) { should == invalid_raw_cost }
        its(:expected_type) { should == :float }
      end
    end
  end

  describe '[:raw_values]' do
    it "holds the raw cost value" do
      form = form_class.build(:cost => raw_cost)

      form[:raw_values][:cost].should == raw_cost
    end
  end

  describe '.float' do # TODO find sth better, like: describe a type definition method
    it "creates a reader method" do
      form_class = Class.new(Foraneus::Base) do

        float :cost
      end

      form_class.instance_methods.should include(:cost)
    end
  end

  describe '[:as_hash]' do
    context 'when valid' do
      let(:form) { form_class.build(:cost => raw_cost) }

      it "is a hash" do
        form[:as_hash].should be_instance_of(Hash)
      end

      it "holds the parsed param" do
        hash = form[:as_hash]

        hash[:cost].should == cost
      end
    end

    context 'when invalid' do
      let(:form) { form_class.build(:cost => invalid_raw_cost) }

      it "is nil" do
        hash = form[:as_hash]

        hash.should be_nil
      end
    end
  end

  describe 'unknown array key' do
    let(:unknown) { :unknown }
    context 'when valid' do
      let(:form) { form_class.build(:cost => raw_cost) }

      it 'is nil' do
        form[unknown].should be_nil
      end
    end

    context 'when invalid' do
      let(:form) { form_class.build(:cost => invalid_raw_cost) }

      it 'is nil' do
        form[unknown].should be_nil
      end
    end
  end

  describe '.raw' do
    context 'with form' do
      let(:form) { form_class.build }

      it "returns a kind of RawXForm" do
        raw_form = form_class.raw(form)

        raw_form.should be_a_kind_of(Foraneus::RawXForm)
      end

      it "returns a kind of form's class" do
        raw_form = form_class.raw(form)

        raw_form.should be_a_kind_of(form_class)
      end

      it "holds raw values" do
        form = form_class.build(:cost => raw_cost)
        raw_form = form_class.raw(form)

        raw_form.cost.should == raw_cost
      end

      it "holds nil for a not given param" do
        form = form_class.build(:cost => raw_cost)
        raw_form = form_class.raw(form)

        raw_form.duration.should be_nil
      end
    end

    context 'with params' do
      let(:params) { {:cost => raw_cost} }

      it "returns a kind of RawXForm" do
        raw_form = form_class.raw(params)

        raw_form.should be_a_kind_of(Foraneus::RawXForm)
      end

      it "returns a kind of form's class" do
        raw_form = form_class.raw(params)

        raw_form.should be_a_kind_of(form_class)
      end

      it "holds raw values" do
        raw_form = form_class.raw(params)

        raw_form.cost.should == raw_cost
      end

      it "holds nil for a not given param" do
        raw_form = form_class.raw(params)

        raw_form.duration.should be_nil
      end
    end

    context 'without form nor params' do
      it "returns nil" do
        form_class.raw(nil).should be_nil
      end
    end
  end
end
