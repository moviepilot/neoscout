require 'spec/spec_helper'
require 'neoscout'

require 'fileutils'

module NeoScout
  module GDB_Neo4j

    describe Constraints do

      it "should render constraints properly to_s" do
        @it = ::NeoScout::GDB_Neo4j::Scout.new
        (@it.verifier.new_node_prop_constr name: 'foo').to_s.should be == "foo"
      end

    end

    describe Scout do

      def load_schema
        ::JSON.parse(::IO.read('spec/lib/neoscout/gdb_neo4j_spec_schema.json'))
      end

      def load_counts
        ::JSON.parse(::IO.read('spec/lib/neoscout/gdb_neo4j_spec_counts.json'))
      end

      before(:each) do
        @schema_json   = load_schema
        @schema_counts = load_counts

        ::Neo4j::Transaction.run do
          @user_a = ::Neo4j::Node.new type: 'users', name: 'Alfons'
          @user_b = ::Neo4j::Node.new type: 'users', name: 'Bernhard', age: '33'
          @user_c = ::Neo4j::Node.new type: 'users', name: 'Claudio'
          @user_d = ::Neo4j::Node.new type: 'users', name: 'Diderot'
          @user_e = ::Neo4j::Node.new type: 'users', name: 'Ephraim'
          @user_f = ::Neo4j::Node.new type: 'users', name: 'Francois'
          @user_g = ::Neo4j::Node.new type: 'users'
          @user_h = ::Neo4j::Node.new type: 'users', name: 0xbaadf00d

          @challenge1 = ::Neo4j::Node.new type: 'challenges', descr: 'Eat fish on friday'

          @user_a.outgoing(:challenger) << @challenge1
          @user_b.incoming(:challengee) << @challenge1
          @rel0 = ::Neo4j::Relationship.new(:fugleman, @challenge1, @user_a)
          @rel0['accepted'] = true
          @rel1 = ::Neo4j::Relationship.new(:fugleman, @challenge1, @user_b)
          @user_e.outgoing(:spectator) << @challenge1
          @user_e.outgoing(:spectator) << @user_g
        end

        @storage_path = ::Neo4j.db.storage_path
        puts "Initialized at '#{@storage_path}'..."
      end

      after(:each) do
        ::Neo4j.shutdown
        puts "Deleting '#{@storage_path}'..."
        FileUtils.rm_rf @storage_path unless (ENV['NEOSCOUT_KEEP_DB']=='YES')
      end

      it 'should verify properties correctly' do
        @it = ::NeoScout::GDB_Neo4j::Scout.new
        @it.typer.value_type_table['string'] = lambda { |n,v| v.kind_of? String }
        @it.verifier.init_from_json @schema_json
        @counts = @it.new_counts
        @it.count_edges counts: @counts
        @it.count_nodes counts: @counts
        @counts.add_to_json @schema_json
        puts '<<RESULT'
        puts @schema_json.to_json
        puts 'RESULT'
        @schema_json.should be == @schema_counts
      end

    end

  end
end
