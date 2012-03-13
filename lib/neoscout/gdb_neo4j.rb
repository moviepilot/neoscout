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
      attr_writer :type_attr

      def initialize
        @type_attr = 'type'
      end

      def node_type(node)
        node[@type_attr]
      end

      def edge_type(edge)
        edge[@type_attr]
      end

    end

    class ElementIterator < NeoScout::ElementIterator

      def iter_nodes(args)
        Neo4j.all_nodes.each do |node|
          yield node if node.neo_id != 0
        end
      end

    end

    class Verifier < NeoScout::Verifier
      def new_node_prop_constr(args={})
        Constraints::PropConstraint.new args
      end

      def new_edge_prop_constr(args={})
        Constraints::PropConstraint.new args
      end
    end

    class Scout < NeoScout::Scout

      def initialize(args={})
        args[:verifier] = Verifier.new unless args[:verifier]
        args[:typer] = Typer.new unless args[:typer]
        args[:iterator] = ElementIterator.new unless args[:iterator]
        super args
      end

    end

  end

end