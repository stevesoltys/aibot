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
      sentence = sentence.downcase.strip.remove_punctuation.split
      trigram_hash = {}
      if sentence.size >= 3
        current_trigram = sentence[0..1]
        sentence[2..sentence.length].each do |word|
          trigram_hash[current_trigram.clone] = word
          current_trigram.shift
          current_trigram << word
        end
        trigram_hash
      elsif sentence.size == 2
        {[sentence[0], sentence[1]] => []}
      else
        {}
      end
    end

    ##
    # Gets an array of trigrams that is bias for words that are in the given sentence. If it cannot find any trigrams
    # for the given sentence, it will choose at random.
    def get_start_trigrams(data_store, sentence)
      trigrams = []

      # downcase, strip whitespace, and remove any punctuation from the input sentence
      sentence = sentence.downcase.strip.remove_punctuation

      # generate a trigram hash for this sentence
      sentence_trigram_hash = get_trigram_hash(sentence)

      # look for trigrams which are entirely contained in the sentence and add them
      sentence_trigram_hash.each do |pair, word|
        query = "SELECT * FROM markov_trigrams WHERE first='#{pair[0]}' AND second='#{pair[1]}' AND third='#{word}'"
        trigrams.concat(data_store.execute(query))
      end

      # look for trigrams which contain pairs in the sentence and add them, if the current list is empty
      sentence_trigram_hash.each do |pair, word|
        query = "SELECT * FROM markov_trigrams WHERE first='#{pair[0]}' AND second='#{pair[1]}'"
        trigrams.concat(data_store.execute(query))
      end if trigrams.empty?

      # look for trigrams which contain any 'important' words in the sentence and add them
      sentence.split.each do |word|
        query = "SELECT * FROM markov_trigrams WHERE first='#{word}' OR second='#{word}' OR third='#{word}'"
        trigrams.concat(data_store.execute(query)) if word.size >= 4
      end

      # if we didn't find anything, we add a random trigram
      trigrams.concat(data_store.execute('SELECT * FROM markov_trigrams ORDER BY RANDOM() LIMIT 1')) if trigrams.empty?

      # return our results
      return trigrams
    end
  end
end