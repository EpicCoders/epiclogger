class Website < ActiveRecord::Base
  belongs_to :member
  has_many :subscribers, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  # has_many :issues, dependent: :destroy # TODO remove the column website_id from issue
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :members, through: :website_members

  validates :title, :presence => true
  validates :domain, :presence => true

  before_create :generate_keys_for_website

  protected
  def generate_keys_for_website
    self.app_key = loop do
      key = SecureRandom.hex(24)
      break key unless Website.exists?(app_key: key)
    end
    self.app_id = loop do
      id = SecureRandom.hex(6)
      break id unless Website.exists?(app_id: id)
    end
  end

end

