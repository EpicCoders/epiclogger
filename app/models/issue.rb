class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  belongs_to :subscriber
  belongs_to :website
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
  accepts_nested_attributes_for :messages
  enumerize :platform, in: {:javascript => 1, :php => 2}, default: :javascript

  validates :description, :presence => true, length: {minimum: 10}
  after_create :issue_created

  def issue_created
    UserMailer.error_occurred(self.group.website_id).deliver
  end

end
