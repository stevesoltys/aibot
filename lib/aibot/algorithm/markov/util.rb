module AIBot::Algorithm::Markov
  module MarkovUtils

    ##
    # Gets the quad hash for a sentence.
    def quad_hash_for(sentence)
      sentence = sentence.downcase.strip.split
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

      sentence = sentence.downcase.strip

      # get all quads for the input sentence
      quads = quad_hash_for(sentence)

      # iterate through the quads, attempting to find a quad which includes three words from the input quad.
      quads.keys.shuffle.each do |pair|
        query = 'SELECT * FROM markov_quads WHERE first=? AND second=? AND third=? ORDER BY RANDOM() LIMIT 1'

        quad = data_store.execute(query, [pair[0], pair[1], pair[2]]).first

        return quad unless quad.nil?
      end

      # iterate through the quads, attempting to find a quad which includes two words from the input quad.
      quads.keys.shuffle.each do |pair|
        query = 'SELECT * FROM markov_quads WHERE first=? AND second=? ORDER BY RANDOM() LIMIT 1'

        quad = data_store.execute(query, [pair[0], pair[1]]).first

        return quad unless quad.nil?
      end

      # if we couldn't find a quad match, we get a list of words in the sentence and look for a match
      words = sentence.split

      # delete any input words which are not at least three characters long
      words.each { |word| words.delete(word) unless word.size >= 3 }

      # iterate through the words, attempting to find a quad which includes our given input word.
      words.shuffle.each do |word|
        query = 'SELECT * FROM markov_quads WHERE first=? OR second=? OR third=? OR fourth=? ORDER BY RANDOM() LIMIT 1'

        quad = data_store.execute(query, [word, word, word, word]).first

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
          query = 'SELECT * FROM markov_quads WHERE second=? AND third=? AND fourth=? ORDER BY RANDOM() LIMIT 1'
          return data_store.execute(query, [quad[0], quad[1], quad[2]]).first
        when :after
          query = 'SELECT * FROM markov_quads WHERE first=? AND second=? AND third=? ORDER BY RANDOM() LIMIT 1'
          return data_store.execute(query, [quad[1], quad[2], quad[3]]).first
        else
          raise 'Invalid quad connection type given!'
      end
    end

  end
end