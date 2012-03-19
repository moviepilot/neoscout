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

    def empty?
      @total == 0
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
      super elem
    end

  end

  module HashDefaultsMixin

    def initialize(*args, &blk)
      super *args
      @default = blk
    end

    def default(key)
      @default.call(key)
    end

    def [](key)
      if has_key?(key) then super(key) else self[key]=default(key) end
    end

    def lookup(key, default_value = nil)
      if has_key?(key) then self[key] else self[key]=default_value end
    end

    def key_descr
      :key
    end


    def self.included(base)

      # defines map_value for mixin target baseclass instances and any subclass instances
      base.class_exec(base) do |base_class|
        define_method(:map_value) do |&blk|
          new_hash = {}
          each_pair do |k,v|
            new_hash[k] = if v.kind_of? base_class then v.map_value(&blk) else blk.call(v) end
          end
          new_hash
        end
      end

      # defines new_multi_keyed on the mixin's target baseclass
      # (subclasses the baseclass to override key_descr for instances)
      def base.new_multi_keyed(*list, &blk)
        new_class = Class.new(self)
        (class << new_class ; self end).class_exec(list.shift) do |descr|
          define_method(:key_descr) { || descr }
        end
        if list.empty?
          then new_class.new(&blk)
          else new_class.new { |key| self.new_multi_keyed(*list, &blk) } end
      end

    end
  end

  class HashWithDefault < Hash

    include HashDefaultsMixin

  end

  class Counter

    def self.new_multi_keyed(*list)
      HashWithDefault.new_multi_keyed(*list) { |key| Counter.new }
    end

  end

  module JSON

    def self.cd(json, args)
      current = json
      args.each do |k|
        current = if current.has_key? k
          then current[k]
          else current[k] = {} end
      end
      current
    end

  end

end
