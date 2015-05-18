module AIBot::Algorithm::POST

  ##
  # An array containing part of speech tags that can be replaced.
  REPLACEMENT_TAGS = ['NN', 'NNS', 'JJ', 'JJR', 'JJS', 'UH', 'MD', 'WDT', 'VB', 'VBN']

  ##
  # An array containing part of speech tags which flag for us to ignore certain input while learning.
  IGNORE_TAGS = ['SYM', 'PPD', 'PPL', 'PPR', 'LRB', 'RRB', 'FW', 'LS']

  ##
  # Indicates whether the given input is worth learning.
  def should_learn(tagger, input)
    tag(tagger, input) do |token, tag|
      return false if IGNORE_TAGS.include?(tag)
    end
    return (4..15).include?(input.split.length) && !input.has_hyperlink?
  end

  ##
  # Indicates whether we should replace a word with the given tag.
  def should_replace(tag)
    return REPLACEMENT_TAGS.include?(tag)
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