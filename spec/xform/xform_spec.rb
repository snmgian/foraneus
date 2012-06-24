require 'spec_helper'

describe XForm do
  it "should define a form class" do
    form_class = Class.new do
      extend XForm
      include ArrayXForm

      float :cost
    end

    form_class.should be
  end

  describe '.build' do
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    context 'valid' do
      it "returns a form instance" do
        form_class.build.should be_instance_of(form_class)
      end

      it "holds the form param" do
        form = form_class.build(:cost => Math::PI)

        form.cost.should be(Math::PI)
      end
    end

    context 'invalid' do
      let(:cost) { 'A' }

      it "returns a subclass of the form" do
        form = form_class.build(:cost => cost)

        form.should be_a_kind_of(form_class)
      end

      it "returns a kind of InvalidXForm" do
        form = form_class.build(:cost => cost)

        form.should be_a_kind_of(InvalidXForm)
      end

      it "returns a kind of RawXForm" do
        form = form_class.build(:cost => cost)

        form.should be_a_kind_of(RawXForm)
      end

      it "holds the invalid cost" do
        form = form_class.build(:cost => cost)

        form.cost.should be(cost)
      end
    end
  end

  describe '.build!' do
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    let(:params) { Hash.new }

    it "invokes .build" do
      form_class.should_receive(:build).with(params)

      form_class.build!(params)
    end

    context 'valid' do
      it "returns the result of build" do
        form_class.stub(:build).and_return(:form)

        form = form_class.build!

        form.should == :form
      end
    end

    context 'invalid' do
      let(:invalid_form) do
        klass = Class.new(form_class) do
          include InvalidXForm
        end

        klass.new
      end

      before(:each) do
        form_class.stub(:build).and_return(invalid_form)
      end

      it "raises a FormError" do
        expect {
          form_class.build!
        }.to raise_error(FormError)
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
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    context 'valid' do
      let(:form) {form_class.build(:cost => Math::PI)}

      it "is true" do
        form[:valid?].should be_true
      end
    end

    context 'invalid' do
      let(:form) {form_class.build(:cost => :c)}

      it "is false" do
        form[:valid?].should == false
      end
    end
  end

  describe '[:errors]' do
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    context 'valid' do
      let(:form) {form_class.build(:cost => Math::PI)}

      it "is empty" do
        form[:errors].should be_empty
      end
    end

    context 'invalid' do
      let(:form) {form_class.build(:cost => :c)}

      it "is not empty" do
        form[:errors].should_not be_empty
      end

      it "includes an error for cost attribute" do
        form[:errors].should include(:cost)
      end

      describe 'each error' do
        subject { form[:errors][:cost] }

        its(:field_name) { should == :cost }
        its(:field_value) { should == :c }
        its(:expected_type) { should == :float }
      end
    end
  end

  describe '[:raw_values]' do
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    context 'when valid' do
      let(:raw_cost) { "invalid" }

      it "holds the raw cost value" do
        form = form_class.build(:cost => raw_cost)

        form[:raw_values][:cost].should == raw_cost
      end
    end

    context 'when valid' do
      let(:raw_cost) { "3.14" }
      it "holds the raw cost value" do
        form = form_class.build(:cost => raw_cost)

        form[:raw_values][:cost].should == raw_cost
      end
    end
  end

  describe '.float' do # TODO find sth better, like: describe a type definition method
    it "creates a reader method" do
      form_class = Class.new do
        extend XForm

        float :cost
      end

      form_class.instance_methods.should include(:cost)
    end
  end

  describe '.raw' do
    let(:form_class) do
      Class.new do
        extend XForm
        include ArrayXForm

        float :cost
      end
    end

    context 'with form' do
      let(:form) { form_class.build }

      it "returns a kind of RawXForm" do
        raw_form = form_class.raw(form)

        raw_form.should be_a_kind_of(RawXForm)
      end

      it "returns a kind of form's class" do
        raw_form = form_class.raw(form)

        raw_form.should be_a_kind_of(form_class)
      end

      it "holds raw values" do
        raw_cost = "3.14"
        form = form_class.build(:cost => raw_cost)
        raw_form = form_class.raw(form)

        raw_form.cost.should == raw_cost
      end
    end
  end
end
