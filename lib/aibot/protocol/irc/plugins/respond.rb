module Cinch
  module Plugins
    ##
    # Cinch plugin which utilizes the response algorithm to respond to users.
    class Response
      include Cinch::Plugin

      match /(reply|talk about|talk|speak|respond|tell me about|tell me)(.*)/

      def execute(msg, command, topic)
        msg.safe_reply msg.bot.respond(topic)
      end
    end
  end
end