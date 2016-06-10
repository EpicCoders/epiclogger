class Integration < ActiveRecord::Base
  belongs_to :website

  def driver
    Integrations.create(self)
  end

  def assign_configuration(auth_hash)
    self.configuration = driver.build_configuration(auth_hash)
    self.provider = driver.type
  end
end
