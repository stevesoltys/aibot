module AIBot
  class DataStore
    ##
    # Performs a transaction on this data store.
    def transaction(&block)
      raise 'SubclassResponsibility'
    end

    ##
    # Loads our data store. This is the responsibility of the
    # subclass.
    def load(params=nil)
      raise 'SubclassResponsibility'
    end

    ##
    # Saves our data store. This is the responsibility of the
    # subclass.
    def save(params=nil)
      raise 'SubclassResponsibility'
    end
  end
end