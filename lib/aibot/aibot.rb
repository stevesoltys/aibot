module AIBot
  ##
  # The main class for an AIBot. Contains the protocol, data store, and algorithm.
  class AIBot
    attr_reader :protocol, :algorithm,  :data_store

    def initialize(configuration)
      raise "Configuration error! Could not find 'protocol' entry." unless configuration[:protocol]
      @protocol = Protocol::for(configuration[:protocol][:type], configuration[:protocol])
      @algorithm = Algorithm::for(configuration[:algorithm])
      raise "Configuration error! Could not find 'store' entry." unless configuration[:store]
      @data_store = Store::SQLiteDataStore.new(configuration[:store])
    end

    ##
    # Starts this bot.
    def start
      @algorithm.init(@data_store)
      @protocol.start(self)
    end

    ##
    # Stops this bot.
    def stop
      @protocol.stop
    end

    ##
    # Learns from the given input.
    def learn(input)
      @algorithm.learn(@data_store, input)
    end

    ##
    # Responds to the given input, with the option of context.
    def respond(input, context=nil)
      @algorithm.respond(@data_store, input, context)
    end
  end
end
