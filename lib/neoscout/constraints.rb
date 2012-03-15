module NeoScout

  module Constraints

    class Constraint
      def satisfied_by_node?(typer, node) ; satisfied_by?(typer, node) end
      def satisfied_by_edge?(typer, edge) ; satisfied_by?(typer, edge) end

      def satisfied_by?(typer, obj) ; raise NotImplementedError end
    end

    class PropConstraint < Constraint
      attr_reader :name, :opt, :type

      def initialize(args = {})
        super(args)
        @name  = args[:name]
        @opt   = args[:opt]
        @type  = args[:type]

        raise ArgumentError unless @name.kind_of? String
        raise ArgumentError unless @name.length > 0
      end

      def to_s
        opt_s  = if @opt then " (opt.)" else '' end
        type_s = if @type then ": #{@type}" else '' end

        "#{@name}#{type_s}#{opt_s}"
      end
    end


  end
end