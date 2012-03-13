module NeoScout

  class Scout
    attr_reader :typer, :verifier, :iterator

    def initialize(args={})
      @typer    = args[:typer]
      @typer    = Typer.new unless @typer
      @verifier = args[:verifier]
      @verifier = Verifier.new unless @verifier
      @iterator = args[:iterator]
      @iterator = ElementIterator.new unless @iterator
    end


    def new_counts
      NeoScout::Counts.new
    end

    def count_nodes(args)
      counts = args[:counts]
      @iterator.iter_nodes(args) do |node|
        node_type = @typer.node_type(node)
        node_ok   = process_node(counts, node_type, node)
        counts.count_node(node_type, node_ok)
      end
      counts
    end

    def count_edges(args)
      counts = args[:counts]
      @iterator.iter_edges(args) do |edge|
        edge_type = @typer.edge_type(edge)
        edge_ok   = process_edge(counts, edge_type, edge)
        counts.count_edge(edge_type, edge_ok)
      end
      counts
    end

    protected

    def process_node(counts, node_type, node)
      node_ok = true

      @verifier.node_props[node_type].each do |constr|
        prop_ok   = constr.satisfied_by?(node)
        counts.count_node_prop(node_type, constr.name, prop_ok)
        node_ok &&= prop_ok
      end

      node_ok
    end

    def process_edge(counts, edge_type, edge)
      edge_ok = true

      @verifier.edge_props[edge_type].each do |constr|
        prop_ok   = constr.satisfied_by?(edge)
        counts.count_edge_prop(edge_type, constr.name, prop_ok)
        edge_ok &&= prop_ok
      end

      edge_ok
    end
  end

end
