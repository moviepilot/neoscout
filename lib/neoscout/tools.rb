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

    def add(elem)
      raise ArgumentError unless valid_elem?(elem)
      super elem
    end

    def to_s
      first  = true
      result = "#<NeoScout::ConstrainedSet: ["
      each { |elem|
        if first
          result <<= "#{elem.to_s}"
          first    = false
        else
          result <<= ", #{elem.to_s}"
        end
      }
      result <<= "]>"
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

    def [](key)
      if has_key?(key) then super(key) else self[key]=default(key) end
    end

    def lookup(key, default_value = nil)
      if has_key?(key) then super(key) else self[key]=default_value end
    end

    def map_values(&blk)
      new_hash = {}
      each_pair do |k,v|
        new_hash[k] = blk.call(v)
      end
      new_hash
    end

    def to_s
      (self.map_values { |v| v.to_s }).to_s
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
