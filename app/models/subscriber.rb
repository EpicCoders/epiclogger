class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_many :issues
  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: :website_id
end
