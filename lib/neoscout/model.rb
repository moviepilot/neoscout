require 'set'

module NeoScout

  class ElementIterator
    def iter_nodes(args) ; raise NotImplentedError end
    def iter_edges(args) ; raise NotImplentedError end
  end

  class Typer
    def node_type(node) ; raise NotImplementedError end
    def edge_type(edge) ; raise NotImplementedError end
  end

  class Counts
    attr_reader :all_nodes
    attr_reader :all_edges

    attr_reader :typed_nodes
    attr_reader :typed_edges

    attr_reader :typed_node_props
    attr_reader :typed_edge_props

    def initialize
      reset
    end

    def reset
      @all_nodes        = Counter.new
      @all_edges        = Counter.new

      @typed_nodes      = HashWithDefault.new { |node_type| Counter.new }
      @typed_edges      = HashWithDefault.new { |edge_type| Counter.new }

      @typed_node_props = HashWithDefault.new { |node_type| HashWithDefault.new { |prop_constr| Counter.new } }
      @typed_edge_props = HashWithDefault.new { |edge_type| HashWithDefault.new { |prop_constr| Counter.new } }
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

    def to_s
      {
        'all_nodes' => @all_nodes.to_s,
        'all_edges' => @all_edges.to_s,
        'typed_nodes' => @typed_nodes.to_s,
        'typed_edges' => @typed_edges.to_s,
        'typed_node_props' => @typed_node_props.to_s,
        'typed_edge_props' => @typed_edge_props.to_s,
      }
    end

  end

  class Verifier
    attr_reader :node_props
    attr_reader :edge_props

    def initialize
      @node_props = HashWithDefault.new { |type| ConstrainedSet.new { |o| o.kind_of? Constraints::PropConstraint } }
      @edge_props = HashWithDefault.new { |type| ConstrainedSet.new { |o| o.kind_of? Constraints::PropConstraint } }
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

    def to_s
      {
          :node_props => @node_props.to_s,
          :edge_props => @edge_props.to_s
      }.to_s
    end

  end

end


