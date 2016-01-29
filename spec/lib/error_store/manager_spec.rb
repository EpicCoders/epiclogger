require 'rails_helper'

RSpec.describe ErrorStore::Manager do
  xdescribe 'initialize' do
    it 'assigns data and version'
  end

  xdescribe 'store_error' do
    it 'saves the provided checksum'
    it 'creates hash from fingerprint'
    it 'creates a new issue without subscriber'
    it 'creates a new issue with subscriber'
    it 'creates issue if it fails once'
    it 'does not save issue if it fails twice'
    it 'saves group_issue if new'
    it 'does not save group_issue if already there'
    it 'creates issue with already there group_issue'
  end

  xdescribe '_save_aggregate' do
    it 'returns the new group'
    it 'returns the existing group by hash/checksum'
    it 'returns is_sample false if group new'
    it 'returns is_sample false if is_regression (resolved group gone unresolved)'
    it 'returns is_sample true if it can_sample'
    it 'creates a new grouped_issue'
  end

  xdescribe 'should_sample' do
    it 'returns false if '
  end
end
