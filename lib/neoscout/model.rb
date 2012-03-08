require 'set'

module NeoScout

  class Iterator
    def iter_nodes(args)
      raise NotImplentedError
    end

    def iter_edges(args)
      raise NotImplentedError
    end
  end

  class Typer
    def node_type(node)
      raise NotImplementedError
    end

    def edge_type(edge)
      raise NotImplementedError
    end
  end

  class Counts
    attr_reader :all_nodes
    attr_reader :all_edges
    attr_reader :nodes_by_type
    attr_reader :edges_by_type
    attr_reader :node_constrs
    attr_reader :edge_constrs
    attr_reader :node_constrs_by_type
    attr_reader :edge_constrs_by_type

    def initialize
      reset
    end

    def reset
      @all_nodes     = Counter.new
      @all_edges     = Counter.new
      @nodes_by_type = HashWithDefault.new { |node_type| Counter.new }
      @edges_by_type = HashWithDefault.new { |edge_type| Counter.new }
      @node_constrs  = HashWithDefault.new { |node_constr| Counter.new }
      @edge_constrs  = HashWithDefault.new { |edge_constr| Counter.new }
      @node_constrs_by_type = HashWithDefault.new { |node_type| HashWithDefault.new { |node_constr| Counter.new } }
      @edge_constrs_by_type = HashWithDefault.new { |edge_type| HashWithDefault.new { |edge_constr| Counter.new } }
    end

  end

  class Verifier
    attr_reader :node_constrs, :edge_constrs

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
      @node_constrs = HashWithDefault.new { |node_type| ConstraintSet.new :nodes }
      @edge_constrs = HashWithDefault.new { |edge_type| ConstraintSet.new :edges }
    end
  end
end

