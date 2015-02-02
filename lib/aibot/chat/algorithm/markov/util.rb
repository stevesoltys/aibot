class String
  ##
  # Removes all punctuation from this string.
  def remove_punctuation
    gsub /[[:punct:]]/, ''
  end
end

module AIBot
  module MarkovUtils
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
    # Gets the <i>Triad</i> hash for a sentence.
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
    # Gets an array of <i>Triad</i> that is bias for words that
    # are in the given sentence. If it cannot find any triads
    # for the given sentence, it will choose at random.
    def get_triads(data_store, sentence)
      sentence = sentence.downcase.strip.remove_punctuation
      # first, we get the triads for the sentence
      triads = get_triad_hash(sentence).keys
      # next, we delete any triads that our data store doesn't contain
      triads.each { |triad| triads.delete(triad) unless data_store.has?(triad) }
      # if our hash is empty, we look for triads that contain words in the sentence and add them
      if triads.empty?
        data_store.keys.each do |triad|
          triad.each do |word|
            # if our sentence contains a word that this one does, we add it
            if sentence.split.include? word.remove_punctuation
              triads << triad
              break
            end
          end
        end
      end
      # if we still didn't find anything, we add a random triad
      triads << data_store.keys.sample if triads.empty?
      # time to return the triads
      triads
    end
  end
end