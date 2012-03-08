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
      @iterator.iter_nodes(args) { |node| count_node(counts, node) }
      counts
    end

    def count_edges(args)
      counts = args[:counts]
      @iterator.iter_edges(args) { |edge| count_edge(counts, edge) }
      counts
    end

    protected

    def count_node(counts, node)
      node_ok   = true
      node_type = @typer.node_type(node)

      node_constrs_count         = counts.node_constrs
      node_constrs_by_type_count = counts.node_constrs_by_type[node_type]

      @verifier.node_constrs[node_type].each do |c|
        c_ok     = c.complying?(node)
        node_ok &= c_ok

        node_constrs_count[c].incr(c_ok)
        node_constrs_by_type_count[c].incr(c_ok)
      end

      counts.all_nodes.incr(node_ok)
      counts.nodes_by_type[node_type].incr(node_ok)
    end

    def count_edge(counts, edge)
      edge_ok   = true
      edge_type = @typer.edge_type(edge)

      edge_constrs_count         = counts.edge_constrs
      edge_constrs_by_type_count = counts.edge_constrs_by_type[edge_type]

      @verifier.edge_constrs[edge_type].each do |c|
        c_ok     = c.complying?(edge)
        edge_ok &= c_ok

        edge_constrs_count[c].incr(c_ok)
        edge_constrs_by_type_count[c].incr(c_ok)
      end

      counts.all_edges.incr(edge_ok)
      counts.edges_by_type[edge_type].incr(edge_ok)
    end
  end

end
