FactoryGirl.define do
  factory :issue do
    page_title "Homepage"
    description "test description for error"
    association :website
  end
end
