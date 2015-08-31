module AIBot::Algorithm::Markov
  module MarkovUtils

    ##
    # Gets the quad hash for a sentence.
    def quad_hash_for(sentence)
      sentence = sentence.downcase.strip.remove_punctuation.split
      quad_hash = {}
      if sentence.size >= 4
        current_quad = sentence[0..2]
        sentence[3..sentence.length].each do |word|
          quad_hash[current_quad.clone] = word
          current_quad.shift
          current_quad << word
        end
        quad_hash
      elsif sentence.size == 3
        {[sentence[0], sentence[1], sentence[2]] => []}
      else
        {}
      end
    end

    ##
    # Gets a quad that is bias for words that are in the given sentence. If it cannot find any quads for the given
    # sentence, it will choose at random.
    def bias_quad_for(data_store, sentence)

      sentence = sentence.downcase.strip.remove_punctuation

      # get all quads for the input sentence
      quads = quad_hash_for(sentence)

      # iterate through the quads, attempting to find a quad which includes three words from the input quad.
      quads.keys.shuffle.each do |pair|
        query = "SELECT * FROM markov_quads WHERE first='#{pair[0]}' AND second='#{pair[1]}' AND third='#{pair[2]}'" +
            'ORDER BY RANDOM() LIMIT 1'

        quad = data_store.execute(query).first

        return quad unless quad.nil?
      end

      # iterate through the quads, attempting to find a quad which includes two words from the input quad.
      quads.keys.shuffle.each do |pair|
        query = "SELECT * FROM markov_quads WHERE first='#{pair[0]}' AND second='#{pair[1]}'" +
            'ORDER BY RANDOM() LIMIT 1'

        quad = data_store.execute(query).first

        return quad unless quad.nil?
      end

      # if we couldn't find a quad match, we get a list of words in the sentence and look for a match
      words = sentence.split

      # delete any input words which are not at least three characters long
      words.each { |word| words.delete(word) unless word.size >= 3 }

      # iterate through the words, attempting to find a quad which includes our given input word.
      words.shuffle.each do |word|
        query = "SELECT * FROM markov_quads WHERE first='#{word}' OR second='#{word}' OR third='#{word}' OR " +
            "fourth='#{word}' ORDER BY RANDOM() LIMIT 1"

        quad = data_store.execute(query).first

        return quad unless quad.nil?
      end

      # if nothing was found, select a random quad.
      return data_store.execute('SELECT * FROM markov_quads ORDER BY RANDOM() LIMIT 1').first
    end

    ##
    # Returns a random quad which can be connected with the given quad.
    def connectable_quad_for(data_store, quad, type)
      case type
        when :before
          query = "SELECT * FROM markov_quads WHERE second='#{quad[0]}' AND third='#{quad[1]}' AND fourth='#{quad[2]}'" +
              'ORDER BY RANDOM() LIMIT 1'
        when :after
          query = "SELECT * FROM markov_quads WHERE first='#{quad[1]}' AND second='#{quad[2]}' AND third='#{quad[3]}'" +
              'ORDER BY RANDOM() LIMIT 1'
        else
          raise 'Invalid quad connection type given!'
      end

      return data_store.execute(query).first
    end

  end
end