require 'spree/api/testing_support/helpers'
require 'spree/api/testing_support/setup'

RSpec.configure do |config|
  config.include Spree::Api::TestingSupport::Helpers
  config.extend Spree::Api::TestingSupport::Setup, type: :request
end
