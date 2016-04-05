require 'google-search'
require 'cgi'

module AIBot::Plugin::Google

  include AIBot::Plugin::Command

  class GoogleCommand < CommandPlugin

    def initialize
      super('~', 'google')
    end

    def clean_content(content)
      CGI::unescapeHTML(content.gsub(/\r|\n|<b>|<\/b>/, ''))
    end

    def execute_command(bot, message, parameters)

      result = Google::Search::Web.new(:query => parameters).first

      if result.nil?
        message.reply("[Google] No results found for '#{parameters}'.")
      else
        message.reply("[Google] #{result.title} <#{result.uri}>")
        message.reply("[Google] Description: #{clean_content(result.content)}")
      end

    end
  end

  AIBot::Plugin::register(:google, GoogleCommand.new)
end