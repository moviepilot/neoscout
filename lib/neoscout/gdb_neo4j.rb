module NeoScout

  module GDB_Neo4j

    module Constraints

      class PropConstraint < NeoScout::Constraints::PropConstraint

        def satisfied_by?(typer, obj)
          if obj.property?(@name)
            then satisfies_type?(typer, @type, obj[@name])
            else self.opt
          end
        end

        def satisfies_type?(typer, type, value)
          if type then typer.valid_value?(type, value) else true end
        end
      end

    end

    class Typer < NeoScout::Typer

      attr_accessor :type_attr
      attr_accessor :nil_type
      attr_accessor :value_type_table

      include TyperValueTableMixin

      def initialize
        @type_attr        = '_classname'
        @nil_type         = '__NOTYPE__'
        @value_type_table = {}
      end

      def node_type(node)
        props = node.props
        return props[@type_attr] if props.has_key? @type_attr
        @nil_type
      end

      def edge_type(edge)
        type = edge.rel_type
        if type then type.to_s else @nil_type end
      end

      def checked_node_type?(node_type) ; node_type != self.nil_type end
      def checked_edge_type?(edge_type) ; edge_type != self.nil_type end
    end

    class ElementIterator < NeoScout::ElementIterator

      def iter_nodes(args)
        if args[:report_progress]
          then report = args[:report_progress]
          else report = lambda { |mode, what, num| } end
        glops = org.neo4j.tooling.GlobalGraphOperations.at(Neo4j.db.graph)
        iter  = glops.getAllNodes.iterator
        num   = 0
        while iter.hasNext do
          node = iter.next
          num  = num + 1
          report.call(:progress, :nodes, num)
          yield node unless node.getId == 0
        end

        report.call(:finish, :nodes, num)
        num
      end

      def iter_edges(args)
        if args[:report_progress]
          then report = args[:report_progress]
          else report = lambda { |mode, what, num| } end
        glops = org.neo4j.tooling.GlobalGraphOperations.at(Neo4j.db.graph)
        iter  = glops.getAllRelationships.iterator
        num   = 0
        while iter.hasNext do
          num  = num + 1
          report.call(:progress, :edges, num)
          yield iter.next
        end

        report.call(:finish, :edges, num)
        num
      end

    end

    class Verifier < NeoScout::Verifier
      def initialize(typer)
        super()
        @typer = typer
      end

      def new_node_prop_constr(args={})
        Constraints::PropConstraint.new args
      end

      def new_edge_prop_constr(args={})
        Constraints::PropConstraint.new args
      end

      def init_from_json(json)
        super(json)
        # Ensure __NOTYPE__entries always have a properties hash
        JSON.cd(json, ['nodes', @typer.nil_type, 'properties'])
        JSON.cd(json, ['connections', @typer.nil_type, 'properties'])
      end
    end

    class Scout < NeoScout::Scout

      def initialize(args={})
        args[:typer] = Typer.new unless args[:typer]
        args[:verifier] = Verifier.new(args[:typer]) unless args[:verifier]
        args[:iterator] = ElementIterator.new unless args[:iterator]
        super args
      end

      def prep_counts(counts)
        # Ensure __NOTYPE__entries always have a counts array
        counts.typed_nodes[typer.nil_type]
        counts.typed_edges[typer.nil_type]
        counts
      end
    end

  end

end
