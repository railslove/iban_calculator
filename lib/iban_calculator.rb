require 'iban_calculator/version'
require 'active_support/configurable'
require 'active_support/core_ext/hash'
require 'logger'
require 'iban_calculator/iban_bic'

module IbanCalculator
  include ActiveSupport::Configurable

  config_accessor(:url) { 'https://ssl.ibanrechner.de/soap/?wsdl' }
  config_accessor(:user) { '' }
  config_accessor(:password) { '' }
  config_accessor(:logger) { Logger.new(STDOUT) }

  def self.calculate_iban(attributes = {})
    client = IbanBic.new(config.user, config.password, config.url, config.logger)
    client.calculate_iban(attributes)
  end
end
