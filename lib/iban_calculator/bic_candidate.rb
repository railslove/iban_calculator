module IbanCalculator
  class BicCandidate
    attr_accessor :bic, :city, :sample_url, :www_count, :zip

    def self.build_list(raw_response)
      Array.wrap(raw_response[:item]).map { |candidate| new(candidate) }
    end

    def initialize(raw_attributes = {})
      self.bic = raw_attributes[:bic]
      self.zip = string_or_default(raw_attributes[:zip])
      self.city = string_or_default(raw_attributes[:city])
      self.sample_url = string_or_default(raw_attributes[:sampleurl])
      self.www_count = raw_attributes[:wwwcount].to_i
    end

    def source
      www_count > 0 ? :www : :directory
    end

    def as_json(opts = {})
      {
        bic: bic,
        zip: zip,
        city: city,
        sample_url: sample_url,
        www_count: www_count,
      }.deep_stringify_keys!
    end

    private

    def string_or_default(input, default = '')
      input.kind_of?(String) ? input : default
    end
  end
end
