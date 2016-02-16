FactoryGirl.define do
  factory :grouped_issue do
    association :website
    issue_logger 'javascript'
    platform 'javascript'
    level 'error'
    times_seen 2
    first_seen 1.day.ago
    last_seen Time.now.utc
    time_spent_count 2
    message 'ZeroDivisionError: divided by 0'
    status GroupedIssue::UNRESOLVED
    culprit 'app/controllers/home_controller.rb in / at line 5'
    checksum 'bba2f06a21e44216df5a1bfccda72e8e'
  end
end
