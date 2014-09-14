java_import 'java.io.StringReader'

HYPERLINK_HOOKS = %w(http www)

def has_hyperlink?(message)
  HYPERLINK_HOOKS.each do |string|
    return true if message.include? string
  end
  false
end

on :event, :receive_message do |bot, event|
  include Core
  chat_event = event.chat_event
  line = chat_event.get_line.gsub(/[[:punct:]]/, '').downcase
  nick = bot.nicks.get(chat_event.session)
  if line.include? nick
    message = line.split
    message.each do |token|
      if token.downcase.include? nick
        message.delete_at message.index(token)
      end
    end
    bot.send_message chat_event.session, chat_event.channel,
                     respond(chat_event.get_nick, message.join(' '))
  else
    learn line unless has_hyperlink? line
  end
end