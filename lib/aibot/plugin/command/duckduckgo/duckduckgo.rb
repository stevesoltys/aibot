require 'duckduckgo'
require 'cgi'

module AIBot::Plugin::Google

  include AIBot::Plugin::Command

  class DuckDuckGoCommand < CommandPlugin

    def initialize
      super('~', 'duckduckgo', 'ddg')
    end

    def clean_content(content)
      CGI::unescapeHTML(content.gsub(/\r|\n|<b>|<\/b>/, ''))
    end

    def execute_command(bot, message, parameters)

      result = DuckDuckGo::search(:query => parameters).first

      if result.nil?
        message.reply("[DuckDuckGo] No results found for '#{parameters}'.")
      else
        message.reply("[DuckDuckGo] #{result.title} <#{result.uri}>")
        message.reply("[DuckDuckGo] Description: #{clean_content(result.description)}")
      end

    end
  end

  AIBot::Plugin::register(:duckduckgo, DuckDuckGoCommand.new)
end