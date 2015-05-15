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
        get_trigram_hash(input.downcase).each do |pair, word|
          store.execute("INSERT OR IGNORE INTO markov_trigrams VALUES('#{pair[0]}', '#{pair[1]}', '#{word}')")
        end
      end if should_learn(input)
    end

    ##
    # Responds to the given input.
    def respond(data_store, input, context)
      input = substitute_words(input)

      # we get our bias start trigram list
      trigrams = get_start_trigrams(data_store, input)

      # next, we start our response with a random trigram from our list
      current_trigram = trigrams.sample
      response = "#{current_trigram[0]} #{current_trigram[1]} #{current_trigram[2]}"

      # randomly defines the max size of the response
      max_size = rand(12) + 6

      # we loop and add to our response, without going over the maximum size
      while response.split.size < max_size
        # select trigrams which start with the last two tokens in our current trigram
        results = data_store.execute("SELECT * FROM markov_trigrams WHERE first='#{current_trigram[1]}' AND second='#{current_trigram[2]}'")

        # if there are no results, we can't continue
        break if results.empty?

        bias_word = results.sample[2] # random, if we don't find a match in our input

        # we iterate through each word our trigram is mapped to
        results.shuffle.each do |result|
          # if a word is included in our input, we choose that one
          bias_word = result && break if input.split.include?(result[2])
        end

        # add our (hopefully) bias word to the response
        response << " #{bias_word}"

        # pop the first word in our trigram and insert the bias word as the last
        current_trigram.shift
        current_trigram << bias_word
      end
      response.strip
    end
  end

  ##
  # Registers the algorithm under the :markov symbol.
  AIBot::Algorithm::register :markov, MarkovChatAlgorithm.new
end