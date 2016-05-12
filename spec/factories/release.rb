FactoryGirl.define do
  factory :release do
    association :website
    version "51bda2437170d7d5fe39fb358db9af51baf91c1e"
    data '{"id": "1", "app": "ravenapp-test", "url": "http://ravenapp-test.herokuapp.com", "head": "51bda24", "user": "panioglo.srj@gmail.com", "action": "create", "format": "json", "git_log": " * panioglo: sa", "release": "v16", "app_uuid": "31cc9d59-5608-4ab9-ba11-b14691738dbb", "head_long": "51bda2437170d7d5fe39fb358db9af51baf91c1e", "prev_head": "3dcb9cdb0c6c1efaa64be6134728d9d4a1360a73", "controller": "api/v1/release"}'
  end

end
