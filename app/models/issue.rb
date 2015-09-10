class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  has_and_belongs_to_many :subscribers, join_table: "subscriber_issues"
  belongs_to :website
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
  accepts_nested_attributes_for :messages, :subscribers

  validates :description, :presence => true, length: {minimum: 10}

end
