module AIBot
  class ChatBot
    attr_reader :data_store, :response_algorithm, :learning_algorithm

    def initialize(data_store, learning_algorithm, response_algorithm)
      @learning_algorithm = learning_algorithm
      @response_algorithm = response_algorithm
      @data_store = data_store
    end

    def learn(input)
      learning_algorithm.learn data_store, input
    end

    def respond(input, context=nil)
      response_algorithm.respond data_store, input, context
    end
  end
end
