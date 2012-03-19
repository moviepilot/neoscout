module NeoScout

  class Counter

    def to_json
      [ num_failed, num_total ]
    end

  end


  # TODO indexes
  # TODO edges
  # TODO testing

  class Verifier

    def init_from_json(json)
      JSON.cd(json, %w(nodes)).each_pair do |type_name, type_json|
        JSON.cd(type_json, %w(properties)).each_pair do |prop_name, prop_json|
          prop_constr = new_node_prop_constr name: prop_name, opt: !prop_json['relevant']
          prop_set    = self.node_props[type_name]
          prop_set << prop_constr
        end
      end

      JSON.cd(json, %w(connections)).each_pair do |type_name, type_json|
        JSON.cd(type_json, %w(properties)).each_pair do |prop_name, prop_json|
          prop_constr = new_edge_prop_constr name: prop_name, opt: !prop_json['relevant']
          prop_set    = self.edge_props[type_name]
          prop_set << prop_constr
        end

        sources_json = if type_json.has_key?('sources') then type_json['sources'] else [] end
        targets_json = if type_json.has_key?('targets') then type_json['targets'] else [] end
        add_valid_edge_sets type_name, sources_json, targets_json
      end
    end

  end


  class HashWithDefault

    def to_json
      self.map_value { |v| v.to_json }
    end
  end

  #noinspection RubyTooManyInstanceVariablesInspection
  class Counts

    def add_to_json(json)
      all_json = JSON.cd json, %w(all)
      all_json['node_counts'] = @all_nodes.to_json
      all_json['connection_counts'] = @all_edges.to_json

      nodes_json = JSON.cd(json, %w(nodes))
      @typed_nodes.each_pair do |type, count|
        skip = skip_from_json(:node, type, count)
        JSON.cd(nodes_json, [type])['counts'] = count.to_json unless skip
      end

      nodes_json = JSON.cd(json, %w(nodes))
      @typed_node_props.each_pair do |type, props|
        props.each_pair do |name, count|
          skip = skip_from_json(:node, type, count)
          JSON.cd(nodes_json, [type, 'properties', name])['counts'] = count.to_json unless skip
        end
      end

      edges_json = JSON.cd(json, %w(connections))
      @typed_edges.each_pair do |type, count|
        skip = skip_from_json(:edge, type, count)
        JSON.cd(edges_json, [type])['counts'] = count.to_json unless skip
      end

      edges_json = JSON.cd(json, %w(connections))
      @typed_edge_props.each_pair do |type, props|
        props.each_pair do |name, count|
          skip = skip_from_json(:edge, type, count)
          JSON.cd(edges_json, [type, 'properties', name])['counts'] = count.to_json unless skip
        end
      end

      add_link_stats_to_json(json)
    end

    def skip_from_json(kind, type, count)
      false unless count.empty?
      case kind
        when :node
          @typer.unknown_node_type?(type)
        when :edge
          @typer.unknown_edge_type?(type)
        else
          raise ArgumentError
      end
    end

    protected

    def add_link_stats_to_json(json)
      nodes_json = JSON.cd(json, %w(nodes))

      @node_link_src_stats.each_pair do |type, hash|
        JSON.cd(nodes_json, [type])['src_stats'] = hash.to_json
      end

      @node_link_dst_stats.each_pair do |type, hash|
        JSON.cd(nodes_json, [type])['dst_stats'] = hash.to_json
      end

      edges_json = JSON.cd(json, %w(connections))
      @edge_link_src_stats.each_pair do |type, hash|
        JSON.cd(edges_json, [type])['src_stats'] = hash.to_json
      end

      @edge_link_dst_stats.each_pair do |type, hash|
        JSON.cd(edges_json, [type])['dst_stats'] = hash.to_json
      end
    end

  end
end
