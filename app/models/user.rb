class User < ActiveRecord::Base
  belongs_to :website
  has_and_belongs_to_many :issues, join_table: "user_issues"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :website, :presence => true
end
