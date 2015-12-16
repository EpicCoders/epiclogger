Devise.setup do |config|
  config.warden do |manager|
    manager.strategies.add(:apikey, Devise::Strategies::Apikey)
    manager.default_strategies(:scope => :user).unshift :apikey
  end
  config.allow_unconfirmed_access_for = 1.days
end