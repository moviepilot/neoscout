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

  end
end
