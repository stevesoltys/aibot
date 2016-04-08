module AIBot::Plugin::Command

  include AIBot::Plugin

  ##
  # A plugin which can be used to easily write 'command' plugins.
  class CommandPlugin < Plugin

    def initialize(prefix, *commands)
      commands.each { |command| match(/^#{prefix}#{command} (.*)/) }
    end

    def execute(bot, message)
      matched = @match_regex.match(message.message).to_a
      parameters = matched[1] || ''

      execute_command(bot, message, parameters)
    end

    def execute_command(bot, message, parameters)
      raise 'SubclassResponsibility'
    end

  end

end