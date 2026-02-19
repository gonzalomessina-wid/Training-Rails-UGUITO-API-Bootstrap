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

  belongs_to :user

  def self.word_count(note_id)
    note = find(note_id)
    count = note.content.split.size
    Rails.logger.debug "The note has #{count} words."
  end
end
