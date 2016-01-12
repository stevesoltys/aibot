module AIBot::Plugin::Eval

  include AIBot::Plugin::Command

  class Ruby < EvalIn

    def initialize
      super('~', 'ruby', 'ruby/mri-2.1')
    end

    def wrap_code(code)
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

  AIBot::Plugin::register(:ruby, Ruby.new)
end