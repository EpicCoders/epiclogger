class Website < ActiveRecord::Base
  belongs_to :member
  has_many :subscribers, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true, inverse_of: :website
  has_many :members, through: :website_members, inverse_of: :website

  validates :title, :presence => true
  validates :domain, :presence => true
  validates :member, :presence => true

  before_create :generate_keys_for_website

  protected
  def generate_keys_for_website
    self.app_key = loop do
      key = SecureRandom.urlsafe_base64
      break key unless Website.exists?(app_key: key)
    end
    self.app_id = loop do
      id = SecureRandom.urlsafe_base64(6, false)
      break id unless Website.exists?(app_id: id)
    end
  end

end

