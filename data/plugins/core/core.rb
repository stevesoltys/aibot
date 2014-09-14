module Core
  BRAIN_FILE = File.open('data/brain', 'rb')
  BRAIN = Marshal::load(BRAIN_FILE)
  BRAIN_FILE.close


  def respond(username, input)
    input_pairs = get_input_pairs(input)
    return '' if input_pairs.empty?
    pair = input_pairs.keys.sample
    original_pair = pair
    response = "#{pair[0]} #{pair[1]}"
    if rand < 0.5
      BRAIN.each do |brain_pair, words|
        if words.include? pair[0]
          response = "#{brain_pair[0]} #{brain_pair[1]} #{response}"
          break
        end
      end
    end
    pair = original_pair
    max_size = rand(14) + 3
    while BRAIN[pair] and response.split.size < max_size
      word = BRAIN[pair].sample
      BRAIN[pair].shuffle.each do |wrd|
        if input.split.include? wrd
          word = wrd
          break
        end
      end
      response << " #{word}"
      pair = pair[1], word
    end
    response.strip
  end

  def learn_pair(pair, word)
    BRAIN[pair] = [] unless BRAIN[pair]
    BRAIN[pair] << word unless BRAIN[pair].include?(word)
  end

  def get_input_pairs(input)
    pairs = get_pairs(input)
    pairs.each_key do |pair|
      pairs.delete pair unless BRAIN.include? pair
    end
    if pairs.empty?
      rand_pair = BRAIN.keys.sample
      pairs[rand_pair] = BRAIN[rand_pair]
    end
    pairs
  end

  def get_pairs(input)
    words = input.split
    pairs = {}
    return {[words[0], words[1]] => nil} if words.size == 2
    return pairs unless words.size > 2
    index = 0
    while index < words.size - 2
      current_pair = words[index], words[index + 1]
      next_word = words[index + 2]
      pairs[current_pair] = next_word
      index += 1
    end
    pairs
  end

  def learn(input)
    get_pairs(input).each do |pair, word|
      learn_pair pair, word
    end
  end

  def reload
  end

end

schedule 30, TimeUnit::SECONDS do |task|
  file = File.open('data/brain', 'wb')
  Marshal.dump(Core::BRAIN, file)
  file.close
end

FILE = File.open('data/responses.txt', 'rb')
while (line = FILE.gets) != nil
  include Core
  learn line.gsub(/[[:punct:]]/, '').downcase
end
FILE.close