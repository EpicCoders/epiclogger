require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
  before { @member = FactoryGirl.build(:member) }

  describe "root url" do
    it "should have content", js: true do
      visit root_url
      page.body.should have_xpath("//a[@href = 'http://localhost:3000/login']")
      page.body.should have_xpath("//a[@href = 'http://localhost:3000/signup']")
    end
  end
  describe "login url" do
    before(:each) { visit login_url }

    it 'should sign in member', js: true do
      fill_in 'email', :with => @member.email
      fill_in 'password', :with => @member.password
      click_button 'Sign In'
    end
  end
end
