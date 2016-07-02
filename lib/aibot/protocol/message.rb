module AIBot::Message

  ##
  # A message that has been received by AIBot.
  class Message

    attr_reader :sender, :message

    def initialize(sender, message)
      @sender = sender
      @message = message
    end

    ##
    # Replies to this message.
    def reply(response)
      raise 'SubclassResponsibility'
    end
  end

end