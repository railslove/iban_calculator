require 'iban_calculator/version'
require 'active_support/configurable'
require 'logger'

module IbanCalculator
  include ActiveSupport::Configurable

  config_accessor(:url) { 'https://ssl.ibanrechner.de/soap/?wsdl' }
  config_accessor(:user) { '' }
  config_accessor(:password) { '' }
  config_accessor(:logger) { Logger.new(STDOUT) }
end
