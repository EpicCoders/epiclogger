require 'rails_helper'

describe Website do

  let(:user) { create :user }
  let!(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user, daily_reporting: true, weekly_reporting: true }
  let!(:release) { create :release, website: website }
  let!(:group) { create :grouped_issue, website: website }

  it "has a valid factory" do
    expect(build(:website)).to be_valid
  end

  describe "ActiveModel validations" do
    it "adds http to website" do
      website2 = create :website, domain: "simple-string.com"
      expect(website2.domain).to eq("http://simple-string.com")
    end

    it "returns same if valid" do
      website2 = create :website, domain: "http://valid-website.com"
      website3 = create :website, domain: "https://secured-website.com"
      expect(website2.domain).to eq("http://valid-website.com")
      expect(website3.domain).to eq("https://secured-website.com")
    end

    it "is invalid without a title" do
      expect(website).to validate_presence_of :title
    end

    it "is invalid without a domain" do
      expect(website).to validate_presence_of :domain
    end
  end

   describe "ActiveRecord associations" do
    it "has many subscribers" do
      expect(website).to have_many(:subscribers)
    end

    it "has many members" do
      expect(website).to have_many(:users)
    end

    it "has many members" do
      expect(website).to have_many(:website_members)
    end
   end

  describe 'before create' do
    it 'should add app_key and app_secret to website' do
      website = Website.new(domain: 'domain@example.com', title: 'title for page')
      website.save
      expect(website.app_key).not_to be_nil
      expect(website.app_secret).not_to be_nil
    end
  end

  describe 'ensure_valid_protocol_for_origins' do
    it 'should return asterik' do
      expect( website.ensure_valid_protocol_for_origins("*") ).to eq("*")
    end
    context 'with protocol' do
      it 'returns unchanged' do
        expect( website.ensure_valid_protocol_for_origins("http://gicu-boevicu.com") ).to eq("http://gicu-boevicu.com")
        expect( website.ensure_valid_protocol_for_origins("https://gicu-boevicu.com") ).to eq("https://gicu-boevicu.com")

        expect( website.ensure_valid_protocol_for_origins("http://gicu-boevicu.com\nhttp://epiclogger.com") ).to eq("http://gicu-boevicu.com\nhttp://epiclogger.com")
      end
    end
    context 'without protocol' do
      it 'returns * if balnk origins' do
        expect( website.ensure_valid_protocol_for_origins("") ).to eq("*")
      end

      it 'should add http to origin' do
        expect( website.ensure_valid_protocol_for_origins("website.com") ).to include("http://")
      end

      it 'adds protocol where protocol is needed' do
        expect( website.ensure_valid_protocol_for_origins("website.com\nhttp://gicu-boevicu.com\nhttps://epiclogger.com") ).to eq("http://website.com\nhttp://gicu-boevicu.com\nhttps://epiclogger.com")
      end

      it 'should include http twice' do
        expect( website.ensure_valid_protocol_for_origins("website1.com\nwebsite2.com").scan(/(?=#{'http://'})/).count ).to eq(2)
      end

      it 'should split and join new line' do
        expect( website.ensure_valid_protocol_for_origins("website1.com\nwebsite2.com") ).to eq("http://website1.com\nhttp://website2.com")
      end
    end
  end

  describe 'unique_domain' do
    it 'should raise exception' do
      expect { create :website, domain: website.domain }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it 'should return false' do
      expect( website.unique_domain ).to be(false)
    end

    it 'allows to create record' do
      expect{ create :website, domain: 'http://not-in-db.com' }.to change{ Website.count }.by(1)
    end
  end

  describe 'check_release' do
    it 'returns last release' do
      expect(website.check_release(nil)).to eq(Release.last)
    end

    it 'creates release' do
      website.check_release('51bda2437170d7d5fe39fb358db9af51baf92c6e')
      expect(Release.last.version).to eq('51bda2437170d7d5fe39fb358db9af51baf92c6e')
    end

    it 'resolves the errors in the previous release' do
      error = FactoryGirl.create(:grouped_issue, checksum: SecureRandom.hex(), release: release, website: website, status: GroupedIssue::UNRESOLVED, resolved_at: nil )
      website.check_release('51bda2437170d7d5fe39fb358db9af51baf92c6e')
      error.reload
      expect(error.status).to eq(GroupedIssue::RESOLVED)
      expect(error.resolved_at).to_not be_nil
    end
  end

  describe 'custom_report' do
    it 'should email users' do
      mailer = double('GroupedIssueMailer')
      expect(mailer).to receive(:deliver_later)
      expect(GroupedIssueMailer).to receive(:notify_daily).with(website_member).and_return(mailer).once

      date = Time.now - 1.day
      Website.custom_report(date, 'daily_reporting')
    end

    it 'should email users' do
      mailer = double('GroupedIssueMailer')
      expect(mailer).to receive(:deliver_later)
      expect(GroupedIssueMailer).to receive(:notify_weekly).with(website_member).and_return(mailer).once

      date = Time.now - 1.week
      Website.custom_report(date, 'weekly_reporting')
    end
  end

  describe 'valid_origin?' do
    it 'returns true' do
      expect(website.valid_origin?('http://192.168.2.3')).to eq(true)
    end

    it 'returns false if blank origins' do
      website.update_attributes(origins: '')
      expect(website.valid_origin?('http://192.168.2.3')).to eq(false)
    end

    it 'returns false if blank value' do
      website.update_attributes(origins: 'http://192.168.2.3')
      expect(website.valid_origin?('')).to eq(false)
    end

    it 'returns true if includes value' do
      website.update_attributes(origins: 'http://192.168.2.3')
      expect(website.valid_origin?('http://192.168.2.3')).to eq(true)
    end

    it 'calls downcase on value' do
      website.update_attributes(origins: 'http://192.168.2.3')
      expect(website.valid_origin?('HTTP://192.168.2.3')).to eq(true)
    end
  end
end

