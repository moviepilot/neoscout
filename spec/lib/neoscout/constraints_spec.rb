require 'spec/spec_helper'
require 'neoscout'

module NeoScout
  module Constraints

    describe PropConstraint do

      it 'should require names to be strings' do
        lambda { PropConstraint.new name: 1 }.should raise_error(ArgumentError)
      end

      it 'should require names to have length > 0' do
        lambda { PropConstraint.new name: '' }.should raise_error(ArgumentError)
      end

      it 'should properly implement to_str' do
        (PropConstraint.new name: 'dingo').to_s.should be == 'dingo'
        (PropConstraint.new name: 'dingo', opt: true).to_s.should be == 'dingo (opt.)'
        (PropConstraint.new name: 'dingo', opt: true, type: :int).to_s.should be == 'dingo: int (opt.)'
      end
    end

    describe CardConstraint do

      it 'should set min to 0 by default' do
        CardConstraint.new.min.should be == 0
      end

      it 'should set max to :inf by default' do
        CardConstraint.new.max.should be == :inf
      end

      it 'should set dir to :any by default' do
        CardConstraint.new.dir.should be == :any
      end

      it 'should accept :directed for dir' do
        lambda { CardConstraint.new dir: :directed }.should_not raise_error
      end

      it 'should accept :undirected for dir' do
        lambda { CardConstraint.new dir: :undirected }.should_not raise_error
      end

      it 'should not accept an unknown direction kind for dir' do
        lambda { CardConstraint.new dir: :north }.should raise_error(ArgumentError)
      end

      it 'should require max to be a fixnum or :inf' do
        lambda { CardConstraint.new min: 0, max: '' }.should raise_error(ArgumentError)
        lambda { CardConstraint.new min: 0, max: :inf }.should_not raise_error
      end

      it 'should require min to be a fixnum' do
        lambda { CardConstraint.new min: '', max: 1 }.should raise_error(ArgumentError)
      end

      it 'should properly implement to_str' do
        (CardConstraint.new src: 'src', dst: 'dst').to_s.should be == 'src:any -- (0, inf) dst'
      end
    end

  end
end
