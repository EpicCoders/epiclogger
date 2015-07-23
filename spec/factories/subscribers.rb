FactoryGirl.define do
  factory :subscriber do
    name "Test User 1"
    email "testuser@google.com"
    association :website

    # issues {[FactoryGirl.create(:issue)]}
  end

end
