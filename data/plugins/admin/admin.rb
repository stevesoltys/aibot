java_import 'net.shiver.aibot.irc.IRCBot'
java_import 'net.shiver.aibot.event.EventManager'
java_import 'java.lang.System'

on :event, :command do |bot, event|
  chat_event = event.chat_event
  args = event.args
  if event.command != 'login' or args.length < 2
    next
  end
  if args[0] == AUTH_PASSWORD
    time = args[1].to_i * 60000
    bot.set_attribute "login_session_#{chat_event.nick}", System::current_time_millis + time
    bot.send_notice chat_event.session, chat_event.nick,
                    "Successfully logged in for #{args[1]} minutes."
  end
end

on :event, :command do |bot, event|
  chat_event = event.chat_event
  if event.command != 'rlpl' or not is_authenticated bot, chat_event
    next
  end
  event_manager = EventManager.get_instance
  event_manager.get_event_handlers.clear
  event_manager.init
  bot.send_notice chat_event.session, chat_event.nick, 'Successfully reloaded plugins.'
end

on :event, :command do |bot, event|
  args = event.args
  chat_event = event.chat_event
  if event.command != 'mode' or args.length < 2 or
      not is_authenticated bot, chat_event
    next
  end
  bot.send_mode chat_event.session, args.to_a.join(' ')
end

on :event, :command do |bot, event|
  args = event.args
  chat_event = event.chat_event
  if event.command != 'join' or args.length < 1 or
      not is_authenticated bot, chat_event
    next
  end
  bot.join_channel chat_event.session, args[0]
end

on :event, :command do |bot, event|
  args = event.args
  chat_event = event.chat_event
  if event.command != 'part' or args.length < 1 or
      not is_authenticated bot, chat_event
    next
  end
  bot.part_channel chat_event.session, args[0]
end
