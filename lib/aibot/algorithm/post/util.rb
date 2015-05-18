module AIBot::Algorithm::POST

  ##
  # An array containing part of speech tags that can be replaced.
  REPLACEMENT_TAGS = ['NN', 'NNS', 'JJ', 'JJR', 'JJS', 'UH', 'MD', 'WDT', 'VB', 'VBN']

  ##
  # Indicates whether the given input is worth learning.
  def should_learn(input)
    input.split.length >= 4 && !input.has_hyperlink? && !input.include?("'")
  end

  ##
  # Indicates whether we should replace a word with the given tag.
  def should_replace(tag)
    REPLACEMENT_TAGS.include?(tag)
  end

  ##
  # Tags a sentence. Returns an array of tokens and their tags.
  def tag(tagger, sentence)
    tagged = tagger.add_tags(sentence)
    tagged.split.each do |token|
      token.match(/<\w+>([^<]+)<\/(\w+)>/o) do
        yield($1.downcase, $2.upcase)
      end
    end
  end
end