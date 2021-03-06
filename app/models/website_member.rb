class WebsiteMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  belongs_to :user
  scope :with_realtime, -> { where(realtime: true) }
  scope :with_frequent_event, -> { where(frequent_event: true) }
  enumerize :role, in: { owner: 1, user: 2 }, default: :user, scope: true
  before_create :valid_url

  before_destroy :validate_destroy
  validates :user_id, uniqueness: { scope: [:website_id] }

  def valid_url
    valid = (self.website.domain =~ /\A#{URI::regexp(['http', 'https'])}\z/).nil?
    return true unless valid
    errors.add :domain, 'Invalid url' if valid
    false
  end

  def validate_destroy
    owners = WebsiteMember.with_role(:owner).where('website_id=?', website.id)
    if owners.count == 1 && website.website_members.count == 1
      errors.add :base, 'Website must have at least one owner'
      return false
    end
    return true
  end
end
