module NeoScout

  class Scout
    attr_reader :typer, :verfier, :iterator

    def initialize(args)
      @typer    = args[:typer]
      @verifier = args[:verifier]
      @iterator = args[:iterator]
    end


    def count_nodes(args)
      counts = args[:counts]
      @iterator.iter_nodes(args) do |node|
        node_type = @typer.node_type(node)
        node_ok   = process_node(counts, node_type, node)
        counts.count_node(type, node_ok)
      end
      counts
    end

    def count_edges(args)
      counts = args[:counts]
      @iterator.iter_edges(args) do |edge|
        edge_type = @typer.edge_type(edge)
        edge_ok   = process_edge(counts, edge_type, edge)
        counts.count_edge(type, edge_ok)
      end
      counts
    end

    protected

    def process_node(counts, node_type, node)
      node_ok = true

      @verifier.node_props[node_type].each do |constr|
        prop_ok   = constr.satisfied_by?(node)
        counts.count_node_prop(type, constr.name, prop_ok)
        node_ok &&= prop_ok
      end

      node_ok
    end

    def process_edge(counts, edge_type, edge)
      edge_ok = true

      @verifier.edge_props[edge_type].each do |constr|
        prop_ok   = constr.satisfied_by?(edge)
        counts.count_edge_prop(type, constr.name, prop_ok)
        edge_ok &&= prop_ok
      end

      edge_ok
    end
  end

end
