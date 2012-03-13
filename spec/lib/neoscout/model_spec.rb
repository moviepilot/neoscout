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

  describe Scout do

    before(:each) do
      @it = Scout.new
    end

    it 'initialize verifier default value' do
      @it.verifier.should_not be nil?
    end

    it 'initialize iterator default value' do
      @it.iterator.should_not be nil?
    end

    it 'initialize typer default value' do
      @it.typer.should_not be nil?
    end

  end

end