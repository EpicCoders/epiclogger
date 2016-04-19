class Integration < ActiveRecord::Base
  belongs_to :website

  def driver
    Integrations.create(self)
  end

  def connect(auth_hash)
    driver.connect(auth_hash)
  end
end
