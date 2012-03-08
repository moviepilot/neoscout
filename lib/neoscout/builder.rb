module NeoScout

  class Iterator
    def for_nodes(node_type = nil)
      raise NotImplementedError
    end

    def for_edges(edge_type = nil)
      raise NotImplementedError
    end
  end


  class NeoScout
    def initialize(args)
      @typer     = args[:typer]
      @validator = args[:validator]
      @iterator  = args[:iterator]
    end
  end

end
