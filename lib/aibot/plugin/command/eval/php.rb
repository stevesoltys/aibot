module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class PHP < EvalIn

    def initialize
      super('~', 'php', 'php/php-5.5.14')
    end

    def wrap_code(code)
      code
    end
  end

  AIBot::Plugin::register(:php, PHP.new)
end