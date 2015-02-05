module AIBot::Protocol
  PROTOCOL_BLOCKS = {}

  ##
  # Gets a protocol instance.
  def self.for(symbol, configuration)
    PROTOCOL_BLOCKS[symbol].call configuration
  end

  ##
  # Registers a protocol which the bot can use.
  def self.register(symbol, &block)
    PROTOCOL_BLOCKS[symbol] = block
  end

  ##
  # A protocol for the bot to use.
  class Protocol
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    ##
    # Starts this protocol.
    def start
      raise 'SubclassResponsibility'
    end

    ##
    # Stops this protocol.
    def stop
      raise 'SubclassResponsibility'
    end
  end
end