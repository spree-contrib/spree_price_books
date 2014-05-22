module SpreePriceBooks
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_price_books'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree_active_shipping.register.calculators" do |app|
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::FlatMultiCurrencyRate
    end
  end
end
