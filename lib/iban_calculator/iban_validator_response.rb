module IbanCalculator
  class IbanValidatorResponse
    CHECKS = {
      length: :length_check,
      account_number: :account_check,
      bank_code: :bank_code_check,
      iban_checksum: :iban_checksum_check,
    }

    attr_accessor :raw_response

    def initialize(raw_response)
      self.raw_response = raw_response
    end

    def valid?
      return_code < 128
    end

    def return_code
      @return_code ||= raw_response[:return_code].to_i
    end

    def bic_candidates
      @bic_candidates ||= BicCandidate.build_list(raw_response[:bic_candidates])
    end

    def bank
      @bank ||= begin Bank.new({
          code: string_or_default(raw_response[:bank_code]),
          name: string_or_default(raw_response[:bank]),
          country: string_or_default(raw_response[:country]),
          address: string_or_default(raw_response[:bank_address]).strip,
          url: string_or_default(raw_response[:bank_url]),
          branch: string_or_default(raw_response[:branch]),
          branch_code: string_or_default(raw_response[:branch_code]),
        })
      end
    end

    def account_number
      @account_number ||= string_or_default(raw_response[:account_number], nil)
    end

    def checks
      CHECKS.each_with_object({}) do |(app_key, api_key), result|
        result[app_key] = string_or_default(raw_response[api_key], 'not_checked')
      end
    end

    def updated_at
      @data_created_at ||= Date.parse(raw_response[:data_age]) if string_or_default(raw_response[:data_age], nil)
    end

    def errors
      @errors ||= InvalidData.new('', return_code).errors
    end

    def as_json(opts = {})
      {
        valid: valid?,
        errors: errors,
        account_number: account_number,
        bank: bank.as_json(opts),
        bic_candidates: bic_candidates.map { |c| c.as_json(opts) },
        updated_at: updated_at,
        checks: checks,
      }.deep_stringify_keys!
    end

    private

    def string_or_default(input, default = '')
      input.kind_of?(String) ? input : default
    end
  end
end
