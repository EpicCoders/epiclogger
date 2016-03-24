require 'rails_helper'

describe GroupedIssue do
  let(:grouped_issue) { build(:grouped_issue) }
  # it { is_expected.to enumerize(:level).in(:debug, :error, :fatal, :info, :warning).with_default(:error) }
  # it { is_expected.to enumerize(:issue_logger).in(:javascript, :php).with_default(:javascript) }
  it { is_expected.to enumerize(:status).in(:muted, :resolved, :unresolved) }

  it "has a valid factory" do
    expect(grouped_issue).to be_valid
  end
end
