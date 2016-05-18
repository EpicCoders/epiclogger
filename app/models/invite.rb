class Invite < ActiveRecord::Base
  # include the TokenGenerator extension
  include TokenGenerator
  belongs_to :website
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  before_create { generate_token(:token) }
end
