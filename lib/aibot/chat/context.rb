module AIBot
  ##
  # The context of the current chat.
  class ChatContext
    attr_reader :messages

    def initialize
      self.messages = []
    end

    def push_message(message)
      messages << message
      messages.slice
    end
  end
end