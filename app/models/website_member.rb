class WebsiteMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  belongs_to :member
  enumerize :role, in: { owner: 1, user: 2 }, default: :user, scope: true
  before_create :generate_token

  before_destroy :validate_destroy

  def validate_destroy
    owners = WebsiteMember.with_role(:owner).where('website_id=?', website.id)
    return unless owners.count == 1
    errors.add :base, 'Website must have at least one owner'
    false
  end

  def generate_token
    self.invitation_token = loop do
      token = SecureRandom.hex(10)
      break token unless WebsiteMember.exists?(invitation_token: token)
    end
  end
end
