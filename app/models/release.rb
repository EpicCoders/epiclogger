class Release < ActiveRecord::Base
  belongs_to :website
  has_many :grouped_issues
end
