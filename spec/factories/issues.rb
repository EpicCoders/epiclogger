FactoryGirl.define do
  factory :issue do
  	platform 'javascript'
  	event_id SecureRandom.hex()
  	time_spent 1
  	datetime Time.now.utc
    data '[{"data":"<!doctype html>\n<html>\n<head>\n"}]'
    message "ZeroDivisionError: divided by 0"
    association :subscriber
    association :website
  end
end
