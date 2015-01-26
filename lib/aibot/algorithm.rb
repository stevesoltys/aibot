module AIBot
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