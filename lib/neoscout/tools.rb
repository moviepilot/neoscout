module NeoScout

  class Counter

    def initialize
      reset
    end

    def reset
      @ok    = 0
      @total = 0
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
  end

  class HashWithDefault < Hash
    def initialize(&blk)
      super
      @default = blk
    end

    def default(key)
      @default.call(key)
    end
  end
end

class Hash

  def self.newWithDefault(&blk)
    NeoScout::HashWithDefault.new(&blk)
  end

end