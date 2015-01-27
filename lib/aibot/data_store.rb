module AIBot
  class DataStore
    attr_reader :data

    def initialize
      @data = {}
    end

    ##
    # Gets the list of keys for this data store.
    def keys
      data.keys
    end

    ##
    # Checks if this data store has a given key.
    def has?(key)
      data.include? key
    end

    ##
    # Gets data for a given key from this store.
    def get(key)
      data[key]
    end

    ##
    # Puts data in this store, given the key and value.
    def put(key, value)
      data[key] = value
    end

    ##
    # Loads our data. This is the responsibility of the
    # subclass.
    def load(params=nil)
      raise 'SubclassResponsibility'
    end

    ##
    # Saves our data. This is the responsibility of the
    # subclass.
    def save(params=nil)
      raise 'SubclassResponsibility'
    end
  end
end