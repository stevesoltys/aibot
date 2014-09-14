require 'java'
java_import 'net.shiver.aibot.irc.IRCBot'
java_import 'net.shiver.aibot.event.EventManager'
java_import 'java.lang.System'

AUTH_PASSWORD = 'r0flwat'

def is_authenticated(bot, chat_event)
  login = "login_session_#{chat_event.nick}"
  if bot.get_attribute(login) == nil
    bot.send_notice chat_event.session, chat_event.nick, 
      "You don't have the rights to do that!"
    return false
  end
  if bot.get_attribute(login).to_i < System::current_time_millis
    bot.send_notice chat_event.session, chat_event.nick, 
      "You don't have the rights to do that!"
    return false
  end
  true
end