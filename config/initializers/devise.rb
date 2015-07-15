Devise.setup do |config|
  config.warden do |manager|
    manager.strategies.add(:apikey, Devise::Strategies::Apikey)
    manager.default_strategies(:scope => :user).unshift :apikey
  end
end