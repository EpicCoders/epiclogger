require 'rails_helper'

describe Issue do

  let(:issue) { build(:issue) }

  it "has a valid factory" do
    expect(build(:issue)).to be_valid
  end

  describe "ActiveRecord associations" do
    it "belongs to subscriber" do
      expect(issue).to belong_to(:subscriber)
    end
  end

  describe "user_agent" do
    it "returns user agent" do
      expect(issue.user_agent.browser).to eq('Chrome')
    end

    it "returns nil if cannot find headers" do
      json = { gogu: 'mafiotu' }.to_json
      issue.update_attributes(data: json)
      expect(issue.user_agent).to be_nil
    end

    it "responds with a message if it cannot parse data" do
      issue.update_attributes(data: "not a json")
      expect(issue.user_agent).to eq('Could not parse data!')
    end
  end

end

