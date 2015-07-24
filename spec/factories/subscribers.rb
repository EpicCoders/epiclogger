FactoryGirl.define do
  factory :subscriber do
    name Faker::Name.name
    sequence(:email) { |n| "person#{n}@example.com" }
    association :website
  end

end
