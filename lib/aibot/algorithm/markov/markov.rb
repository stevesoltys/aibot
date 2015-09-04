module AIBot::Algorithm::Markov
  include AIBot::Algorithm

  ##
  # The Markov chat algorithm.
  class MarkovChatAlgorithm < ChatAlgorithm
    include MarkovUtils

    ##
    # Intialize the database.
    def init(data_store)
      data_store.execute('CREATE TABLE IF NOT EXISTS markov_quads(first TEXT NOT NULL, second TEXT NOT NULL, third TEXT NOT NULL, fourth TEXT NOT NULL)')
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

      # add a random amount of connectable words before our input quad. the maximum is five.
      current_quad = input_quad

      rand(7..12).times do
        before_quad = connectable_quad_for(data_store, current_quad, :before)
        break if before_quad.nil?

        current_quad = before_quad

        response = "#{current_quad[0]} #{response}"
      end

      # add a random amount of connectable words after our input quad. the maximum is five.
      current_quad = input_quad

      rand(7..12).times do
        after_quad = connectable_quad_for(data_store, current_quad, :after)
        break if after_quad.nil?

        current_quad = after_quad

        response = "#{response} #{current_quad[3]}"
      end

      return response.strip
    end

  end

  ##
  # Registers the algorithm under the :markov symbol.
  AIBot::Algorithm::register :markov, MarkovChatAlgorithm.new
end