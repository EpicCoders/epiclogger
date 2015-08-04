FactoryGirl.define do
  factory :website do
    title "TestSite 1"
    domain "example.com"
    app_id '123abc'
    app_key 'abc123'
    association :member
  end

end
