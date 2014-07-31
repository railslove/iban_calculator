require 'savon'

module IbanCalculator
  class IbanBic
    ITALIAN_IBAN_LENGTH = 27
    PREFIX_AND_CHECKSUM_LENGTH = 4

    attr_accessor :user, :password, :url, :logger

    def initialize(user, password, url, logger)
      self.user = user
      self.password = password
      self.url = url
      self.logger = logger
    end

    # You should provide country, bank_code, and account_number. (cin, abi, and cab for Italian accounts)
    def calculate_iban(attributes)
      payload = iban_payload(attributes)
      response = client.call(:calculate_iban, message: payload).body[:calculate_iban_response][:return]
      log "iban lookup attributes=#{attributes} payload=#{payload} response=#{response}"
      formatted_result(response)
    end

    def italian_account_number(attributes = {})
      return {} unless ['cin', 'abi', 'cab', 'account_number'].sort == attributes.keys.map(&:to_s).sort
      left_length = ITALIAN_IBAN_LENGTH - PREFIX_AND_CHECKSUM_LENGTH - attributes['account_number'].length
      left_side = [attributes['cin'], attributes['abi'], attributes['cab']].join.ljust(left_length, '0')
      { 'account_number' => left_side + attributes['account_number'] }
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
      candidates[:item].select { |key, _| [:bic, :zip, :city].include?(key) }
    rescue
      log "Could not handle candidates=#{candidates}"
      fail ArgumentError, "Could not handle BIC response"
    end

    def iban_payload(attributes)
      attributes = attributes.with_indifferent_access
      normalized_attributes = attributes.merge(italian_account_number(attributes))
      payload = normalized_attributes.select { |k,_| [:country, :account_number, :bank_code].include?(k) }
      default_payload.merge(payload)
    end

    def log(message)
      logger.info message
    end

    def client
      @client ||= Savon.client(wsdl: url)
    end
  end
end
