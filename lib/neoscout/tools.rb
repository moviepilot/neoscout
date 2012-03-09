module NeoScout

  class Counter

    def initialize
      reset
    end

    def reset
      @ok    = 0
      @total = 0
    end

    def incr(ok)
      if ok then incr_ok else incr_failed end
    end

    def incr_ok
      @ok    += 1
      @total += 1
    end

    def incr_failed
      @total +=1
    end

    def num_ok
      @ok
    end

    def num_failed
      @total - @ok
    end

    def num_total
      @total
    end

    def to_s
      "(#{num_ok}/#{num_failed}/#{num_total})"
    end

  end

  class ConstrainedSet < Set

    def initialize(*args, &elem_test)
      @elem_test = elem_test
      case
        when args.length == 0
          super
        when args.length == 1
          args = args[0]
          raise ArgumentError unless (args.all? &@elem_test)
          super args
        else
          raise ArgumentError
      end
    end

    def valid_elem?(elem)
      @elem_test.call(elem)
    end

    def <<(elem)
      raise ArgumentError unless valid_elem?(elem)
      super << elem
    end

  end

  class HashWithDefault < Hash

    def initialize(&blk)
      super
      @default = blk
    end

    def default(key)
      @default.call(key)
    end

    def lookup(key, default_value = nil)
      if has_key?(key) then self[key] else default_value end
    end

  end

  module JSON

    def self.cd(json, args)
      current = json
      args.each do |k|
        current = (current[k] = if current.has_key? k then current[k] else {} end)
      end
      current
    end
  end
end
