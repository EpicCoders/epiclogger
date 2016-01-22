# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

member = Member.create(name: 'Test Member', email: 'spiridon.alin@gmail.com', password: 'password', password_confirmation: 'password', uid: SecureRandom.hex(10), provider: :email, confirmed_at: Time.now)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
if member_1.errors.blank?
  website_1 = Website.create(title: 'EpicLogger', domain: 'www.epiclogger.com', platform: 'javascript')
  website_2 = Website.create(title: 'EpicCoders', domain: 'www.epiccoders.com', platform: 'ruby')

  # group_1 = GroupedIssue.create(website_id: website_1)
  # group_2 = GroupedIssue.create(website_id: website_2)

  user_1_1 = Subscriber.create(name: 'Gogu', email: 'gogu@gmail.com', website_id: website_1.id)
  user_1_2 = Subscriber.create(name: 'Gogu1', email: 'gogu1@gmail.com', website_id: website_1.id)
  user_1_3 = Subscriber.create(name: 'Gogu2', email: 'gogu2@gmail.com', website_id: website_1.id)
  user_1_4 = Subscriber.create(name: 'Gogu3', email: 'gogu3@gmail.com', website_id: website_1.id)

  user_2_1 = Subscriber.create(name: 'Gogu4', email: 'gogu4@gmail.com', website_id: website_2.id)
  user_2_2 = Subscriber.create(name: 'Gogu5', email: 'gogu5@gmail.com', website_id: website_2.id)
  user_2_3 = Subscriber.create(name: 'Gogu6', email: 'gogu6@gmail.com', website_id: website_2.id)
  user_2_4 = Subscriber.create(name: 'Gogu7', email: 'gogu7@gmail.com', website_id: website_2.id)

  issue_1 = GroupedIssue.create(message: 'jQuery is undefined', website_id: website_1.id)
  issue_2 = GroupedIssue.create(message: 'Object doesn\'t support property or method "AddEventListener"', website_id: website_1.id)
  issue_3 = GroupedIssue.create(message: 'undefined method "first" for nil:NillClass', website_id: website_2.id)

  Issue.create(subscriber_id: user_1_1.id, group_id: issue_1.id)
  Issue.create(subscriber_id: user_1_2.id, group_id: issue_2.id)
  Issue.create(subscriber_id: user_1_3.id, group_id: issue_2.id)
  Issue.create(subscriber_id: user_1_4.id, group_id: issue_1.id)

  Issue.create(subscriber_id: user_2_1.id, group_id: issue_3.id)
  Issue.create(subscriber_id: user_2_2.id, group_id: issue_3.id)
  Issue.create(subscriber_id: user_2_3.id, group_id: issue_3.id)
  Issue.create(subscriber_id: user_2_4.id, group_id: issue_3.id)
  Issue.create(subscriber_id: user_2_1.id, group_id: issue_3.id)

  WebsiteMember.create(member_id: member_1.id, website_id: website_1.id, role: 1)
  WebsiteMember.create(member_id: member_2.id, website_id: website_2.id, role: 1)
else
  puts "Error on user #{member.errors.full_messages}"
end
