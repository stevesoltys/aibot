module AIBot::Plugin

  PLUGINS = {}

  ##
  # Registers a plugin.
  def self.register(symbol, plugin)
    PLUGINS[symbol] = plugin
  end

  ##
  # Gets all plugin instances that match for the given message.
  def self.all_matching(message)
    PLUGINS.select { |symbol, plugin| plugin.matches?(message.message) }.values
  end

  ##
  # A plugin for AIBot.
  class Plugin

    attr_reader :match_regex

    def initialize
      @match_regex = /a^/
    end

    ##
    # Sets the current regex that this plugin matches.
    def match(regex)
      @match_regex = regex
    end

    ##
    # Checks if this plugin matches for the given message.
    def matches?(message)
      @match_regex =~ message
    end

    ##
    # Executes this plugin for the given message.
    def execute(message)
      raise 'SubclassResponsibility'
    end

  end
end