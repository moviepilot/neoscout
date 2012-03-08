require 'spec/spec_helper'
require 'neoscout/neoscout'

module NeoScout

  describe Counter do

    it 'initializes correctly' do
      @it = Counter.new
      @it.num_ok.should be == 0
      @it.num_failed.should be == 0
      @it.num_total.should be == 0
    end

    it 'counts correctly' do
      @it = Counter.new
      @it.incr_ok
      @it.incr_ok
      @it.incr_ok
      @it.incr_failed
      @it.num_ok.should be == 3
      @it.num_failed.should be == 1
      @it.num_total.should be == 4
    end

    it 'resets correctly' do
      @it = Counter.new
      @it.incr_ok
      @it.incr_ok
      @it.incr_ok
      @it.incr_failed
      @it.reset
      @it.num_ok.should be == 0
      @it.num_failed.should be == 0
      @it.num_total.should be == 0
    end
  end

  describe HashWithDefault do
    it 'computes a default value again and again' do
      count   = 0
      default = lambda { |key| count += 1 }
      @it     = HashWithDefault.new &default
      [ @it.default(nil), @it.default(:y), @it[0] ].should be == [ 1, 2, 3 ]
    end

    it 'adds a utility method to the Hash class' do
      Hash.new_with_default { |key| 1 }.class.should be == HashWithDefault
    end
  end

end