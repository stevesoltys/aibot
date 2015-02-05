module AIBot
  ##
  # The main class for an AIBot. Contains the protocol, data store, and algorithm.
  class AIBot
    attr_reader :protocol, :data_store, :algorithm

    def initialize(protocol, data_store, algorithm, configuration)
      raise "Configuration error! Could not find 'protocol' entry." unless configuration[:protocol]
      @protocol = Protocol::for(protocol, configuration[:protocol])
      raise "Configuration error! Could not find 'store' entry." unless configuration[:store]
      @data_store = Store::for(data_store, configuration[:store])
      @algorithm = Algorithm::for(algorithm)
    end

    ##
    # Starts this bot.
    def start
      protocol.start self
    end

    ##
    # Stops this bot.
    def stop
      protocol.stop
    end

    ##
    # Learns from the given input.
    def learn(input)
      algorithm[:learning].learn data_store, input
    end

    ##
    # Responds to the given input, with the option of context.
    def respond(input, context=nil)
      algorithm[:response].respond data_store, input, context
    end
  end
end
