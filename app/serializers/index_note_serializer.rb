class IndexNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :word_count, :content_length
end