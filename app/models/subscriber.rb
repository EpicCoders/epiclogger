class Subscriber < ActiveRecord::Base
  belongs_to :website
  has_many :issues, :dependent => :destroy
  validates_presence_of :name, :email, :website
  validates_uniqueness_of :email, scope: [:website_id, :identity]

  before_validation :check_fields

  def check_fields
    self.name = email.partition('@').first if name.blank?
  end

  def avatar_url(size = 40)
    gravatar = Digest::MD5.hexdigest(email).downcase
    "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end
end
