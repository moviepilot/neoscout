require 'spec/spec_helper'
require 'neoscout/neoscout'
require 'neoscout/json_schema'

module NeoScout

  describe ConstrainedSet do

    it 'should check arguments on initialize' do
      lambda { ConstrainedSet.new { |o| o.kind_of? Fixnum } }.should_not raise_error(ArgumentError)
      lambda { ConstrainedSet.new([1, 2]) { |o| o.kind_of? Fixnum } }.should_not raise_error(ArgumentError)
      lambda { ConstrainedSet.new([:a]) { |o| o.kind_of? Fixnum } }.should raise_error(ArgumentError)
    end

    it 'should check elements on append' do
      lambda { (ConstrainedSet.new { |o| o.kind_of? Fixnum }) << 0 }.should_not raise_error(ArgumentError)
      lambda { (ConstrainedSet.new { |o| o.kind_of? Fixnum }) << :a }.should raise_error(ArgumentError)
    end

    it 'should append' do
      c = ConstrainedSet.new { |o| true }
      c << 1
      c << 2
      c.to_a.should be == [1, 2]
    end

  end


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

    it 'is convertible to string' do
      @it = Counter.new
      @it.incr_ok
      @it.incr_ok
      @it.incr_ok
      @it.incr_failed
      @it.to_s.should be == "(3/1/4)"
    end

    it 'is convertible to json' do
      @it = Counter.new
      @it.incr_ok
      @it.incr_ok
      @it.incr_ok
      @it.incr_failed
      @it.to_json.should be == [ 3, 1, 4 ]
    end

  end


  describe HashWithDefault do
    it 'computes a default value again and again' do
      count   = 0
      default = lambda { |key| count += 1 }
      @it     = HashWithDefault.new &default
      [ @it.default(nil), @it.default(:y), @it[0] ].should be == [ 1, 2, 3 ]
    end

    it 'can lookup via lookup()' do
      @it = HashWithDefault.new { |key| 1 }
      @it[:a] = 2
      @it.lookup(:a).should be == 2
    end

    it 'can lookup without creating a default value' do
      @it = HashWithDefault.new { |key| 1 }
      @it[:a] = 2
      @it.lookup(:b).should be == nil
    end
  end


  describe JSON do

    it 'should cd into hashes' do
      @it = {}
      JSON.cd @it, [:a]
      @it.should be == { :a => {} }
    end

    it 'should cd into hashes deeply' do
      @it = {}
      JSON.cd @it, [:a, :b]
      @it.should be == { :a => { :b => {} } }
    end


    it 'should return the last hash for further writing' do
      @it = {}
      (JSON.cd @it, [:a, :b])[:c] = 3
      @it.should be == { :a => { :b => { :c => 3 } } }
    end

    it 'should not clobber unrelated hashes' do
      @it = { :x => 5 }
      (JSON.cd @it, [:a, :b])[:c] = 3
      @it.should be == { :a => { :b => { :c => 3 } }, :x => 5 }
    end

    it 'should not clobber existing hashes' do
      @it = { :a => { :y => 2 }, :x => 5 }
      (JSON.cd @it, [:a, :b])[:c] = 3
      @it.should be == { :a => { :b => { :c => 3 }, :y => 2 }, :x => 5 }
    end

  end

end