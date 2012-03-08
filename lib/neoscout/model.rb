require 'set'

module NeoScout

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

  class Verifier
    attr_reader :node_constraints, :edge_constraints

    class ConstraintStore

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

      def initialize(type)
        @type  = type
        @store = {}
      end

      def [](key)
        if @store[key] then @store[key] else @store[key] = ConstraintSet.new(@type) end
      end
    end

    def initialize
      @node_constraints = ConstraintStore.new :nodes
      @edge_constraints = ConstraintStore.new :edges
    end
  end
end