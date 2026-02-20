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
  validate :content_length
  validate :review_max_length

  belongs_to :user

  def self.word_count(note_id)
    note = find(note_id)
    count = note.content.split.size
    Rails.logger.debug "The note has #{count} words."
  end

  def content_length
    words = content.to_s.split.size
    utility = user.utility

    case utility.name
    when 'North Utility'
      return 'short'  if words <= 50
      return 'medium' if words <= 100
      'long'
    when 'South Utility'
      return 'short'  if words <= 60
      return 'medium' if words <= 120
      'long'
    else
      'unknown'
    end
  end

  private

  def review_max_length
    return unless review?

    words = content.to_s.split.size
    limit = user.utility.name == 'North Utility' ? 50 : 60

    if words > limit
      errors.add(:content,
                 "es demasiado largo para una reseña en #{user.utility.name} (máximo #{limit} palabras)")
    end
  end
end
