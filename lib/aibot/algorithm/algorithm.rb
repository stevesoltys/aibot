module AIBot::Algorithm
  ALGORITHMS = {}

  ##
  # Gets an algorithm instance.
  def self.for(symbol)
    ALGORITHMS[symbol]
  end

  ##
  # Registers an algorithm which the bot can use.
  def self.register(symbol, algorithm)
    ALGORITHMS[symbol] = algorithm
  end

  ##
  # A chat algorithm.
  class ChatAlgorithm
    def init(data_store)
      raise 'SubclassResponsibility'
    end

    def learn(data_store, input)
      raise 'SubclassResponsibility'
    end

    def respond(data_store, input, context)
      raise 'SubclassResponsibility'
    end
  end
end