class Integration < ActiveRecord::Base
  belongs_to :website

  def driver
    Integrations.create(self)
  end

  def connect(auth_hash)
    self.configuration = driver.connect(auth_hash)
    self.provider = driver.type
  end
end
