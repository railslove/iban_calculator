module IbanCalculator
  class InvalidData < StandardError
    CODES = {
      128  => [:account_number, [:checksum_failed]],
      256  => [:bank_code,      [:not_found]],
      512  => [:account_number, [:invalid_length]],
      1024 => [:bank_code,      [:invalid_length]],
      4096 => [:base,           [:data_missing]],
      8192 => [:country,        [:not_supported]],
    }

    attr_accessor :errors

    def initialize(msg, error_code)
      self.errors = resolve_error_code(error_code)
      super(msg)
    end

    def resolve_error_code(error_code)
      known_error_codes(error_code).reduce(Hash.new([])) do |hsh, item|
        error = CODES[item]
        hsh[error[0]] += error[1]
        hsh
      end
    end

    def known_error_codes(error_code)
      error_codes(error_code) & CODES.keys
    end

    def error_codes(n)
      (0..13).map { |i| n & 2**i } - [0]
    end
  end
end
