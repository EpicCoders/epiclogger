require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
  describe "signup" do
    before(:each) { visit signup_url }
    let(:submit) { 'Sign Up' }

    describe "with invalid information" do
      it "should not create member", js: true do
        expect { click_button submit }.to change(Member, :count).by(0)
      end

      it "validates form when blank", js: true do
        click_button submit
        page.should have_content("Your name is required")
        page.should have_content("Please enter an email")
        page.should have_content("Please enter a password")
        page.should have_content("Please enter the password confirmation")
      end

      it "validates password minlength", js: true do
        fill_in 'name', :with => 'Tester'
        fill_in 'email', :with => 'tester@gmail.com'
        fill_in 'password', :with => 'parola123'
        fill_in 'password_confirm', :with => 'parola1234'
        click_button submit
        page.should have_content("Your passwords do not match")
      end

      it "validates email field", js: true do
        fill_in 'name', :with => 'Tester'
        fill_in 'email', :with => 'tester@.com'
        fill_in 'password', :with => 'parola123'
        fill_in 'password_confirm', :with => 'parola123'
        click_button submit
        page.should have_content("Please enter a valid email")
      end
    end
    describe 'valid information' do
      before do
        fill_in 'name', with: "Tester"
        fill_in 'email', with: "tester@mail.com"
        fill_in 'password', :with => 'parola123'
        fill_in 'password_confirm', :with => 'parola123'
      end
      # it "should create member", js: true do
      #   expect { click_button submit }.to change(Member, :count).by(1)
      #   expect(page.current_path).to eq("/login")
      # end
    end
  end
end