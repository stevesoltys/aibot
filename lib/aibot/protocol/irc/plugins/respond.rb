module Cinch
  module Plugins
    ##
    # Cinch plugin which utilizes the response algorithm to respond to users.
    class Response
      include Cinch::Plugin
      PLUGIN_NAMES = ['urban', 'rr', 'word'] # we want to avoid matching other plugins

      match /(reply|talk about|talk|speak|respond|tell me about|tell me)*(.*)/

      def execute(msg, command, topic)
        PLUGIN_NAMES.each do |name| #TODO: figure out a better way!!
          return if topic.downcase.start_with? name
        end
        msg.safe_reply msg.bot.respond(topic)
      end
    end
  end
end