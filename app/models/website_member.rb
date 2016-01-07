class WebsiteMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  belongs_to :member
  enumerize :role, in: {:owner => 1, :user => 2}, default: :user, scope: true
  before_create :generate_token

  validate :unique_domain, :on => :create

  def unique_domain
    domain = URI.parse(self.website.domain)
    website_cases = ["http://#{domain.host}", "https://#{domain.host}", "ftp://#{domain.host}"]
    errors.add :website, 'This website already exists for you' if Website.where("domain IN (?)", website_cases).count > 1
  end


  def generate_token
    self.invitation_token = loop do
      token = SecureRandom.hex(10)
      break token unless WebsiteMember.exists?(invitation_token: token)
    end
  end
end
