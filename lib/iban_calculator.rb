require 'iban_calculator/version'
require 'active_support/configurable'
require 'active_support/core_ext/hash'
require 'logger'
require 'iban_calculator/iban_bic'
require 'iban_calculator/invalid_data'
require 'iban_calculator/bic_candidate'
require 'iban_calculator/iban_validator_response'

module IbanCalculator
  # Extensions
  include ActiveSupport::Configurable

  # Configuration
  config_accessor(:url) { 'https://ssl.ibanrechner.de/soap/?wsdl' }
  config_accessor(:user) { '' }
  config_accessor(:password) { '' }
  config_accessor(:logger) { Logger.new(STDOUT) }

  # Errors
  ServiceError = Class.new(StandardError)

  def self.calculate_iban(attributes = {})
    client = IbanBic.new(config.user, config.password, config.url, config.logger)
    client.calculate_iban(attributes)
  end

  def self.validate_iban(iban)
    client = Savon.client(wsdl: config.url, logger: config.logger)
    response = client.call(:validate_iban, message: { iban: iban, user: config.user, password: config.password })
    IbanValidatorResponse.new(response.body[:validate_iban_response][:return])
  end
end
