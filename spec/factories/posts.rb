# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    association :created_by, factory: :user
    
    trait :with_long_title do
      title { Faker::Lorem.sentence(word_count: 20) }
    end
  end
end
