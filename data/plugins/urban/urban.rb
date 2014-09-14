java_import 'net.htmlparser.jericho.Source'
java_import 'java.net.URL'

on :event, :command do |bot, event|
  if event.command != 'urban'
    next
  end
  chat_event = event.chat_event
  args = event.args
  if args.length < 1
    bot.send_notice chat_event.session, chat_event.nick,
      " [Invalid syntax. Type '!help urban']"
    next
  end
  phrase = args.to_a.join(' ').gsub(' ', '+')
  source = Source.new URL.new "http://www.urbandictionary.com/define.php?term=#{phrase}"
  phrase = phrase.gsub('+', ' ')
  source.full_sequential_parse
  definition = source.get_first_element_by_class 'meaning'
  example = source.get_first_element_by_class 'example'
  definition = definition.get_content.get_text_extractor.to_string.gsub "\n|\r", ""
  example = example.get_content.get_text_extractor.to_string.gsub "\n|\r", ""
  bot.send_message chat_event.session, chat_event.channel, 
    chat_event.nick + ", definition for #{phrase}: #{definition}"
  bot.send_message chat_event.session, chat_event.channel, 
    chat_event.nick + ", example for #{phrase}: #{example}"
  
end
