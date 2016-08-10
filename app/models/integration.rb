class Integration < ActiveRecord::Base
  extend Enumerize
  enumerize :provider, in: Integrations.drivers_types, scope: true, predicates: true

  belongs_to :website
  validates :name, :provider, presence: true
  store_accessor :configuration

  attr_accessor :app_name, :app_owner

  before_update :select_application, if: -> { app_name && app_owner }

  def driver
    Integrations.create(self)
  end

  def select_application
    self.configuration["selected_application"] = app_name
    self.configuration["application_owner"] = app_owner
  end

  def assign_configuration(auth_hash)
    self.configuration = driver.build_configuration(auth_hash)
    self.provider = driver.type
  end

  def get_applications
    driver.applications
  end

  def selected_application
    driver.selected_application
  end
end
