require 'set'

module NeoScout

  class Iterator
    def for_nodes(node_type = nil)
      raise NotImplementedError
    end

    def for_edges(edge_type = nil)
      raise NotImplementedError
    end
  end

  class Typer
    def node_type(node)
      raise NotImplementedError
    end

    def edge_type(edge)
      raise NotImplementedError
    end

    def iter_node_types(*blk)
    end

    def iter_edge_types(*blk)
    end
  end

  class Counts
    attr_reader :all_nodes
    attr_reader :all_edges
    attr_reader :nodes_by_type
    attr_reader :edges_by_type
    attr_reader :node_props
    attr_reader :edge_props
    attr_reader :node_props_by_type
    attr_reader :edge_props_by_type

    def initialize
      @all_nodes     = Counter.new
      @all_edges     = Counter.new
    end
  end

  class Verifier
    attr_reader :node_constraints, :edge_constraints

    class ConstraintSet < Set
      def initialize(type)
        @type = type
        super []
      end

      def <<(o)
        raise ArgumentError unless o.is_a?(Constraints::Constraint) && o.constraints.include?(@type)
        super(o)
      end
    end

    def initialize
      @node_constraints = HashWithDefault.new { |key| ConstraintSet.new :nodes }
      @edge_constraints = HashWithDefault.new { |key| ConstraintSet.new :edges }
    end
  end
end

