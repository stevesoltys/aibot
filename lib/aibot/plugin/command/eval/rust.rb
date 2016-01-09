require 'rest-client'
require 'json'

module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Rust < CommandPlugin

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

      response = (response['program'] || response['rustc']).split(/\r|\n/).first

      message.reply("#{message.sender}: => #{response}")
    end
  end

  AIBot::Plugin::register(:rust, Rust.new)
end