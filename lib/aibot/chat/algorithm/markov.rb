module AIBot
  module MarkovUtil
    HYPERLINK_HOOKS = %w(http www)

    ##
    # Checks whether a given string contains a hyperlink.
    def has_hyperlink?(message)
      HYPERLINK_HOOKS.each do |string|
        return true if message.include? string
      end
      false
    end

    ##
    # Gets the markov pairs for the given string.
    def get_pairs(input)
      words = input.split
      pairs = {}
      return {[words[0], words[1]] => nil} if words.size == 2
      return pairs unless words.size > 2
      index = 0
      while index < words.size - 2
        current_pair = words[index], words[index + 1]
        next_word = words[index + 2]
        pairs[current_pair] = next_word
        index += 1
      end
      pairs
    end

    ##
    # Gets the markov pairs, given the data store and the string. This method
    # only returns pairs which our database already contains.
    def get_input_pairs(data_store, input)
      pairs = get_pairs(input)
      pairs.each_key do |pair|
        pairs.delete pair unless data_store.has?(pair)
      end

      if pairs.empty?
        topics = input.split
        data_store.keys.each do |pair|
          if topics.include? pair[0].gsub(/[[:punct:]]/, '') or
              topics.include? pair[1].gsub(/[[:punct:]]/, '')
            pairs[pair] = data_store.get(pair)
          end
        end
      end

      if pairs.empty?
        rand_pair = data_store.keys.sample
        pairs[rand_pair] = data_store.get(rand_pair) if rand_pair
      end
      pairs
    end
  end

  ##
  # The Markov learning algorithm.
  class MarkovLearningAlgorithm < LearningAlgorithm
    include MarkovUtil

    def learn(data_store, input)
      unless has_hyperlink? input
        input = input.downcase #gsub(/[[:punct:]]/, '')
        get_pairs(input).each do |pair, word|
          data_store.put(pair, []) unless data_store.has?(pair)
          data_store.get(pair) << word
        end
      end
    end
  end

  ##
  # The Markov response algorithm.
  class MarkovResponseAlgorithm < ResponseAlgorithm
    include MarkovUtil

    def respond(data_store, input, context)
      input = input.gsub(/[[:punct:]]/, '').downcase
      input_pairs = get_input_pairs(data_store, input)
      return '' if input_pairs.empty?
      pair = input_pairs.keys.sample
      original_pair = pair
      response = "#{pair[0]} #{pair[1]}"
      if rand < 0.5
        data_store.data.each do |brain_pair, words|
          if words.include? pair[0]
            response = "#{brain_pair[0]} #{brain_pair[1]} #{response}"
            break
          end
        end
      end
      pair = original_pair
      max_size = rand(14) + 3
      while data_store.has?(pair) and response.split.size < max_size
        word = data_store.get(pair).sample
        data_store.get(pair).shuffle.each do |wrd|
          if input.split.include? wrd
            word = wrd
            break
          end
        end
        response << " #{word}"
        pair = pair[1], word
      end
      response.strip
    end
  end
end