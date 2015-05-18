require 'engtagger'

module AIBot::Algorithm::POST
  include AIBot::Algorithm

  ##
  # The 'Part Of Speech Tagger' chat algorithm.
  class POSTChatAlgorithm < ChatAlgorithm
    include AIBot::Algorithm::POST

    ##
    # Intialize the algorithm.
    def init(data_store)
      data_store.execute('CREATE TABLE IF NOT EXISTS post_tokens(token TEXT NOT NULL, tag TEXT NOT NULL)')
      data_store.execute('CREATE TABLE IF NOT EXISTS post_sentences(sentence TEXT NOT NULL)')
      @tagger = EngTagger.new
    end

    ##
    # Learns from the given input, if it is deemed worth learning.
    def learn(data_store, input)
      data_store.transaction do |store|
        @tagger.get_sentences(input).each do |sentence|
          tag(@tagger, sentence.titleize) do |token, tag|
            store.execute('INSERT OR IGNORE INTO post_tokens(token, tag) VALUES(?, ?)', [token, tag]) if token.size >= 3
          end

          store.execute('INSERT OR IGNORE INTO post_sentences(sentence) VALUES(?)', sentence)
        end
      end if should_learn(input)
    end

    ##
    # Responds to the given input.
    def respond(data_store, input, context)
      response_sentences = []

      @tagger.get_sentences(input).each do |sentence|
        response = []

        # select a random sentence from our 'sentence structure' table
        random_sentence = data_store.execute('SELECT * FROM post_sentences ORDER BY RANDOM() LIMIT 1').flatten.first
        tag(@tagger, random_sentence.titleize) do |token, tag|
          if should_replace(tag)
            response_token = nil

            # attempt to find bias tokens for this tag
            sentence.downcase.remove_punctuation.split.each do |input_token|
              query = 'SELECT * FROM post_tokens WHERE token=? AND tag=?'
              results = data_store.execute(query, [input_token, tag])
              puts "#{input_token}, #{tag}: #{results.flatten.first}"
              unless results.empty? || response.join.include?(input_token)
                response_token = results.flatten.first
                break
              end
            end

            # select a random word with the same tag our current token
            query = 'SELECT * FROM post_tokens WHERE tag=? ORDER BY RANDOM() LIMIT 1'
            response_token = data_store.execute(query, [tag]).flatten.first if response_token.nil?

            # default to the random sentence's token if we can't find anything else
            response_token = token if response_token.nil?
          else
            response_token = token
          end

          # add a space before our token, unless our token is punctuation
          response_token = " #{response_token}" unless tag.start_with?('PP')

          response << response_token
        end

        response_sentences << response.join.strip
      end

      return response_sentences.join(' ').strip
    end
  end

  ##
  # Registers the algorithm under the :post symbol.
  AIBot::Algorithm::register(:post, POSTChatAlgorithm.new)
end