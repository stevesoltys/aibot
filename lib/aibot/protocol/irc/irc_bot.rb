require 'cinch'

module AIBot
  class IRCBot < ChatBot
    attr_reader :bot

    def initialize(data_store, learning_algorithm, response_algorithm, &block)
      super data_store, learning_algorithm, response_algorithm

      #TODO: seems hacked together, i don't like this at all
      tmp_self = self
      @bot = Cinch::Bot.new do
        configure &block

        @irc_bot = tmp_self

        def learn(input)
          @irc_bot.learn input
        end

        def respond(input, context=nil)
          @irc_bot.respond input, context
        end
      end
    end

    ##
    # Starts the bot.
    def start
      bot.start
    end

    ##
    # Stops the bot.
    def stop
      bot.stop
    end
  end
end