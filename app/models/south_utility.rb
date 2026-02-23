class SouthUtility < Utility
  @limit = 60
  class << self
    attr_reader :limit
  end

  def words_length(words)
    return 'short'  if words <= 60
    return 'medium' if words <= 120
    return 'long'
  end

end
