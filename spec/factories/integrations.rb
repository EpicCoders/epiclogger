FactoryGirl.define do
  factory :integration do
    association :website
    provider :intercom
    sequence(:name) { |n|  "Integration #{n}" }
    configuration { { token: { access_token: 'someaccess', expires_in: 10.days.to_i, refresh_token: 'qwe' } } }
  end
end
