class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_and_belongs_to_many :issues, join_table: "subscriber_issues"

  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: :website_id

  def define_role
    member_id = Member.where("email=?", self.email).first.id
    WebsiteMember.where("member_id = ? AND website_id =?", member_id, Website.find(website_id).id).first.role
  end
end
