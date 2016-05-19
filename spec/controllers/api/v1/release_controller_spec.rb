require 'rails_helper'

describe Api::V1::ReleaseController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:release) { create :release, website: website }
  let!(:group) { create :grouped_issue, website: website, release: release }

  describe 'POST #create' do
    context 'when release changed' do
      let(:params) { { "id": "1",
                       "app": "ravenapp-test",
                       "url": "http://ravenapp-test.herokuapp.com",
                       "head": "c8b1da1",
                       "user": "panioglo.srj@gmail.com",
                       "action": "create",
                       "format": "json",
                       "git_log": " * panioglo: update",
                       "release": "v18",
                       "app_uuid": "31cc9d59-5608-4ab9-ba11-b14691738dbb",
                       "head_long": "c8b1da16bd2860fb252cb738660b48201ea1a09f",
                       "prev_head": "862c28f5604030e37889bbd10742b0ba2dcb77bc",
                       "controller": "api/v1/release"
                      }
                    }
      it 'should update the release' do
        expect {
            post_with user, :create, params
            group.reload
          }.to change { group.status }.from('unresolved').to('resolved')
           .and change(Release, :count).by(1)
      end
    end

    context 'with same release' do
      let(:params) { { "id": "1",
                         "app": "ravenapp-test",
                         "url": "http://ravenapp-test.herokuapp.com",
                         "head": "51bda24",
                         "user": "panioglo.srj@gmail.com",
                         "action": "create",
                         "format": "json",
                         "git_log": " * panioglo: sa",
                         "release": "v16",
                         "app_uuid": "31cc9d59-5608-4ab9-ba11-b14691738dbb",
                         "head_long": "51bda2437170d7d5fe39fb358db9af51baf91c1e",
                         "prev_head": "3dcb9cdb0c6c1efaa64be6134728d9d4a1360a73",
                         "controller": "api/v1/release"
                      }
                    }
      it 'should not create new release' do
        expect{
            post_with user, :create, params
          }.to change(Release, :count).by(0)
      end

      it 'should not update group status' do
        expect {
            post_with user, :create, params
            group.reload
          }.not_to change(group, :status).from('unresolved')
      end

      it 'should not update the release' do
        expect {
            post_with user, :create, params
            group.reload
          }.not_to change(group, :release_id)
      end
    end
  end
end
