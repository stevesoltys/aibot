
class String
  HYPERLINK_HOOKS = %w(http www)

  ##
  # Checks whether a given string contains a hyperlink.
  def has_hyperlink?
    HYPERLINK_HOOKS.each { |string|
      return true if self.include?(string)
    }
    false
  end

  ##
  # Removes all punctuation from this string.
  def remove_punctuation
    gsub /[[:punct:]]/, ''
  end

  ##
  # Capitalizes the first character of this string.
  def titleize
    self[0].upcase!
    return self
  end
end