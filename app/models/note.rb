# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null

class Note < ApplicationRecord
  enum note_type: { review: 0,
                    critique: 1 }

  validates :title, :content, :note_type, :user_id, presence: true
  validate :review_max_length

  belongs_to :user

  def word_count
    return content.split.size
  end

  def get_utility
    return user.utility
  end

  def content_length
    words = word_count()
    utility = get_utility()
    if utility.name == 'North Utility'
      return utility.words_length(words)
    else
      return utility.words_length(words)
    end
  end

  private
  def review_max_length
    return unless review?

    words = word_count()
    limit = user.utility.class.limit

    if words > limit
      errors.add(:content,
                 "es demasiado largo para una reseña en #{user.utility.name} (máximo #{limit} palabras)")
    end
  end
end
