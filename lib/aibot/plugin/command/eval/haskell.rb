module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Haskell < EvalIn

    def initialize
      super('~', 'haskell', 'haskell/hugs98-sep-2006')
    end

    def wrap_code(code)
      "main = print $ #{code}"
    end
  end

  AIBot::Plugin::register(:haskell, Haskell.new)
end