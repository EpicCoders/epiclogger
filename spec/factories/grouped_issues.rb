FactoryGirl.define do
  factory :grouped_issue do
    association :website
    issue_logger 'javascript'
    platform 'javascript'
    level 'error'
    message 'Message for grouped issue'
    status GroupedIssue::UNRESOLVED
    culprit '{"headers":{"User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36"}, "url":"http://192.168.0.103/raven-js/example/index.html"}'
  end
end
