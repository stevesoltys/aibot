require 'rest-client'
require 'json'

module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Rust < CommandPlugin

    MAX_RESPONSE_LENGTH = 120

    def initialize
      super('~', 'rust')
    end

    def execute_command(message, parameters)

      request = {
          'code' => "fn main() { #{parameters} }",
          'version' => 'stable',
          'optimize' => '0',
          'test' => false,
          'separate_output' => true,
          'color' => false
      }.to_json

      json_response = RestClient.post('https://play.rust-lang.org/evaluate.json', request, :content_type => :json, :accept => :json)
      response = JSON::parse(json_response)

      response = (response['program'] || response['rustc']).split(/\r|\n/).first[0, MAX_RESPONSE_LENGTH]

      message.reply("#{message.sender}: => #{response}")
    end
  end

  AIBot::Plugin::register(:rust, Rust.new)
end