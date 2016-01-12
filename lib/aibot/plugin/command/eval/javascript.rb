module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Javascript < EvalIn

    def initialize
      super('~', 'javascript', 'javascript/node-0.10.29')
    end

    def wrap_code(code)
      code
    end
  end

  AIBot::Plugin::register(:javascript, Javascript.new)
end