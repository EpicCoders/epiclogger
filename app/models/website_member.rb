class Message < ActiveRecord::Base
  belongs_to :website
  belongs_to :member
end
