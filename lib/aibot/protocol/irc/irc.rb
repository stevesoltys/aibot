require 'cinch'

module AIBot::Protocol::IRC
  include AIBot::Protocol
  include AIBot::Message

  ##
  # An IRC message that has been received.
  class IRCMessage < Message

    def initialize(cinch_msg)
      super(cinch_msg.user, cinch_msg.message)

      @cinch_msg = cinch_msg
    end

    def reply(response)
      @cinch_msg.safe_reply(response)
    end
  end

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
              bot_config.port = network_config[:port] || 6667
              bot_config.ssl.use = network_config[:ssl]
              bot_config.channels = network_config[:channels]

              bot_config.plugins.prefix = /#{network_config[:plugin_prefix] || '^::'}/
              bot_config.plugins.plugins = []

              network_config[:plugins].each do |plugin_name, plugin_config|
                require_path = plugin_config[:require_path]
                class_path = plugin_config[:class_path]

                unless class_path.nil?
                  require require_path unless require_path.nil?

                  plugin_constant = Kernel.const_get(class_path)
                  bot_config.plugins.plugins << plugin_constant

                  configuration = plugin_config[:configuration]
                  bot_config.plugins.options[plugin_constant] = configuration unless configuration.nil?
                end

              end if network_config[:plugins]
            end

            # Learn and respond to messages.
            # TODO: This is temporary. Will use plugins in the near future.
            on :message do |msg|
              bot = msg.bot
              message = msg.message

              if message.include?(bot.nick)
                message = message.gsub(bot.nick, '').squeeze(' ')
                response = aibot.respond(message).split

                if response.first.eql?("\x01action")
                  response.delete(response.first)
                  msg.safe_action_reply(response.join(' ')) if network_config[:silenced].nil?
                else
                  msg.safe_reply(response.join(' ')) if network_config[:silenced].nil?
                end

              else
                aibot.learn(message)
              end

              aibot.message_received(IRCMessage.new(msg))
            end

            # Auto join after being invited.
            on :invite do |msg|
              bot = msg.bot
              bot.join(msg.channel.name)
            end

            # Auto join after being kicked.
            on :kick do |msg|
              bot = msg.bot
              bot.join(msg.channel.name)
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