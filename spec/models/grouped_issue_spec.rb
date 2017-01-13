require 'rails_helper'

describe GroupedIssue do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:grouped_issue) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: grouped_issue }
  it { is_expected.to enumerize(:level).in(:debug, :error, :fatal, :info, :warning).with_default(:error) }
  it { is_expected.to enumerize(:status).in(:muted, :resolved, :unresolved) }

  it 'has many subscribers' do
    expect(subject).to have_many(:subscribers).through(:issues)
  end

  it 'has many issues' do
    expect(subject).to have_many(:issues)
  end

  it 'has many messages' do
    expect(subject).to have_many(:messages).through(:issues)
  end

  it "has a valid factory" do
    expect(grouped_issue).to be_valid
  end
end
