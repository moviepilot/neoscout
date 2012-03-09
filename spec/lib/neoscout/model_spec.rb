require 'spec/spec_helper'
require 'neoscout/neoscout'

module NeoScout

  describe Verifier do

    before(:each) do
      @it = Verifier.new
    end

    it 'initialize node_constraints' do
      @it.node_props[:movie].length.should be == 0
    end

    it 'initialize edge_constraints' do
      @it.edge_props[:movie].length.should be == 0
    end

    it 'should only store node_constraints in node_constraints' do
      @it.node_props[:dog] << (Constraints::PropConstraint.new name: 'dingo')
      lambda { @it.node_props[:dog] << Constraints::CardConstraint.new }.should raise_error(ArgumentError)
    end


    it 'should only store edge_constraints in edge_constraints' do
      @it.edge_props[:dog] << (Constraints::PropConstraint.new name: 'dingo')
      lambda { @it.edge_props[:dog] << Constraints::CardConstraint.new }.should raise_error(ArgumentError)
    end
  end

end