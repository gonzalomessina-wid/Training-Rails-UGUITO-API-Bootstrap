FactoryBot.define do
  factory :note do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    note_type { :review }
    user
  end

  trait :review do
    note_type { :review }
  end

  trait :critique do
    note_type { :critique }
  end
end
