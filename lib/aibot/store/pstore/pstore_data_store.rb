require 'pstore'

module AIBot::Store::PStore
  include AIBot::Store

  class PStoreDataStore < DataStore
    attr_reader :store

    def initialize(configuration)
      super configuration
      if configuration[:file]
        data_store_file = File.expand_path(configuration[:file])
        File.new(data_store_file, 'w') unless File.exists?(data_store_file)
        @store = PStore.new(data_store_file, true)
      else
        raise "Could not find 'file' entry in store configuration!"
      end
    end

    ##
    # Performs a transaction on this data store.
    def transaction(&block)
      store.transaction do
        block.call
      end
    end

    ##
    # Gets the list of keys for this data store.
    def keys
      store.roots
    end

    ##
    # Checks if this data store has a given key.
    def has?(key)
      store.root? key
    end

    ##
    # Gets data for a given key from this store.
    def get(key)
      store[key]
    end

    ##
    # Puts data in this store, given the key and value.
    def put(key, value)
      store[key] = value
    end
  end

  ##
  # Registers the PStore data store.
  AIBot::Store::register :pstore do |configuration|
    PStoreDataStore.new configuration
  end
end