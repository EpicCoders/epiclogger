class WebsiteMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  belongs_to :member
  enumerize :role, in: {:owner => 1, :user => 2}, default: :user
end
