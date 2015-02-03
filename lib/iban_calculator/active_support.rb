# these are methods implemented in active_support 4 which
# are required to run this gem with active_support 3
require 'active_support/configurable'

module IbanCalculator
  include ActiveSupport::Configurable

  # taken from: activesupport/lib/active_support/core_ext/hash/keys.rb
  Hash.class_eval do
    def deep_stringify_keys!
      deep_transform_keys!{ |key| key.to_s }
    end

    def deep_transform_keys!(&block)
      keys.each do |key|
        value = delete(key)
        self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
      end
      self
    end
  end
end

class << IbanCalculator
  alias_method :old_config_accessor, :config_accessor

  def config_accessor(key, &block)
    old_config_accessor(key)
    send("#{key}=", block.call)
  end
end
