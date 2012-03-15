require 'set'

module NeoScout

  class ElementIterator
    def iter_nodes(args) ; raise NotImplentedError end
    def iter_edges(args) ; raise NotImplentedError end
  end

  class Typer
    def node_type(node) ; raise NotImplementedError end
    def edge_type(edge) ; raise NotImplementedError end

    def checked_node_type?(node_type) ; raise NotImplementedError end
    def checked_edge_type?(edge_type) ; raise NotImplementedError end

    def valid_value?(value_type, value) ; true end
  end

  module TyperValueTableMixin
    def valid_value?(value_type, value)
      if (entry = self.value_type_table[value_type])
        entry.call(value_type_name, value)
      else
        true
      end
    end
  end

  class Counts
    attr_reader :all_nodes
    attr_reader :all_edges

    attr_reader :typed_nodes
    attr_reader :typed_edges

    attr_reader :typed_node_props
    attr_reader :typed_edge_props

    attr_reader :node_link_src_stats
    attr_reader :node_link_dst_stats
    attr_reader :edge_link_src_stats
    attr_reader :edge_link_dst_stats

    def initialize
      reset
    end

    def reset
      @all_nodes        = Counter.new
      @all_edges        = Counter.new

      @typed_nodes      = Counter.new_multi_keyed :node_type
      @typed_edges      = Counter.new_multi_keyed :edge_type

      @typed_node_props = Counter.new_multi_keyed :node_type, :prop_constr
      @typed_edge_props = Counter.new_multi_keyed :node_type, :prop_constr

      @node_link_src_stats = Counter.new_multi_keyed :src_type, :edge_type
      @node_link_dst_stats = Counter.new_multi_keyed :dst_type, :edge_type

      @edge_link_src_stats = Counter.new_multi_keyed :edge_type, :src_type, :dst_type
      @edge_link_dst_stats = Counter.new_multi_keyed :edge_type, :dst_type, :src_type
    end

    def count_node(type, ok)
      @all_nodes.incr(ok)
      @typed_nodes[type].incr(ok)
    end

    def count_node_prop(type, prop, ok)
      @typed_node_props[type][prop].incr(ok)
    end

    def count_edge(type, ok)
      @all_edges.incr(ok)
      @typed_edges[type].incr(ok)
    end

    def count_edge_prop(type, prop, ok)
      @typed_edge_props[type][prop].incr(ok)
    end

    def count_link_stats(edge_type, src_type, dst_type, ok)
      # puts "#{src_type} -- #{edge_type} -- #{dst_type} #{if ok then "CHECK" else "FAIL" end}"
      @node_link_src_stats[src_type][edge_type].incr(ok)
      @node_link_dst_stats[dst_type][edge_type].incr(ok)
      @edge_link_src_stats[edge_type][src_type][dst_type].incr(ok)
      @edge_link_dst_stats[edge_type][dst_type][src_type].incr(ok)
    end

  end

  class Verifier
    attr_reader :node_props
    attr_reader :edge_props
    attr_reader :allowed_edges

    def initialize
      @node_props = HashWithDefault.new { |type| ConstrainedSet.new { |o| o.kind_of? Constraints::PropConstraint } }
      @edge_props = HashWithDefault.new { |type| ConstrainedSet.new { |o| o.kind_of? Constraints::PropConstraint } }
      @allowed_edges = HashWithDefault.new_multi_keyed(:edge_type, :src_type) { |v| Set.new }
    end

    def new_node_prop_constr(args={})
      Constraints::PropConstraint.new args
    end

    def new_edge_prop_constr(args={})
      Constraints::PropConstraint.new args
    end

    def new_card_constr(args={})
      Constraints::CardConstraint.new args
    end

    def add_valid_edge(edge_type, src_type, dst_type)
      @allowed_edges[edge_type][src_type] << dst_type
    end

    def add_valid_edge_sets(edge_type, src_types, dst_types)
      src_types.each do |src_type|
        dst_types.each do |dst_type|
          add_valid_edge edge_type, src_type, dst_type
        end
      end
    end

    def checked_node_type?(node_type)
      ! @node_props[node_type].empty?
    end

    def checked_edge_type?(node_type)
      ! @node_props[node_type].empty?
    end

    def allowed_edge?(edge_type, src_type, dst_type)
      allowed_edges[edge_type].empty? || allowed_edges[edge_type][src_type].member?(dst_type)
    end
  end

end


