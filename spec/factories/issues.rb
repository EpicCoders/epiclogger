FactoryGirl.define do
  factory :issue do
    page_title "Homepage"
    description '[{"descr":"<title>Scratch Disk</title>\n"}]'
    data '[{"data":"<!doctype html>\n<html>\n<head>\n"}]'
    association :subscriber
    association :group, factory: :grouped_issue
  end
end
