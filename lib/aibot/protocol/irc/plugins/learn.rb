require 'cgi'
require 'json'
require 'open-uri'
require 'cinch/toolbox'

module AIBot
  module LearningUtil
    ##
    # Searches Urban Dictionary for a given query.
    def self.search(query)
      uri = 'http://api.urbandictionary.com/v0/define?term=%s' % [CGI.escape(query)]
      open(uri) do |f|
        obj = JSON.parse(f.read)
        if obj['list'].empty?
          'No result'
        else
          obj['list'][0]['definition'].gsub(/(\r\n)+/, ' ')
        end
      end
    rescue => e
      exception(e)
      'An exception occured'
    end

    ##
    # Searches Wikipedia for a given query.
    def self.wiki(term)
      # URI Encode
      term = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      url = "http://simple.wikipedia.org/w/index.php?search=#{term}"
      get_def(url)
    end

    ##
    # Gets a Wikipedia definition, given the url.
    def self.get_def(url)
      cats = Cinch::Toolbox.get_html_element(url, '#mw-normal-catlinks')
      if cats && cats.include?('Disambiguation')
        wiki_text = nil
      else
        wiki_text = Cinch::Toolbox.get_html_element(url, '#mw-content-text p')
        if wiki_text.nil? || wiki_text.include?('Help:Searching')
          return nil
        end
      end
      wiki_text
    end
  end
end

module Cinch
  module Plugins

    class Learning
      include Cinch::Plugin

      match /(learn about|learn)(.*)/, :method => :learn_about
      match /.*/, :use_prefix => false

      ##
      # Teaches the bot about a certain topic by querying
      # Urban Dictionary and learning from the result.
      def learn_about(msg, command, topic)
        bot = msg.bot
        topic = topic.strip
        result = AIBot::LearningUtil::search(topic)
        if result
          bot.learn result
          msg.reply "Successfully learned about #{topic}."
        else
          msg.reply "Could not find information about #{topic}."
        end
      end

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