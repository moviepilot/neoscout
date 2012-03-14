module NeoScout

  module GDB_Neo4j

    module Constraints

      class PropConstraint < NeoScout::Constraints::PropConstraint

        def satisfied_by?(obj)
          if obj.property?(@name)
            satisfies_type?(@type, obj[@name])
          else
            ! self.opt
          end
        end

        def satisfies_type?(type, value)
          true
        end
      end

    end

    class Typer < NeoScout::Typer

      attr_accessor :type_attr
      attr_accessor :nil_type

      def initialize
        @type_attr = 'type'
        @nil_type  = '__NOTYPE__'
      end

      def node_type(node)
        node[@type_attr] || @nil_type
      end

      def edge_type(edge)
        edge[@type_attr] || @nil_type
      end

    end

    class ElementIterator < NeoScout::ElementIterator

      def iter_nodes(args)
        glops = org.neo4j.tooling.GlobalGraphOperations.at(Neo4j.db.graph)
        iter  = glops.getAllNodes.iterator
        while iter.hasNext do
          node = iter.next
          yield node.wrapper unless node.getId == 0
        end
      end

      def iter_edges(args)
        glops = org.neo4j.tooling.GlobalGraphOperations.at(Neo4j.db.graph)
        iter  = glops.getAllRelationships.iterator
        while iter.hasNext do
          yield iter.next.wrapper
        end
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
        JSON.cd(json, ['nodes', @typer.nil_type, 'properties'])
        JSON.cd(json, ['edges', @typer.nil_type, 'properties'])
      end
    end

    class Scout < NeoScout::Scout

      def initialize(args={})
        args[:typer] = Typer.new unless args[:typer]
        args[:verifier] = Verifier.new(args[:typer]) unless args[:verifier]
        args[:iterator] = ElementIterator.new unless args[:iterator]
        super args
      end

    end

  end

end
