require 'rest-client'
require 'json'

module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Rust < CommandPlugin

    RESOURCE_URL = 'https://play.rust-lang.org/evaluate.json'

    MAX_RESPONSE_LENGTH = 120

    def initialize
      super('~', 'rust')
    end

    def execute_command(bot, message, parameters)

      request = {
          'code' => wrap_code(parameters),
          'version' => 'stable',
          'optimize' => '0',
          'test' => false,
          'separate_output' => true,
          'color' => false
      }.to_json

      json_response = RestClient.post(RESOURCE_URL, request, :content_type => :json, :accept => :json)
      response = JSON::parse(json_response)

      response = (response['program'] || response['rustc']).split(/\r|\n/).first[0, MAX_RESPONSE_LENGTH]

      message.reply("#{message.sender}: => #{response}")
    end

    def wrap_code(code)
      <<eot
#![allow(dead_code, unused_variables)]
static VERSION: &'static str = "%(version)s";
fn show<T: std::fmt::Debug>(e: T) { println!("{:?}", e) }
fn main() {
    show({
        #{code}
    });
}
eot
    end

  end

  AIBot::Plugin::register(:rust, Rust.new)
end