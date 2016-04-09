FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    name "Test User 1"
    provider "email"
    confirmed_at Time.now
    password "hello123"
    password_confirmation "hello123"
  end
end
