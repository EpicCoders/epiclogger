FactoryGirl.define do
  factory :integration do
    association :website
    provider :github
    sequence(:name) { |n|  "Integration #{n}" }
    configuration { {
                    "uid"=>"12345",
                    "token"=>"",
                    "secret"=>nil,
                    "provider"=>"intercom",
                    "username"=>nil,
                    "refresh_token"=>nil,
                    "token_expires"=>"false",
                    "token_expires_at"=>nil,
                    "selected_application"=>"test"
                  } }
  end
end
