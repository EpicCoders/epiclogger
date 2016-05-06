class Release < ActiveRecord::Base
  belongs_to :website
  has_one :grouped_issue
end
