class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_many :issues
  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: :website_id

  before_validation :check_fields

  def check_fields
    self.name = email.partition('@').first if name.blank?
  end
end
