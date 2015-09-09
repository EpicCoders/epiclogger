require 'rails_helper'

describe GroupedIssue do
  it { is_expected.to enumerize(:level).in(debug: 1, error: 2, fatal: 3, info: 4, warning: 5).with_default(:error) }
  it { is_expected.to enumerize(:issue_logger).in(javascript: 1, php: 2).with_default(:javascript) }
  it { is_expected.to enumerize(:status).in(muted: 1, resolved: 2, unresolved: 3) }
  let(:grouped_issue) { build(:grouped_issue) }

  it "has a valid factory" do
    expect(build(:grouped_issue)).to be_valid
  end
end
