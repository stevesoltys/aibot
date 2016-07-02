require 'weather-underground'
require 'time-lord'

module AIBot::Plugin::Weather

  include AIBot::Plugin::Command

  class ForecastCommand < CommandPlugin

    def initialize
      super('~', 'forecast')
    end

    def execute_command(bot, message, parameters)
      data = WeatherUnderground::Base.new.SimpleForecast(parameters).days[1]
      observation_data = WeatherUnderground::Base.new.CurrentObservations(parameters)

      message.reply("Sorry, couldn't find '#{parameters}'") && return if data.nil?

      location = observation_data.display_location.first.full
      forecast = data.conditions.downcase
      temp_high_farenheit = data.high.fahrenheit.round
      temp_low_farenheit = data.low.fahrenheit.round
      temp_high_celsius = data.high.celsius.round
      temp_low_celsius = data.low.celsius.round

      message.reply("Tommorrow in #{location}; #{forecast}, high of #{temp_high_celsius}C/#{temp_high_farenheit}F, low of #{temp_low_celsius}C/#{temp_low_farenheit}F.")
    end
  end

  AIBot::Plugin::register(:forecast, ForecastCommand.new)
end