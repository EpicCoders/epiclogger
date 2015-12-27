FactoryGirl.define do
  factory :issue do
    page_title "Homepage"
    data '[{"data":"<!doctype html>\n<html>\n<head>\n"}]'
    message "Message for issue"
    association :subscriber
  end
end
