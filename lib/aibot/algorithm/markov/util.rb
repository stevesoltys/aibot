class String
  HYPERLINK_HOOKS = %w(http www)

  ##
  # Checks whether a given string contains a hyperlink.
  def has_hyperlink?
    HYPERLINK_HOOKS.each { |string|
      return true if self.include?(string)
    }
    false
  end

  ##
  # Removes all punctuation from this string.
  def remove_punctuation
    gsub /[[:punct:]]/, ''
  end
end

module AIBot::Algorithm::Markov
  module MarkovUtils
    ##
    # Gets the trigram hash for a sentence.
    def get_trigram_hash(sentence)
      sentence = sentence.downcase.strip.split
      pair_hash = {}
      if sentence.size >= 3
        current_pair = sentence[0..1]
        sentence[2..sentence.length].each do |word|
          pair_hash[current_pair.clone] = word
          current_pair.shift
          current_pair << word
        end
        pair_hash
      elsif sentence.size == 2
        {[sentence[0], sentence[1]] => []}
      else
        {}
      end
    end

    ##
    # Gets an array of pair that is bias for words that are in the given sentence. If it cannot find any pairs for the
    # given sentence, it will choose at random.
    def get_start_trigrams(data_store, sentence)
      trigrams = []

      # downcase, strip whitespace, and remove any punctuation from the input sentence
      sentence = sentence.downcase.strip.remove_punctuation

      # look for trigrams which contain words in the sentence and add them
      sentence.split.each do |word|
        trigrams.concat(data_store.execute("SELECT * FROM markov_trigrams WHERE first='#{word}' OR second='#{word}'"))
      end

      # if we didn't find anything, we add a random trigram
      trigrams.concat(data_store.execute('SELECT * FROM markov_trigrams ORDER BY RANDOM() LIMIT 1')) if trigrams.empty?

      # return our results
      return trigrams
    end
  end
end