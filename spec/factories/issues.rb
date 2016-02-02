FactoryGirl.define do
  factory :issue do
    data '[{"data":"<!doctype html>\n<html>\n<head>\n"}]'
    message "Message for issue"
    association :subscriber
  end
end
