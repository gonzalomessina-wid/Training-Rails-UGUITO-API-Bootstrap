# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :text
#  note_type  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#

class Note < ApplicationRecord
  enum note_type: { review:   0,
                    comment:  1 
                  }

  validates :title, :content, :note_type, :user_id, presence: true

  belongs_to :user
end
