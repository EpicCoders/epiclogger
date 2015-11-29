class Website < ActiveRecord::Base
  belongs_to :member
  has_many :subscribers, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :members, through: :website_members

  validates :title, :presence => true
  validates :domain, :presence => true

  attr_accessor :generate

  before_create :custom_call
  before_update :custom_call

  def custom_call
    if generate
      generate_app_key()
    else
      generate_app_key()
      generate_app_id()
    end
  end

  protected
  def generate_app_key
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

