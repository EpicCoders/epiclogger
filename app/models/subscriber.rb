class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_and_belongs_to_many :issues, join_table: "subscriber_issues"

  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: :website_id

  def define_role
    if !Member.find_by_email(self.email).nil?
      WebsiteMember.where("member_id = ? AND website_id =?", Member.find_by_email(self.email).id, Website.find(website_id).id).first.role
    end
  end
end
