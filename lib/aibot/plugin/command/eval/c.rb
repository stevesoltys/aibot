module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class CLang < EvalIn

    DEFAULT_INCLUDES = %w(stdio.h string.h stdio.h stdbool.h stdint.h errno.h time.h math.h assert.h stddef.h signal.h)

    def initialize
      super('~', 'c', 'c/gcc-4.9.1')
    end

    def wrap_code(code)
      DEFAULT_INCLUDES.each { |default_include| code = "#include<#{default_include}>\n#{code}" }

      code
    end
  end

  AIBot::Plugin::register(:c, CLang.new)
end