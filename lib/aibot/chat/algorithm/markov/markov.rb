require 'aibot/chat/algorithm/markov/util'

module AIBot
  ##
  # The Markov learning algorithm.
  class MarkovLearningAlgorithm < LearningAlgorithm
    include MarkovUtils

    def should_learn(input)
      input.split.length >= 3 && !input.has_hyperlink?
    end

    def learn(data_store, input)
      if should_learn input
        data_store.transaction do
          get_triad_hash(input.downcase).each do |pair, word|
            words = data_store.has?(pair) ? data_store.get(pair) : []
            words << word unless words.include? word
            data_store.put(pair, words)
          end
        end
      end
    end
  end

  ##
  # The Markov response algorithm.
  class MarkovResponseAlgorithm < ResponseAlgorithm
    include MarkovUtils

    def respond(data_store, input, context)
      data_store.transaction do
        # we get our bias start pair list
        pairs = get_start_pairs(data_store, input)
        # next, we start our response with a random pair from our list
        current_pair = pairs.sample
        response = current_pair.join(' ')
        # randomly defines the max size of the response
        max_size = rand(12) + 6
        # we loop and add to our response, without going over the maximum size
        while data_store.has?(current_pair) && response.split.size < max_size
          words = data_store.get(current_pair)
          bias_word = words.sample # random, if we don't find a match in our input
          # we iterate through each word our pair is mapped to
          words.shuffle.each do |word|
            # if a word is included in our input, we choose that one
            if input.split.include? word
              bias_word = word
              break
            end
          end
          # add our (hopefully) bias word to the response
          response << " #{bias_word}"
          # pop the first word in our pair and insert the bias word as the last
          current_pair.shift
          current_pair << bias_word
        end
        response.strip
      end
    end
  end
end