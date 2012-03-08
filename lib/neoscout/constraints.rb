module NeoScout

  module Constraints

    class Constraint
      attr_reader :constraints

      def initialize(args)
        @constraints = []
      end

      def complying?(obj)
        true
      end
    end

    class PropConstraint < Constraint
      attr_reader :name, :opt, :type

      def initialize(args = {})
        super(args)
        @name  = args[:name]
        @opt   = args[:opt]
        @type  = args[:type]

        raise ArgumentError unless @name.class == String
        raise ArgumentError unless @name.length > 0

        @constraints = [:nodes, :edges]
      end

      def to_s
        opt_s  = if @opt then " (opt.)" else '' end
        type_s = if @type then ": #{@type}" else '' end

        "#{@name}#{type_s}#{opt_s}"
      end
    end

    class CardConstraint < Constraint
      attr_reader :src, :dst, :min, :max, :dir

      def initialize(args = {})
        super(args)
        @src = args[:src]
        @dst = args[:dst]
        @min = args[:min]
        @min = 0 unless @min
        @max = args[:max]
        @max = :inf unless @max
        @dir = args[:dir]
        @dir = :any unless @dir

        raise ArgumentError unless [:directed, :undirected, :any].include?(@dir)
        raise ArgumentError unless @min.class == Fixnum
        raise ArgumentError unless @max.class == Fixnum || @max == :inf

        @constraints = [:nodes]
      end

      def to_s
        "#{@src}:#{@dir} -- (#{@min}, #{@max}) #{@dst}"
      end
    end
  end
end