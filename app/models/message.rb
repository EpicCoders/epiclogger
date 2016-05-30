class Message < ActiveRecord::Base
  belongs_to :issue

  delegate :subscriber, to: :issue

  validates :content, presence: true, length: { minimum: 10 }
  validates :issue, presence: true
  after_create :issue_created

  def issue_created
    UserMailer.error_occurred(self.issue.group.website_id, self.id).deliver_later
  end
end
