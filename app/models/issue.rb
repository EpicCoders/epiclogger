class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  has_and_belongs_to_many :subscribers, join_table: "subscriber_issues"
  belongs_to :website
  enumerize :status, in: {:unresolved => 1, :resolved => 2}, default: :unresolved
  accepts_nested_attributes_for :messages, :subscribers

  validates :description, :presence => true, length: {minimum: 10}

end
