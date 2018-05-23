require 'savon'

# Return codes and their meaning:
#
# 0 = all checks were successful
#
# 1 = sub account number has been added automatically
# 2 = account number did not include a checksum
# 4 = checksum has not been checked
# 8 = bank code has not been checked
#
# 32 = A sub account number might be required, but could not be determined autoamtically
#
# 128 = checksum for account_number is invalid
# 256 = bank_code could not be found is database
# 512 = account_number has an invalid length
# 1024 = bank_code has an invalid length
# 4096 = data is missing (i.e. country code)
# 8192= country is not yet supported
#
module IbanCalculator
  class IbanBic
    ITALIAN_IBAN_LENGTH = 27
    PREFIX_AND_CHECKSUM_LENGTH = 4

    VALID_RESPONSE_CODE = 0..31
    PROBABLY_VALID_RESPONSE_CODE = 32..127
    SERVICE_ERROR_RESPONSE_CODE = 65536

    attr_accessor :user, :password, :url, :logger, :config

    def initialize(config)
      self.user = config.user
      self.password = config.password
      self.url = config.url
      self.logger = config.logger
      self.config = config
    end

    # You should provide country, bank_code, and account_number. (cin, abi, and cab for Italian accounts)
    def calculate_iban(attributes)
      payload = iban_payload(attributes)
      response = client.call(:calculate_iban, message: payload).body[:calculate_iban_response][:return]
      log "iban lookup attributes=#{attributes} payload=#{payload} response=#{response}"

      case return_code = response[:return_code].to_i
      when VALID_RESPONSE_CODE
        formatted_result(response)
      when PROBABLY_VALID_RESPONSE_CODE
        log "iban check needs manual check return_code=#{return_code}"
        formatted_result(response)
      when SERVICE_ERROR_RESPONSE_CODE
        log "iban check failed return_code=#{return_code}"
        fail ServiceError, 'Service could not handle the request'
      else
        log "iban check invalid return_code=#{return_code}"
        fail InvalidData.new('Invalid input data', return_code)
      end
    end

    def italian_account_number(attributes = {})
      return {} unless attributes['country'].to_s.upcase == 'IT'
      left_length = ITALIAN_IBAN_LENGTH - PREFIX_AND_CHECKSUM_LENGTH - attributes['account'].length
      left_side = [attributes['cin'], attributes['abi'], attributes['cab']].join.ljust(left_length, '0')
      { 'account' => left_side + attributes['account'] }
    end

    def default_payload
      { country: '', bank_code: '', account: '', user: user, password: password, bic: '', legacy_mode: 0 }
    end

    def formatted_result(data)
      { iban: data[:iban],
        bics: process_bic_candidates(data[:bic_candidates]),
        country: data[:country],
        bank_code: data[:bank_code],
        bank: data[:bank],
        account_number: data[:account_number],
        updated_at: Date.parse(data[:data_age]) }
    end

    def process_bic_candidates(candidates)
      [candidates[:item].select { |key, value| [:bic, :zip, :city].include?(key) && value.kind_of?(String) }]
    rescue
      log "Could not handle candidates=#{candidates}"
      fail ArgumentError, "Could not handle BIC response"
    end

    def iban_payload(attributes)
      attributes = attributes.with_indifferent_access
      attributes['account'] = attributes.delete('account_number')
      normalized_attributes = attributes.merge(italian_account_number(attributes))
      payload = normalized_attributes.select { |k,_| %w(country account bank_code).include?(k) }
      default_payload.merge(payload.symbolize_keys)
    end

    def log(message)
      logger.info message
    end

    def client
      @client ||= Savon.client(wsdl: url, read_timeout: config.read_timeout, open_timeout: config.open_timeout)
    end
  end
end
