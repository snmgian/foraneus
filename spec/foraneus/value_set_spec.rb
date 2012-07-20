require 'spec_helper'

describe Foraneus::ValueSet do

  let(:vs_class) do
    Class.new(Foraneus::ValueSet) do
      include Foraneus::HashlikeValueSet

      float :cost
      float :duration
    end
  end

  let(:invalid_vs_class) do
    Class.new(vs_class) do
      include Foraneus::InvalidValueSet
    end
  end

  let(:invalid_vs) do
    invalid_vs_class.new
  end

  let(:cost) { Math::PI }
  let(:invalid_raw_cost) { 'invalid' }
  let(:raw_cost) { cost.to_s }

  it "should define a value_set class" do
    vs_class.should be
  end

  describe '.build' do

    context 'when valid' do
      it "returns a value_set instance" do
        vs_class.build.should be_instance_of(vs_class)
      end

      it "holds the parsed value_set param" do
        value_set = vs_class.build(:cost => raw_cost)

        value_set.cost.should == cost
      end

      it "holds nil for not given params" do
        value_set = vs_class.build

        value_set.cost.should be_nil
      end
    end

    context 'when invalid' do

      it "returns a subclass of the value_set" do
        value_set = vs_class.build(:cost => invalid_raw_cost)

        value_set.should be_a_kind_of(vs_class)
      end

      it "returns a kind of InvalidXForm" do
        value_set = vs_class.build(:cost => invalid_raw_cost)

        value_set.should be_a_kind_of(Foraneus::InvalidValueSet)
      end

      it "returns a kind of RawXForm" do
        value_set = vs_class.build(:cost => invalid_raw_cost)

        value_set.should be_a_kind_of(Foraneus::RawValueSet)
      end

      it "holds the invalid cost" do
        value_set = vs_class.build(:cost => invalid_raw_cost)

        value_set.cost.should be(invalid_raw_cost)
      end

      it "holds nil for not given params" do
        value_set = vs_class.build(:cost => invalid_raw_cost)

        value_set.duration.should be_nil
      end
    end

    context 'with strings' do
      it "holds the value" do
        value_set = vs_class.build('cost' => raw_cost)

        value_set.cost.should == cost
      end
    end

  end

  describe '.build!' do
    let(:params) { Hash.new }

    it "invokes .build" do
      vs_class.should_receive(:build).with(params)

      vs_class.build!(params)
    end

    context 'when valid' do
      it "returns the result of build" do
        vs_class.stub(:build).and_return(:value_set)

        value_set = vs_class.build!

        value_set.should == :value_set
      end
    end

    context 'when invalid' do
      before(:each) do
        vs_class.stub(:build).and_return(invalid_vs)
      end

      it "raises a ValueSetError" do
        expect {
          vs_class.build!
        }.to raise_error(Foraneus::ValueSetError)
      end

      describe 'raised error' do
        it "invalid_vs attr it's the same as the result of .build" do
          error = nil
          begin
            vs_class.build!
          rescue StandardError => e
            error = e
          end

          error.value_set.should == invalid_vs
        end
      end
    end
  end

  describe '[:valid?]' do
    context 'when valid' do
      let(:value_set) {vs_class.build(:cost => raw_cost)}

      it "is true when valid params" do
        value_set[:valid?].should be_true
      end

      it "is true when no params" do
        value_set[:valid?].should be_true
      end
    end

    context 'when invalid' do
      let(:value_set) {vs_class.build(:cost => invalid_raw_cost)}

      it "is false when invalid params" do
        value_set[:valid?].should == false
      end
    end
  end

  describe '[:errors]' do
    context 'when valid' do
      let(:value_set) {vs_class.build(:cost => raw_cost)}

      it "is empty" do
        value_set[:errors].should be_empty
      end
    end

    context 'when invalid' do
      let(:value_set) {vs_class.build(:cost => invalid_raw_cost)}

      it "is not empty" do
        value_set[:errors].should_not be_empty
      end

      it "includes an error for cost attribute" do
        value_set[:errors].should include(:cost)
      end

      describe 'each error' do
        subject { value_set[:errors][:cost] }

        its(:name) { should == :cost }
        its(:value) { should == invalid_raw_cost }
        its(:expected_type) { should == :float }
      end
    end
  end

  describe '[:raw_values]' do
    it "holds the raw cost value" do
      value_set = vs_class.build(:cost => raw_cost)

      value_set[:raw_values][:cost].should == raw_cost
    end

    context 'with strings' do
      it "holds the raw_value" do
        value_set = vs_class.build('cost' => raw_cost)

        value_set[:raw_values]['cost'].should == raw_cost
      end
    end
  end

  describe '.float' do # TODO find sth better, like: describe a type definition method
    it "creates a reader method" do
      vs_class = Class.new(Foraneus::ValueSet) do

        float :cost
      end

      vs_class.instance_methods.should include(:cost)
    end
  end

  describe '[:as_hash]' do
    context 'when valid' do
      let(:value_set) { vs_class.build(:cost => raw_cost) }

      it "is a hash" do
        value_set[:as_hash].should be_instance_of(Hash)
      end

      it "holds the parsed param" do
        hash = value_set[:as_hash]

        hash[:cost].should == cost
      end

      context 'with strings' do
        let(:value_set) { vs_class.build('cost' => raw_cost) }

        it "holds the parsed param" do
          hash = value_set[:as_hash]

          hash[:cost].should == cost
        end
      end
    end

    context 'when invalid' do
      let(:value_set) { vs_class.build(:cost => invalid_raw_cost) }

      it "is nil" do
        hash = value_set[:as_hash]

        hash.should be_nil
      end
    end
  end

  describe 'unknown array key' do
    let(:unknown) { :unknown }
    context 'when valid' do
      let(:value_set) { vs_class.build(:cost => raw_cost) }

      it 'is nil' do
        value_set[unknown].should be_nil
      end
    end

    context 'when invalid' do
      let(:value_set) { vs_class.build(:cost => invalid_raw_cost) }

      it 'is nil' do
        value_set[unknown].should be_nil
      end
    end
  end

  describe '.raw' do
    context 'with value_set' do
      let(:value_set) { vs_class.build }

      it "returns a kind of RawXForm" do
        raw_vs = vs_class.raw(value_set)

        raw_vs.should be_a_kind_of(Foraneus::RawValueSet)
      end

      it "returns a kind of value_set's class" do
        raw_vs = vs_class.raw(value_set)

        raw_vs.should be_a_kind_of(vs_class)
      end

      it "holds raw values" do
        value_set = vs_class.build(:cost => raw_cost)
        raw_vs = vs_class.raw(value_set)

        raw_vs.cost.should == raw_cost
      end

      it "holds nil for a not given param" do
        value_set = vs_class.build(:cost => raw_cost)
        raw_vs = vs_class.raw(value_set)

        raw_vs.duration.should be_nil
      end
    end

    context 'with params' do
      let(:params) { {:cost => raw_cost} }

      it "returns a kind of RawXForm" do
        raw_vs = vs_class.raw(params)

        raw_vs.should be_a_kind_of(Foraneus::RawValueSet)
      end

      it "returns a kind of value_set's class" do
        raw_vs = vs_class.raw(params)

        raw_vs.should be_a_kind_of(vs_class)
      end

      it "holds raw values" do
        raw_vs = vs_class.raw(params)

        raw_vs.cost.should == raw_cost
      end

      it "holds nil for a not given param" do
        raw_vs = vs_class.raw(params)

        raw_vs.duration.should be_nil
      end

      context 'with strings' do
        let(:params) { {'cost' => raw_cost} }

        it "holds raw values" do
          raw_vs = vs_class.raw(params)

          raw_vs.cost.should == raw_cost
        end
      end
    end

    context 'without value_set nor params' do
      it "returns nil" do
        vs_class.raw(nil).should be_nil
      end
    end
  end
end
