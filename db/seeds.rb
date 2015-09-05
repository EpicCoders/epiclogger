# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

member = Member.create(name: 'Test Member', email: 'chocksy@gmail.com', password: 'password', password_confirmation: 'password', uid: SecureRandom.hex(10), provider: :email, confirmed_at: Time.now)
if member.errors.blank?
  website_1 = Website.create(title: 'EpicLogger', domain: 'www.epiclogger.com')
  website_2 = Website.create(title: 'EpicCoders', domain: 'www.epiccoders.com')

  user_1_1 = Subscriber.create(name: 'Gogu', email: 'gogu@gmail.com', website_id: website_1.id)
  user_1_2 = Subscriber.create(name: 'Gogu1', email: 'gogu1@gmail.com', website_id: website_1.id)
  user_1_3 = Subscriber.create(name: 'Gogu2', email: 'gogu2@gmail.com', website_id: website_1.id)
  user_1_4 = Subscriber.create(name: 'Gogu3', email: 'gogu3@gmail.com', website_id: website_1.id)

  user_2_1 = Subscriber.create(name: 'Gogu4', email: 'gogu4@gmail.com', website_id: website_2.id)
  user_2_2 = Subscriber.create(name: 'Gogu5', email: 'gogu5@gmail.com', website_id: website_2.id)
  user_2_3 = Subscriber.create(name: 'Gogu6', email: 'gogu6@gmail.com', website_id: website_2.id)
  user_2_4 = Subscriber.create(name: 'Gogu7', email: 'gogu7@gmail.com', website_id: website_2.id)

  issue_1 = Issue.create(description: 'jQuery is undefined', website_id: website_1.id)
  issue_2 = Issue.create(description: 'Object doesn\'t support property or method "AddEventListener"', website_id: website_1.id)
  issue_3 = Issue.create(description: 'undefined method "first" for nil:NillClass', website_id: website_2.id)

  SubscriberIssue.create(subscriber_id: user_1_1.id, issue_id: issue_1.id)
  SubscriberIssue.create(subscriber_id: user_1_2.id, issue_id: issue_2.id)
  SubscriberIssue.create(subscriber_id: user_1_3.id, issue_id: issue_2.id)
  SubscriberIssue.create(subscriber_id: user_1_4.id, issue_id: issue_1.id)

  SubscriberIssue.create(subscriber_id: user_2_1.id, issue_id: issue_3.id)
  SubscriberIssue.create(subscriber_id: user_2_2.id, issue_id: issue_3.id)
  SubscriberIssue.create(subscriber_id: user_2_3.id, issue_id: issue_3.id)
  SubscriberIssue.create(subscriber_id: user_2_4.id, issue_id: issue_3.id)
  SubscriberIssue.create(subscriber_id: user_2_1.id, issue_id: issue_3.id)

  WebsiteMember.create(member_id: member.id, website_id: website_1.id, role: 1)
else
  puts "Error on user #{member.errors.full_messages}"
end