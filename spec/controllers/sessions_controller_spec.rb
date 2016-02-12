require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
  before(:each) do
    controller.class.skip_before_filter :authenticate_member!
  end

  describe "root url" do
    it "should have content", js: true do
      visit root_url
      page.body.should have_xpath("//a[@href = 'http://localhost:3000/login']")
      page.body.should have_xpath("//a[@href = 'http://localhost:3000/signup']")
    end
  end
  describe "login url" do
    it 'should sign in member', js: true do
      member = create(:member)
      website = create(:website)
      website_member = create(:website_member, website: website, member: member)
      # visit login_url
      page.driver.set_cookie("pickedWebsite", website.id)
      login_with(member)
      binding.pry
      # page.driver.add_headers(member.create_new_auth_token)
      # visit login_url
      # fill_in "email", :with => member.email
      # fill_in "password", :with => member.password
      # click_button "Sign In"
    end
  end
end
