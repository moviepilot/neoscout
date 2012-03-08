require 'spec/spec_helper'
require 'neoscout/neoscout'

module NeoScout

  describe Verifier do

    before(:each) do
      @it = Verifier.new
    end

    it 'initialize node_constraints' do
      @it.node_constraints[:movie].length.should be == 0
    end

    it 'initialize edge_constraints' do
      @it.node_constraints[:movie].length.should be == 0
    end

    it 'should only store node_constraints in node_constraints' do
      @it.node_constraints[:dog] << (Constraints::PropConstraint.new name: 'dingo')
      lambda { @it.node_constraints[:dog] << Constraints::CardConstraint.new }.should raise_error(ArgumentError)
    end


    it 'should only store edge_constraints in edge_constraints' do
      lambda {
        @it.edge_constraints[:dog] << (Constraints::PropConstraint.new name: 'dingo')
        @it.edge_constraints[:dog] << Constraints::CardConstraint.new
      }.should_not raise_error(ArgumentError)
    end
  end

end