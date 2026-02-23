FactoryBot.define do
  factory :note do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    note_type { :review }
    user

    trait :review do
      note_type { :review }
    end

    trait :critique do
      note_type { :critique }
    end

    trait :short_content do
      content { 'palabra ' * 10 }
    end

    trait :medium_content do
      content { 'palabra ' * 75 }
    end

    trait :long_content do
      content { 'palabra ' * 150 }
    end
  end
end
