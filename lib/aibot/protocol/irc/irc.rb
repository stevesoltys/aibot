require 'cinch'

module AIBot::Protocol::IRC
  include AIBot::Protocol

  ##
  # The IRC protocol.
  class IRC < Protocol
    attr_reader :threads, :bots

    def initialize(configuration)
      super configuration
      @threads = []
      @bots = []
    end

    ##
    # Starts the IRC protocol.
    def start(aibot)
      if configuration[:networks]
        # Loop through our networks, creating an <i>IRCBot</i> from the configuration for each.
        configuration[:networks].each do |network_name, network_config|
          bot = Cinch::Bot.new do
            # Our bot configuration.
            configure do |bot_config|
              bot_config.realname = network_config[:name]
              bot_config.nick = network_config[:nick]
              bot_config.user = network_config[:user]
              bot_config.server = network_config[:server]
              bot_config.channels = network_config[:channels]
              bot_config.plugins.prefix = /#{network_config[:prefix] || '^::'}/
              bot_config.plugins.plugins = []
              network_config[:plugins].each do |plugin|
                bot_config.plugins.plugins << Kernel.const_get(plugin)
              end if network_config[:plugins]
            end

            # Learn and respond to messages.
            # TODO: This is temporary. Will use plugins in the near future.
            on :message do |msg|
              bot = msg.bot
              message = msg.message
              if message.include?(bot.nick)
                msg.safe_reply(aibot.respond(message.gsub(bot.nick, '')))
              else
                aibot.learn(message)
              end
            end
          end
          @bots << bot
        end

        # Start our bots.
        @bots.each do |bot|
          @threads << Thread.new do
            bot.start
          end
        end

        # Wait (indefinitely) for the threads to join.
        @threads.each { |thread| thread.join }
      else
        raise "Could not find a 'networks' entry in the IRC configuration!"
      end
    end
  end

  ##
  # Registers the IRC protocol.
  AIBot::Protocol::register :irc do |configuration|
    IRC.new(configuration)
  end
end