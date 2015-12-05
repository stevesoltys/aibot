module AIBot::Algorithm::Markov
  include AIBot::Algorithm

  ##
  # The Markov chat algorithm.
  class MarkovChatAlgorithm < ChatAlgorithm
    include MarkovUtils

    ##
    # Initialize the database.
    def init(data_store)
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
      quads_for(input.downcase).each do |quad|

        data_store.execute('INSERT OR IGNORE INTO markov_links VALUES(?, ?, ?, ?, ?)', [quad[0], quad[1], quad[2], '', ''])

        query = 'SELECT * FROM markov_links WHERE first=? AND second=? AND third=? LIMIT 1'

        before_link = data_store.execute(query, [quad[0], quad[1], quad[2]]).first
        after = before_link[4].split(' ')

        unless after.include?(quad[3])
          after << quad[3]
          after = after.join(' ')

          update_query = 'UPDATE markov_links SET after=? WHERE first=? AND second=? AND third=?'
          data_store.execute(update_query, [after, quad[0], quad[1], quad[2]])
        end

        data_store.execute('INSERT OR IGNORE INTO markov_links VALUES(?, ?, ?, ?, ?)', [quad[1], quad[2], quad[3], '', ''])

        after_link = data_store.execute(query, [quad[1], quad[2], quad[3]]).first
        before = after_link[3].split(' ')

        unless before.include?(quad[0])
          before << quad[0]
          before = before.join(' ')

          update_query = 'UPDATE markov_links SET before=? WHERE first=? AND second=? AND third=?'
          data_store.execute(update_query, [before, quad[1], quad[2], quad[3]])
        end

      end if should_learn(input)
    end

    ##
    # Responds to the given input.
    def respond(data_store, input, context)

      # a quad which is bias towards words in our input.
      input_link = bias_link_for(data_store, input)

      # input quads, combined from the input link
      input_quads = []

      # list of words that come after the input link
      after_list = input_link[4].split
      input_quads << [input_link[0], input_link[1], input_link[2], after_list.sample] unless after_list.empty?

      # list of words that come before the input link
      before_list = input_link[3].split
      input_quads << [before_list.sample, input_link[0], input_link[1], input_link[2]] unless before_list.empty?

      # select a random input quad
      input_quad = input_quads.sample

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
