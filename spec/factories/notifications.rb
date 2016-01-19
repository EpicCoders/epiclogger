FactoryGirl.define do
  factory :notification do
    association :website
    new_event false
    daily false
    realtime false
    frequent_event false
  end
end
