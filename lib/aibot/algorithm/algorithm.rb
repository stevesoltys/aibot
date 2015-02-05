module AIBot::Algorithm
  ALGORITHMS = {}

  ##
  # Gets an algorithm instance.
  def self.for(symbol)
    ALGORITHMS[symbol]
  end

  ##
  # Registers an algorithm which the bot can use.
  def self.register(symbol, learn, respond)
    ALGORITHMS[symbol] = {:learning => learn, :response => respond}
  end

  ##
  # A response algorithm.
  class ResponseAlgorithm
    def respond(data_store, input, context)
      raise 'SubclassResponsibility'
    end
  end

  ##
  # A learning algorithm.
  class LearningAlgorithm
    def learn(data_store, input)
      raise 'SubclassResponsibility'
    end
  end
end