class NorthUtility < Utility
  @limit = 50
  class << self
    attr_reader :limit
  end

  def words_length(words)
    return 'short'  if words <= 50
    return 'medium' if words <= 100
    return 'long'
  end
end
