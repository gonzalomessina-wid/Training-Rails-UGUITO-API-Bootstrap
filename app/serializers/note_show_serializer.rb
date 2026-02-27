class NoteShowSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :word_count, :content_length, :created_at, :content
  belongs_to :user, serializer: UserSerializer
end