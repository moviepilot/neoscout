module NeoScout

  class Counter

    def to_json
      [ num_ok, num_failed, num_total ]
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

      JSON.cd(json, %w(edges)).each_pair do |type_name, type_json|
        JSON.cd(type_json, %w(properties)).each_pair do |prop_name, prop_json|
          prop_constr = new_edge_prop_constr name: prop_name, opt: !prop_json['relevant']
          prop_set    = self.edge_props[type_name]
          prop_set << prop_constr
        end
      end
    end

  end


  class Counts

    def add_to_json(json)
      all_json = JSON.cd json, %w(all)
      all_json['node_counts'] = @all_nodes.to_json
      all_json['edge_counts'] = @all_edges.to_json

      nodes_json = JSON.cd(json, %w(nodes))
      @typed_nodes.each_pair do |type, count|
        JSON.cd(nodes_json, [type])['counts'] = count.to_json
      end

      nodes_json = JSON.cd(json, %w(nodes))
      @typed_node_props.each_pair do |type, props|
        props.each_pair do |name, count|
          JSON.cd(nodes_json, [type, 'properties', name])['counts'] = count.to_json
        end
      end

      edges_json = JSON.cd(json, %w(edges))
      @typed_edges.each_pair do |type, count|
        JSON.cd(edges_json, [type])['counts'] = count.to_json
      end

      edges_json = JSON.cd(json, %w(edges))
      @typed_edge_props.each_pair do |type, props|
        props.each_pair do |name, count|
          JSON.cd(edges_json, [type, 'properties', name])['counts'] = count.to_json
        end
      end
    end

  end
end
