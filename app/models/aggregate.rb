class Aggregate < ActiveRecord::Base
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: group_id
end