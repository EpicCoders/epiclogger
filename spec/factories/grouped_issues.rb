FactoryGirl.define do
  factory :grouped_issue do
  	association :website
    issue_logger 1
    platform 1
    level 4
    message "Message for grouped issue"
    status 3
    data "text here"
  end
end
