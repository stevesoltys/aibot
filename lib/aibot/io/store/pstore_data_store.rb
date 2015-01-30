require 'pstore'

module AIBot
  class PStoreDataStore < DataStore
    attr_reader :store

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

    ##
    # Loads our <i>PStore</i>.
    def load(params=nil)
      @store = PStore.new(params[:file], true)
    end

    ##
    # Not necessary for <i>PStore</i>.
    def save(params=nil)
      raise 'PStore automatically saves changes, the save method is not necessary.'
    end
  end
end