require 'sqlite3'

module AIBot::Store
  class SQLiteDataStore
    attr_reader :store

    def initialize(configuration)
      if configuration[:file]
        data_store_file = File.expand_path(configuration[:file])
        File.new(data_store_file, 'w') unless File.exists?(data_store_file)
        @store = SQLite3::Database.new(data_store_file)
      else
        raise "Could not find 'file' entry in store configuration!"
      end
    end

    ##
    # Performs a transaction on this data store.
    def transaction(&block)
      begin
        @store.transaction
        block.call(@store)
        @store.commit
      rescue SQLite3::Exception => exception
        raise "SQLite exception: #{exception}"
      end
    end

    ##
    # Executes a query on this data store.
    def execute(query, params=nil)
      begin
        @store.execute(query, params)
      rescue SQLite3::Exception => exception
        raise "SQLite exception: #{exception}"
      end
    end
  end
end