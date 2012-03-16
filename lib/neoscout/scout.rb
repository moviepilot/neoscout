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

    def checked_node_type?(node_type)
      @typer.checked_node_type?(node_type) && @verifier.checked_node_type?(node_type)
    end

    def checked_edge_type?(edge_type)
      @typer.checked_edge_type?(edge_type) && @verifier.checked_edge_type?(edge_type)
    end


    def new_counts
      NeoScout::Counts.new
    end

    def count_nodes(args)
      counts = prep_counts(args[:counts])
      @iterator.iter_nodes(args) do |node|
        node_type = @typer.node_type(node)
        node_ok   = process_node(counts, node_type, node)
        counts.count_node(node_type, node_ok)
      end
      counts
    end

    def count_edges(args)
      counts = prep_counts(args[:counts])
      @iterator.iter_edges(args) do |edge|
        edge_type = @typer.edge_type(edge)
        edge_ok   = process_edge(counts, edge_type, edge)
        counts.count_edge(edge_type, edge_ok)
      end
      counts
    end

    def prep_counts(counts) ; counts end

    protected

    def process_node(counts, node_type, node)
      node_ok    = true

      node_props = Set.new(node.props.keys)

      node_props.delete('_neo_id')

      @verifier.node_props[node_type].each do |constr|
        prop_ok   = constr.satisfied_by_node?(typer, node)
        counts.count_node_prop(node_type, constr.name, prop_ok)
        node_props.delete(constr.name)
        node_ok &&= prop_ok
      end

      # Process remaining properties in this node as erroneously missing in the schema
      # unless the node is untyped
      node_props.each do |prop_name|
        prop_ok   = ! checked_node_type?(node_type)
        counts.count_node_prop(node_type, prop_name, prop_ok)
        node_ok &&= prop_ok
      end

      node_ok
    end

    def process_edge(counts, edge_type, edge)
      edge_props = Set.new(edge.props.keys)
      edge_props.delete('_neo_id')

      src_type = @typer.node_type(edge.getStartNode)
      dst_type = @typer.node_type(edge.getEndNode)

      edge_ok = @verifier.allowed_edge?(edge_type, src_type, dst_type)

      @verifier.edge_props[edge_type].each do |constr|
        prop_ok   = constr.satisfied_by_edge?(typer, edge)
        counts.count_edge_prop(edge_type, constr.name, prop_ok)
        edge_props.delete(constr.name)
        edge_ok &&= prop_ok
      end

      # Process remaining properties in this node as erroneously missing in the schema
      # unless the edge is untyped
      edge_props.each do |prop_name|
        prop_ok   = ! checked_edge_type?(edge_type)
        counts.count_edge_prop(edge_type, prop_name, prop_ok)
        edge_ok &&= prop_ok
      end

      # Finally count edge statistics
      counts.count_link_stats(edge_type, src_type, dst_type, edge_ok)

      edge_ok
    end

  end

end
