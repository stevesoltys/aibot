module AIBot
  ##
  # A DSL for creating an <i>AIBot</i> instance.
  class AIBotBuilder
    def initialize(&block)
      @protocol = nil
      @data_store = nil
      @algorithm = nil
      instance_eval &block
    end

    ##
    # Sets the protocol symbol.
    def protocol(symbol)
      @protocol = symbol
    end

    ##
    # Sets the data store symbol.
    def data_store(symbol)
      @data_store = symbol
    end

    ##
    # Sets the algorithm symbol.
    def algorithm(symbol)
      @algorithm = symbol
    end

    ##
    # Creates an <i>AIBot</i> instance from this builder.
    def to_bot(configuration)
      AIBot.new(@protocol, @data_store, @algorithm, configuration)
    end
  end

  ##
  # Creates an <i>AIBot</i> instance using an <i>AIBotBuilder</i>.
  def self.create(configuration, &block)
    AIBotBuilder.new(&block).to_bot(configuration)
  end
end