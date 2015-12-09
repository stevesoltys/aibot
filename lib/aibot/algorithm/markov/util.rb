module AIBot::Algorithm::Markov
  module MarkovUtils

    ##
    # An array of quads for a sentence.
    def quads_for(sentence)
      sentence = sentence.strip.split

      if sentence.size >= 4

        quads = []
        current_quad = sentence[0..3]

        sentence[4..sentence.length].each do |word|
          quads << current_quad.clone

          current_quad.shift
          current_quad << word
        end

        quads << current_quad.clone

        return quads
      else
        raise 'Sentence is too small.'
      end
    end

    ##
    # Gets a link that is bias for words that are in the given sentence. If it cannot find any links for the given
    # sentence, it will choose at random.
    def bias_link_for(data_store, sentence)

      sentence = sentence.downcase.remove_punctuation.strip
      words = sentence.split

      # the result links
      results = []

      if words.size >= 4
        quads = quads_for(sentence)

        quads.shuffle.each do |quad|
          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=?'

          result_quads = data_store.execute(query, quad[0..2])
          results.concat(result_quads)

          break unless results.empty?
        end

      elsif words.length == 3
        query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=?'

        result_links = data_store.execute(query, words)
        results.concat(result_links)

      elsif words.length == 2
        query = 'SELECT * FROM markov_links WHERE first=? AND second=?'

        result_links = data_store.execute(query, words)
        results.concat(result_links)

      elsif words.length == 1
        word = words.first

        result_count = data_store.execute('SELECT count(*) FROM markov_links WHERE first=?', [word]).first.first.to_i
        query = 'SELECT * FROM markov_links WHERE first=? LIMIT 1 OFFSET ?'

        if result_count > 0
          result_links = data_store.execute(query, [word, rand(result_count)])
          results.concat(result_links)
        end
      end

      # if we have any results, return one
      return results.sample unless results.empty?

      # iterate through the words, attempting to find a link which includes our given input word.
      words.shuffle.each do |word|
        result_count = data_store.execute('SELECT count(*) FROM markov_links WHERE first=?', [word]).first.first.to_i

        if result_count > 0
          query = 'SELECT * FROM markov_links WHERE first=? LIMIT 1 OFFSET ?'
          results.concat(data_store.execute(query, [word, rand(result_count)]))
        end

        break unless results.empty?
      end

      # if nothing was found, select a random link.
      if results.empty?
        num_rows = data_store.execute('SELECT MAX(rowid) FROM markov_links').first.first.to_i
        results.concat(data_store.execute('SELECT * FROM markov_links WHERE rowid=?', [rand(num_rows)]))
      end

      # return a random result
      return results.sample
    end

    ##
    # Returns a random quad which can be connected with the given quad.
    def connectable_quad_for(data_store, quad, type)
      case type
        when :before
          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=?'

          link = data_store.execute(query, [quad[0], quad[1], quad[2]]).sample
          return nil if link.nil?

          before_list = link[3].split(' ')
          return nil if before_list.empty?

          return [before_list.sample, quad[0], quad[1], quad[2]]
        when :after
          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=?'

          link = data_store.execute(query, [quad[1], quad[2], quad[3]]).sample
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