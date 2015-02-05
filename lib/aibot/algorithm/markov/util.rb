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
    # Gets the pair hash for a sentence.
    def get_pair_hash(sentence)
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
    # Gets the triad hash for a sentence.
    def get_triad_hash(sentence)
      sentence = sentence.downcase.strip.split
      if sentence.size >= 4
        triad_hash = {}
        current_triad = sentence[0..2]
        sentence[3..sentence.length].each do |word|
          triad_hash[current_triad.clone] = word
          current_triad.shift
          current_triad << word
        end
        triad_hash
      else
        {}
      end
    end

    ##
    # Gets an array of triad that is bias for words that
    # are in the given sentence. If it cannot find any triads
    # for the given sentence, it will choose at random.
    def get_start_triads(data_store, sentence)
      sentence = sentence.downcase.strip.remove_punctuation
      # first, we get the triads for the sentence
      triads = get_triad_hash(sentence).keys
      # next, we delete any triads that our data store doesn't contain
      triads.each { |triad| triads.delete(triad) unless data_store.has?(triad) }
      # we look for triads that contain words in the sentence and add them
      data_store.keys.each do |triad|
        word_match_count = 0
        # if our sentence contains a word that this triad does, we add to our match count
        triad.each { |word| word_match_count += 1 if sentence.split.include?(word.remove_punctuation) }
        # if two or more words matched, we add the triad to our list
        triads << triad.clone if word_match_count >= (sentence.split.size == 1 ? 1 : 2)
      end
      # if we still didn't find anything, we add a random triad
      triads << data_store.keys.sample.clone if triads.empty?
      # time to return the triads
      triads
    end

    ##
    # Gets an array of triad that is bias for words that
    # are in the given sentence. If it cannot find any triads
    # for the given sentence, it will choose at random.
    def get_start_pairs(data_store, sentence)
      sentence = sentence.downcase.strip.remove_punctuation
      # first, we get the pairs for the sentence
      pairs = get_pair_hash(sentence).keys
      # next, we delete any pairs that our data store doesn't contain
      pairs.each { |pair| pairs.delete(pair) unless data_store.has?(pair) }
      # we look for pairs that contain words in the sentence and add them, if our pairs are empty
      if pairs.empty?
        data_store.keys.each do |pair|
          # if our sentence contains a word that this pair does, we add it to our list
          pair.each { |word| pairs << pair.clone if sentence.split.include?(word.remove_punctuation) }
        end
      end
      # if we still didn't find anything, we add a random pair
      pairs << data_store.keys.sample.clone if pairs.empty?
      # time to return the pairs
      pairs
    end
  end
end