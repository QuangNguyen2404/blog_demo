# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    
    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, created_by: user)
      end
    end
  end
end
