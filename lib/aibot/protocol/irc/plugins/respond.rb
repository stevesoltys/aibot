module Cinch
  module Plugins
    ##
    # Cinch plugin which utilizes the response algorithm to respond to users.
    class Response
      include Cinch::Plugin
      PLUGIN_NAMES = ['urban', 'rr', 'word'] # we want to avoid matching other plugins

      match(/.*/, :method => :respond)
      def respond(msg)
        split_message = msg.message.split
        split_message.delete(split_message.first)
        topic = split_message.join(' ')
        PLUGIN_NAMES.each do |name| #TODO: figure out a better way!!
          return if topic.downcase.start_with? name
        end
        msg.safe_reply msg.bot.respond(topic)
      end
    end
  end
end