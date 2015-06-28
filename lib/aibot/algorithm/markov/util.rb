module AIBot::Algorithm::Markov
  module MarkovUtils

    ##
    # Gets the trigram hash for a sentence.
    def trigram_hash_for(sentence)
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
    # Gets a trigram that is bias for words that are in the given sentence. If it cannot find any trigrams for the given
    # sentence, it will choose at random.
    def bias_trigram_for(data_store, sentence)
      words = sentence.downcase.strip.remove_punctuation.split

      # delete any input words which are not at least three characters long
      words.each { |word| words.delete(word) unless word.size >= 3 }

      # sort our list of input words, based upon size
      words.sort! { |a, b| a.size >= b.size ? 1 : -1 }

      # iterate through the words, attempting to find a trigram which includes our given input word.
      words.each do |word|
        query = "SELECT * FROM markov_trigrams WHERE first='#{word}' OR second='#{word}' OR third='#{word}' " +
            'ORDER BY RANDOM() LIMIT 1'

        trigram = data_store.execute(query).first

        return trigram unless trigram.nil?
      end

      # if nothing was found, select a random trigram.
      return data_store.execute('SELECT * FROM markov_trigrams ORDER BY RANDOM() LIMIT 1').first
    end

    ##
    # Returns a random trigram which can be connected with the given trigram.
    def connectable_trigram_for(data_store, trigram, type)
      case type
        when :before
          query = "SELECT * FROM markov_trigrams WHERE second='#{trigram[0]}' AND third='#{trigram[1]}'" +
              'ORDER BY RANDOM() LIMIT 1'
        when :after
          query = "SELECT * FROM markov_trigrams WHERE first='#{trigram[1]}' AND second='#{trigram[2]}'" +
              'ORDER BY RANDOM() LIMIT 1'
        else
          raise 'Invalid trigram connection type given!'
      end

      return data_store.execute(query).first
    end

  end
end