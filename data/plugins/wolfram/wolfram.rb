java_import 'net.stevesoltys.aibot.util.WolframAlphaUtility'

on :event, :command do |bot, event|
  if event.command != 'wolfram'
    next
  end
  chat_event = event.chat_event
  args = event.args
  if args.length < 1
    bot.send_notice chat_event.session, chat_event.nick,
      " [Invalid syntax. Type '!help wolfram']"
    next
  end
  phrase = args.to_a.join ' '
  result = WolframAlphaUtility.instance.query phrase
  if result.is_error
    bot.send_message chat_event.session, chat_event.channel, 
      chat_event.nick + ', There was an error: ' + result.get_error_message
  elsif not result.is_success
    bot.send_message chat_event.session, chat_event.channel, 
      chat_event.nick + ", I couldn't get a result from that query."
  else
    bot.send_message chat_event.session, chat_event.channel, 
      chat_event.nick + ', here are the results:'
    count = 0
    result.get_pods.each do |pod|
      if count == 4
        break
      end
      unless pod.is_error
        count += 1
        message = "[#{pod.get_title}]: "
        pod.get_subpods.each do |subpod|
          subpod.get_contents.each do |element|
            message << "{#{element.get_text}} "
          end
        end
        bot.send_message chat_event.session, chat_event.channel, message
      end
    end
  end
end
