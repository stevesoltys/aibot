module Cinch
  module Plugins

    ##
    # Cinch plugin which utilizes the learning algorithm to learn from users.
    class Learning
      include Cinch::Plugin

      match /.*/, :use_prefix => false

      ##
      # Learns from user input.
      def execute(msg)
        message = msg.message
        bot = msg.bot
        bot.learn(message) unless message.include?(bot.nick)
      end
    end
  end
end