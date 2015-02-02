module AIBot
  class DataStore
    ##
    # Performs a transaction on this data store.
    def transaction(&block)
      raise 'SubclassResponsibility'
    end

    ##
    # Gets the list of keys for this data store.
    def keys
      raise 'SubclassResponsibility'
    end

    ##
    # Checks if this data store has a given key.
    def has?(key)
      raise 'SubclassResponsibility'
    end

    ##
    # Gets data for a given key from this store.
    def get(key)
      raise 'SubclassResponsibility'
    end

    ##
    # Puts data in this store, given the key and value.
    def put(key, value)
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