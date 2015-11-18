module AIBot::Algorithm::Markov
  include AIBot::Algorithm

  ##
  # The Markov chat algorithm.
  class MarkovChatAlgorithm < ChatAlgorithm
    include MarkovUtils

    ##
    # Initialize the database.
    def init(data_store)
      data_store.execute('CREATE TABLE IF NOT EXISTS markov_quads(first TEXT NOT NULL, second TEXT NOT NULL, third TEXT NOT NULL, fourth TEXT NOT NULL)')
      data_store.execute('CREATE TABLE IF NOT EXISTS markov_links(first TEXT NOT NULL, second TEXT NOT NULL, third TEXT NOT NULL, before TEXT NOT NULL, after TEXT NOT NULL, PRIMARY KEY (first, second, third))')
    end

    ##
    # Indicates whether the given input is worth learning.
    def should_learn(input)
      input.split.length >= 4 && !input.has_hyperlink?
    end

    ##
    # Learns from the given input, if it is deemed worth learning.
    def learn(data_store, input)
      data_store.transaction do |store|

        quad_hash_for(input.downcase).each do |pair, word|
          store.execute('INSERT OR IGNORE INTO markov_quads VALUES(?, ?, ?, ?)', [pair[0], pair[1], pair[2], word])

          store.execute('INSERT OR IGNORE INTO markov_links VALUES(?, ?, ?, ?, ?)', [pair[0], pair[1], pair[2], '', ''])
          store.execute('INSERT OR IGNORE INTO markov_links VALUES(?, ?, ?, ?, ?)', [pair[1], pair[2], pair[3], '', ''])

          query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=? LIMIT 1'

          before_link = store.execute(query, [pair[0], pair[1], pair[2]]).first

          after = before_link[4].split(' ')

          unless after.include?(word)
            after << word
            after = after.join(' ')

            update_query = 'UPDATE markov_links SET after=? WHERE first=? AND second=? AND third=?'
            store.execute(update_query, [after, pair[0], pair[1], pair[2]])
          end

          after_link = store.execute(query, [pair[1], pair[2], word]).first

          before = after_link[3].split(' ')

          unless before.include?(pair[0])
            before << pair[0]
            before = before.join(' ')

            update_query = 'UPDATE markov_links SET before=? WHERE first=? AND second=? AND third=?'
            store.execute(update_query, [before, pair[1], pair[2], word])
          end
        end

      end if should_learn(input)
    end

    ##
    # Responds to the given input.
    def respond(data_store, input, context)

      # a quad which is bias towards words in our input.
      input_quad = bias_quad_for(data_store, input)

      # start our response with the input quad.
      response = "#{input_quad[0]} #{input_quad[1]} #{input_quad[2]} #{input_quad[3]}"

      # add a random amount of connectible words before our input quad.
      current_quad = input_quad

      data_store.transaction do |store|

        18.times do
          before_quad = connectable_quad_for(store, current_quad, :before)
          break if before_quad.nil?

          current_quad = before_quad

          response = "#{current_quad[0]} #{response}"
        end

        # add a random amount of connectible words after our input quad.
        current_quad = input_quad

        18.times do
          after_quad = connectable_quad_for(store, current_quad, :after)
          break if after_quad.nil?

          current_quad = after_quad

          response = "#{response} #{current_quad[3]}"
        end

      end


      return response.strip
    end

  end

  ##
  # Registers the algorithm under the :markov symbol.
  AIBot::Algorithm::register :markov, MarkovChatAlgorithm.new
end
