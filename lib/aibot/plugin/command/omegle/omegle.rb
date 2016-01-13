require 'omegle'
require 'json'

module AIBot::Plugin::Omegle

  include AIBot::Plugin::Command

  class OmegleCommand < CommandPlugin

    def initialize
      super('~', 'omegle')

      @omegle = Omegle.new
    end

    def execute_command(bot, message, parameters)
      parameters = parameters.split
      command = parameters.shift

      case command
        when 'start'
          @omegle.start

          @omegle.listen do |event|
            event = event.flatten
            type = event.shift

            if type.eql?('gotMessage')

              omegle_msg = event.shift.gsub(/\r|\n/, ' ... ')
              message.reply("stranger: #{omegle_msg}")

              @omegle.typing

              response = bot.respond(omegle_msg)

              sleep(rand(3..6))
              @omegle.send(response)

              message.reply("response: #{response}")
            end
          end

          message.reply('stranger disconnected')

        when 'stop'
          @omegle.disconnect

      end unless command.nil?

    end
  end

  AIBot::Plugin::register(:omegle, OmegleCommand.new)
end