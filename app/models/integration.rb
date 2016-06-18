class Integration < ActiveRecord::Base
  belongs_to :website
  validates :name, presence: true
  validates :provider, presence: true
  store_accessor :configuration

  def driver
    Integrations.create(self)
  end

  def assign_configuration(auth_hash)
    self.configuration = driver.build_configuration(auth_hash)
    self.provider = driver.type
  end

  def get_applications
    driver.driver.applications
  end
end
