module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Perl < EvalIn

    def initialize
      super('~', 'perl', 'perl/perl-5.20.0')
    end

    def wrap_code(code)
      code
    end
  end

  AIBot::Plugin::register(:perl, Perl.new)
end