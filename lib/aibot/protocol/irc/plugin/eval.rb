# This is a modified version of https://github.com/charliesome/cinch-eval-in
require 'cinch'

require 'uri'
require 'net/http'
require 'nokogiri'

module Cinch::Plugins

  class Evaluate
    include Cinch::Plugin

    LANGUAGE_ALIASES = {
        :c => 'c/gcc-4.9.1',
        :cpp => 'c++/gcc-4.9.1',
        :coffeescript => 'coffeescript/node-0.10.29-coffee-1.7.1',
        :haskell => 'haskell/hugs98-sep-2006',
        :javascript => 'javascript/node-0.10.29',
        :lua => 'lua/lua-5.2.3',
        :ocaml => 'ocaml/ocaml-4.01.0',
        :php => 'php/php-5.5.14',
        :pascal => 'pascal/fpc-2.6.4',
        :perl => 'perl/perl-5.20.0',
        :python => 'python/cpython-3.4.1',
        :ruby => 'ruby/mri-2.1',
        :slash => 'slash/slash-head',
        :assembly => 'assembly/nasm-2.07'
    }
    LANGUAGE_ALIASES.each_key { |name| match(/(#{name})\s(.*)\z/) }

    SERVICE_URI = URI('https://eval.in/')
    MAX_RESPONSE_LENGTH = 80

    def execute(msg, language, code)
      msg.reply("=> #{evaluate(language, code)}", true)
    end

    def evaluate(language, code)
      code = ruby_template(code) if language.eql?('ruby')

      result = Net::HTTP.post_form(SERVICE_URI,
                                   'utf8' => 'λ',
                                   'code' => code,
                                   'execute' => 'on',
                                   'lang' => LANGUAGE_ALIASES[language.to_sym],
                                   'input' => '')

      if result.is_a?(Net::HTTPFound)
        location = URI(result['location'])
        location.scheme = 'https'
        location.port = 443

        body = Nokogiri(Net::HTTP.get(location))

        if (output_title = body.at_xpath("*//h2[text()='Program Output']"))

          output = output_title.next_element.text

          first_line = (output.each_line.first || '').chomp
          needs_ellipsis = output.each_line.count > 1 || first_line.length > MAX_RESPONSE_LENGTH

          "#{first_line[0, MAX_RESPONSE_LENGTH]}#{'...' if needs_ellipsis} (#{location})"
        else
          raise "Couldn't find program result."
        end

      else
        raise "Communication exception: #{result}"
      end

    end

    def ruby_template(code)
      <<eot
begin
  puts eval(DATA.read).inspect
rescue Exception => e
  $stderr.puts "\#{e.class}: \#{e}"
end
__END__
#{code}
eot
    end
  end
end