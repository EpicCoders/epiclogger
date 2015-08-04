require 'rails_helper'

describe Api::V1::ApiController, :type => :controller do
	let!(:member) { FactoryGirl.create(:member) }
	 let(:website) { create :website, app_id: 'adsada2sda', app_key: 'asdafe2da1', member: member }

	describe '#current_site' do

		it 'should get current site' do
			post '/api/v1/errors', {website_id: website.id, format: :json}, {app_id: 'adsada2sda', app_key: 'asdafe2da1'}
			expect(assigns(:current_site)).to eq(website)
	    expect(response).to be_success

	    json = JSON.parse(response.body)
	    expect(json).to eq({'errors'=> []})
		end
	end

end