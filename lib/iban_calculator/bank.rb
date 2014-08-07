module IbanCalculator
  class Bank
    attr_accessor :code, :name, :country, :address, :url, :branch, :branch_code

    def initialize(attributes = {})
      self.code = attributes[:code]
      self.name = attributes[:name]
      self.country = attributes[:country]
      self.address = attributes[:address]
      self.url = attributes[:url]
      self.branch = attributes[:branch]
      self.branch_code = attributes[:branch_code]
    end

    def as_json(opts = {})
      {
        code: code,
        name: name,
        country: country,
        address: address,
        url: url,
        branch: branch,
        branch_code: branch_code,
      }
    end
  end
end
