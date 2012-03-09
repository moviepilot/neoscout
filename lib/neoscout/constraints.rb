module NeoScout

  module Constraints

    class Constraint
      def satisfied_by?(obj) ; raise NotImplementedError end
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
        raise ArgumentError unless @min.kind_of? Fixnum
        raise ArgumentError unless (@max.kind_of?(Fixnum) || @max == :inf)
      end

      def to_s
        "#{@src}:#{@dir} -- (#{@min}, #{@max}) #{@dst}"
      end
    end
  end
end