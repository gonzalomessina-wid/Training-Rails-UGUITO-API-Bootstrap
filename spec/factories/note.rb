FactoryBot.define do
  factory :note do
    title { Faker::Movies::Hackers.name }
    content { Faker::Lorem.words }
    note_type { "review"}
    user_id { 1 }
  end
end
