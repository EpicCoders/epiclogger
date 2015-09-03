FactoryGirl.define do
  factory :website_member do
    association :website
    association :member
  end

end
