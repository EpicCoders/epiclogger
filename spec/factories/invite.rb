FactoryGirl.define do
  factory :invite do
    association :website
    association :invited_by_id, factory: :user
    sequence(:email) { |n| "person#{n+1}@example.com" }
    token "sJCyJOe72EgbDIHA-x82Ow"
  end

end
