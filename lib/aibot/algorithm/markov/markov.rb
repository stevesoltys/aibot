module AIBot::Algorithm::Markov
  include AIBot::Algorithm

  ##
  # The Markov chat algorithm.
  class MarkovChatAlgorithm < ChatAlgorithm
    include MarkovUtils

    ##
    # Intialize the database.
    def init(data_store)
      data_store.execute('CREATE TABLE IF NOT EXISTS markov_trigrams(first TEXT NOT NULL, second TEXT NOT NULL, third TEXT NOT NULL)')
    end

    ##
    # Indicates whether the given input is worth learning.
    def should_learn(input)
      input.split.length >= 3 && !input.has_hyperlink?
    end

    ##
    # Learns from the given input, if it is deemed worth learning.
    def learn(data_store, input)
      data_store.transaction do |store|
        trigram_hash_for(input.downcase).each do |pair, word|
          store.execute("INSERT OR IGNORE INTO markov_trigrams VALUES('#{pair[0]}', '#{pair[1]}', '#{word}')")
        end
      end if should_learn(input)
    end

    ##
    # Responds to the given input.
    def respond(data_store, input, context)
      # a trigram which is bias towards words in our input.
      input_trigram = bias_trigram_for(data_store, input)

      # start our response with the input trigram.
      response = "#{input_trigram[0]} #{input_trigram[1]} #{input_trigram[2]}"

      # add a random amount of connectable words before our input trigram. the maximum is five.
      current_trigram = input_trigram

      rand(6).times do
        before_trigram = connectable_trigram_for(data_store, current_trigram, :before)
        break if before_trigram.nil?

        current_trigram = before_trigram

        response = "#{current_trigram[0]} #{response}"
      end

      # add a random amount of connectable words after our input trigram. the maximum is five.
      current_trigram = input_trigram

      rand(8).times do
        after_trigram = connectable_trigram_for(data_store, current_trigram, :after)
        break if after_trigram.nil?

        current_trigram = after_trigram

        response = "#{response} #{current_trigram[2]}"
      end

      return response.strip
    end

  end

  ##
  # Registers the algorithm under the :markov symbol.
  AIBot::Algorithm::register :markov, MarkovChatAlgorithm.new
end