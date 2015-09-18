FactoryGirl.define do
  factory :issue do
    page_title "Homepage"
    description "test description for error"
    association :subscriber
    association :group, factory: :grouped_issue
  end
end
