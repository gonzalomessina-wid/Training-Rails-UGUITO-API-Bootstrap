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
  validate :max_length_of_content_allowed
  delegate :utility, to: :user
  belongs_to :user

  def word_count
    content.split.size
  end

  def content_length
    return 'short' if word_count.between?(0, utility.short_word_count)
    return 'medium' if word_count.between?(utility.short_word_count + 1, utility.long_word_count)
    'long'
  end

  private
  def max_length_of_content_allowed
    return unless validate_exceeds_limit?

    errors.add(:content, I18n.t("activerecord.errors.models.too_long"))
  end

  private
  def validate_exceeds_limit?
    review? && content_length != 'short'
  end
end