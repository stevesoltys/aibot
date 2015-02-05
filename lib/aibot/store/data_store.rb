module AIBot::Store
  DATA_STORE_BLOCKS = {}

  ##
  # Gets a data store instance.
  def self.for(symbol, configuration)
    DATA_STORE_BLOCKS[symbol].call configuration
  end

  ##
  # Registers a data store which the bot can use.
  def self.register(symbol, &block)
    DATA_STORE_BLOCKS[symbol] = block
  end

  class DataStore
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

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
  end
end