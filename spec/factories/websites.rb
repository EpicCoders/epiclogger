FactoryGirl.define do
  factory :website do
    title "TestSite 1"
    sequence(:domain) { |n| "http://example#{n}.com" }
  end
end
