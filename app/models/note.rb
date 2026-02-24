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
    content.split.size
  end

  delegate :utility, to: :user

  def content_length
    if utility.name == 'North Utility'
      'short' if word_count <= NorthUtility.short_word_count
      if word_count > NorthUtility.short_word_count && word_count <= NorthUtility.long_word_count
        'medium'
      end
    else
      'short' if word_count <= SouthUtility.short_word_count
      if word_count > SouthUtility.short_word_count && word_count <= SouthUtility.long_word_count
        'medium'
      end
    end
    'long'
  end

  private

  def review_max_length
    return unless review?

    if utility.name == 'North Utility'
      if word_count > NorthUtility::LIMIT
        errors.add(:content,
                   "Too long for review #{user.utility.name} (max #{NorthUtility::LIMIT})")
      end
    elsif word_count > SouthUtility::LIMIT
      errors.add(:content,
                 "Too long for review #{user.utility.name} (max #{SouthUtility::LIMIT})")
    end
  end
end
