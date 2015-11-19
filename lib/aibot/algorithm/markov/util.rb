module AIBot::Algorithm::Markov
  module MarkovUtils

    ##
    # Gets the quad hash for a sentence.
    def quad_hash_for(sentence)
      sentence = sentence.downcase.strip.split

      if sentence.size >= 4

        quad_hash = {}
        current_quad = sentence[0..2]

        sentence[3..sentence.length].each do |word|
          quad_hash[current_quad.clone] = word
          current_quad.shift
          current_quad << word
        end

        return quad_hash

      elsif sentence.size == 3
        return {[sentence[0], sentence[1], sentence[2]] => []}
      elsif sentence.size == 2
        return {[sentence[0], sentence[1]] => []}
      else
        return {}
      end
    end

    ##
    # Gets a quad that is bias for words that are in the given sentence. If it cannot find any quads for the given
    # sentence, it will choose at random.
    def bias_quad_for(data_store, sentence)

      sentence = sentence.downcase.remove_punctuation.strip
      words = sentence.split

      # get all quads for the input sentence
      quads = quad_hash_for(sentence)

      # the result quad
      result = nil

      # iterate through the quads, attempting to find a quad which includes three words from the input quad.
      if words.size > 2
        data_store.transaction do |store|
          quads.keys.shuffle.each do |pair|
            if pair.size > 2
              query = 'SELECT * FROM markov_quads WHERE first=? AND second=? AND third=?'

              result = store.execute(query, [pair[0], pair[1], pair[2]]).sample

              break unless result.nil?
            end
          end
        end

        return result unless result.nil?
      end


      # iterate through the quads, attempting to find a quad which includes two words from the input quad.
      if words.size > 1
        data_store.transaction do |store|
          quads.keys.shuffle.each do |pair|
            query = 'SELECT * FROM markov_quads WHERE first=? AND second=?'

            result = store.execute(query, [pair[0], pair[1]]).sample

            break unless result.nil?
          end
        end

        return result unless result.nil?
      end


      # delete any input words which are not at least three characters long
      words.each { |word| words.delete(word) unless word.size >= 3 }

      # iterate through the words, attempting to find a quad which includes our given input word.
      unless words.empty?
        data_store.transaction do |store|
          words.shuffle.each do |word|
            query = 'SELECT * FROM markov_quads WHERE first=? OR second=? OR third=? OR fourth=?'

            result = store.execute(query, [word, word, word, word]).sample

            break unless result.nil?
          end
        end

        return result unless result.nil?
      end

      # if nothing was found, select a random quad.
      return data_store.execute('SELECT * FROM markov_quads ORDER BY RANDOM() LIMIT 1').first
    end

    ##
    # Returns a random quad which can be connected with the given quad.
    def connectable_quad_for(data_store, quad, type)
      case type
        when :before
          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=? ORDER BY RANDOM() LIMIT 1'

          link = data_store.execute(query, [quad[0], quad[1], quad[2]]).first
          return nil if link.nil?

          before_list = link[3].split(' ')
          return nil if before_list.empty?

          return [before_list.sample, quad[0], quad[1], quad[2]]
        when :after
          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=? ORDER BY RANDOM() LIMIT 1'

          link = data_store.execute(query, [quad[1], quad[2], quad[3]]).first
          return nil if link.nil?

          after_list = link[4].split(' ')
          return nil if after_list.empty?

          return [quad[1], quad[2], quad[3], after_list.sample]
        else
          raise 'Invalid quad connection type given!'
      end
    end

  end
end