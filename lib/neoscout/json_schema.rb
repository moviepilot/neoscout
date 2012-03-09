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
      json['nodes'].keys.each_with_index do |type_name, type_json|
        type_json['properties'].each_with_index do |prop_name, prop_json|
          prop_constr = Constraints::PropConstraint.new name: prop_name, opt: !prop_json['relevant']
          @node_props[type_name] << prop_constr
        end
      end

      json['edges'].keys.each_with_index do |type_name, type_json|
        type_json['properties'].each_with_index do |prop_name, prop_json|
          prop_constr = Constraints::PropConstraint.new name: prop_name, opt: !prop_json['relevant']
          @edge_props[type_name] << prop_constr
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
      @typed_nodes.each_with_index do |type, count|
        JSON.cd(nodes_json, [type])['count'] = count.to_json
      end

      nodes_json = JSON.cd(json, %w(nodes))
      @typed_node_props.each_with_index do |type, props|
        props.each_with_index do |name, count|
          JSON.cd(nodes_json, [type, 'properties', name])['count'] = count.to_json
        end
      end

      edges_json = JSON.cd(json, %w(edges))
      @typed_edges.each_with_index do |type, count|
        JSON.cd(edges_json, [type])['count'] = count.to_json
      end

      edges_json = JSON.cd(json, %w(edges))
      @typed_edge_props.each_with_index do |type, props|
        props.each_with_index do |name, count|
          JSON.cd(edges_json, [type, 'properties', name])['count'] = count.to_json
        end
      end
    end

  end
end