require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'

module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  ##
  # A plugin which uses "https://eval.in" to execute user submitted code and reply with the program's standard output.
  class EvalIn < CommandPlugin

    ##
    # The resource url for an <i>EvalIn</i> plugin.
    RESOURCE_URL = URI('https://eval.in')

    ##
    # The maximum length of a response message.
    MAX_RESPONSE_LENGTH = 120

    ##
    # The language being used.
    attr_reader :language

    def initialize(prefix, command, language)
      super(prefix, command)

      @language = language
    end

    ##
    # Executes a command, given the <i>Message</i> and parameters.
    def execute_command(message, parameters)

      request = {
          'utf8' => 'λ',
          'code' => wrap_code(parameters),
          'execute' => 'on',
          'lang' => language,
          'input' => ''
      }

      result = Net::HTTP.post_form(RESOURCE_URL, request)

      location = URI(result['location'])
      location.scheme = 'https'
      location.port = 443

      body = Nokogiri(Net::HTTP.get(location))

      if (output_title = body.at_xpath("*//h2[text()='Program Output']"))

        output = output_title.next_element.text

        first_line = (output.each_line.first || '').chomp
        needs_ellipsis = output.each_line.count > 1 || first_line.length > MAX_RESPONSE_LENGTH

        message.reply("#{message.sender} => #{first_line[0, MAX_RESPONSE_LENGTH]} #{'...' if needs_ellipsis} (#{location})")
      else
        message.reply("#{message.sender}: Couldn't find program result, please report this bug.")
      end

    end

    ##
    # Wraps the given code in a template. This is dependant upon the language being used.
    def wrap_code(code)
      raise 'SubclassResponsibility'
    end
  end

end