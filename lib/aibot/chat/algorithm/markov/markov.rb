require 'aibot/chat/algorithm/markov/util'

module AIBot
  ##
  # The Markov learning algorithm.
  class MarkovLearningAlgorithm < LearningAlgorithm
    include MarkovUtils

    def should_learn(input)
      input.split.length >= 4 && !has_hyperlink?(input)
    end

    def learn(data_store, input)
      if should_learn input
        data_store.transaction do
          get_triad_hash(input.downcase).each do |triad, word|
            words = data_store.has?(triad) ? data_store.get(triad) : []
            words << word unless words.include? word
            data_store.put(triad, words)
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
        # we get our bias triad list
        triads = get_triads(data_store, input)
        # next, we start our response with a random triad from our list
        current_triad = triads.sample
        response = current_triad.join(' ')
        # randomly defines the max size of the response
        max_size = rand(12) + 6
        # we loop and add to our response, without going over the maximum size
        while data_store.has?(current_triad) && response.split.size < max_size
          words = data_store.get(current_triad)
          bias_word = words.sample # random, if we don't find a match in our input
          # we iterate through each word our triad is mapped to
          words.shuffle.each do |word|
            # if a word is included in our input, we choose that one
            if input.split.include? word
              bias_word = word
              break
            end
          end
          # add our (hopefully) bias word to the response
          response << " #{bias_word}"
          # pop the first word in our triad and insert the bias word as the last
          current_triad.shift
          current_triad << bias_word
        end
        response.strip
      end
    end
  end
end