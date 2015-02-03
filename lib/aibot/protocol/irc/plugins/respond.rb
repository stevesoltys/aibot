module Cinch
  module Plugins
    ##
    # Cinch plugin which utilizes the response algorithm to respond to users.
    class Response
      include Cinch::Plugin

      match /.*/, :use_prefix => false

      ##
      # Responds to users when they mention the bot's nick.
      def execute(msg)
        bot = msg.bot
        if msg.message.include? bot.nick
          topic = msg.message.gsub(bot.nick, '')
          msg.safe_reply bot.respond(topic)
        end
      end
    end
  end
end