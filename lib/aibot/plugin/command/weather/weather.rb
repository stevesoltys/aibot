require 'weather-underground'
require 'time-lord'

module AIBot::Plugin::Weather

  include AIBot::Plugin::Command

  class WeatherCommand < CommandPlugin

    def initialize
      super('~', 'weather')
    end

    def execute_command(bot, message, parameters)
      forecast_data = WeatherUnderground::Base.new.SimpleForecast(parameters).days[1]

      message.reply("Sorry, couldn't find '#{parameters}'") && return if forecast_data.nil?

      data = WeatherUnderground::Base.new.CurrentObservations(parameters)

      location = data.display_location.first.full

      temperature_fahrenheit = data.temp_f
      temperature_celsius = data.temp_c
      conditions = data.weather.downcase

      updated = Time.parse(data.observation_time).ago.to_words

      message.reply("In #{location} it is #{conditions} and #{temperature_celsius}C/#{temperature_fahrenheit}F (last updated about #{updated}).")
    end
  end

  AIBot::Plugin::register(:weather, WeatherCommand.new)
end