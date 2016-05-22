FactoryGirl.define do
  factory :invite do
    association :website
    invited_by_id  1
    sequence(:email) { |n| "person#{n}@example.com" }
    token "sJCyJOe72EgbDIHA-x82Ow"
  end

end
