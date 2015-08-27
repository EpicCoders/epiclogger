class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_and_belongs_to_many :issues, join_table: "subscriber_issues"

  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: :website_id
end
