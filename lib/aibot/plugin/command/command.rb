module AIBot::Plugin::Command

  include AIBot::Plugin

  ##
  # A plugin which can be used to easily write 'command' plugins.
  class CommandPlugin < Plugin

    def initialize(prefix, command)
      match(/^#{prefix}#{command} (.*)/)
    end

    def execute(message)
      matched = @match_regex.match(message.message).to_a
      parameters = matched[1] || ''

      execute_command(message, parameters)
    end

    def execute_command(message, parameters)
      raise 'SubclassResponsibility'
    end

  end

end