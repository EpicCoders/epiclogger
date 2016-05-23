class Invite < ActiveRecord::Base
  # include the TokenGenerator extension
  include TokenGenerator
  belongs_to :website
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  before_create { generate_token(:token) }

  def accept(user)
    Invite.transaction do
      if website.website_members.find_by_user_id(user.id).blank?
        website.website_members.create!( user: user, role: 'user' )
      end

      self.accepted_at = Time.now
      save
    end
  end

end
