module SpreeOnlyOneLineItemPerOrder
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_only_one_line_item_per_order'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_only_one_line_item_per_order.environment', before: :load_config_initializers do |_app|
      SpreeOnlyOneLineItemPerOrder::Config = SpreeOnlyOneLineItemPerOrder::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Spree::Api::Dependencies.storefront_cart_add_item_service = 'Spree::Cart::AddItemIfEmpty'
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
