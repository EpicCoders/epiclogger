require 'rails_helper'

describe "Auth API" do
  let!(:user) { create :user }
  let!(:website) { create :website  }
  let!(:website_member) { create :website_member, website: website, user: user }

  it 'can login with valid credentials' do
    post '/api/v1/auth/sign_in', {email: user.email, password: "hello123"}
    expect(response).to be_success
  end

  it 'fails to login with invalid credentials' do
    post '/api/v1/auth/sign_in', {email: user.email, password: "123456"}
    expect(response).to have_http_status(:unauthorized)
  end

  it 'has access once logged in' do
    post '/api/v1/auth/sign_in', {email: user.email, password: "hello123"}
    expect(response).to be_success

    get '/api/v1/errors',{website_id: website.id}, {"client" => response.headers["client"], "uid" => response.headers["uid"], "access-token"=> response.headers["access-token"], "expiry" => response.headers["expiry"], "token-type" => response.headers["token-type"]}
    expect(response).to be_success

    json = JSON.parse(response.body)
    expect(json).to eq({'groups'=> [], 'page' => 0, 'pages' => 0})
  end

end