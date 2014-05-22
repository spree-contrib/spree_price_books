require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatMultiCurrencyRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :base_currency, :string, default: -> { Spree::Config[:currency] }

      def self.description
        Spree.t(:shipping_flat_multi_currency_rate_per_order)
      end

      def compute_package(package)

        exchange_rate = if Spree::CurrencyRate.default.base_currency == package.order.currency
                          1
                        else
                          Spree::CurrencyRate.find_by(base_currency: preferred_base_currency, currency: package.order.currency).try(:exchange_rate)
                        end

        if exchange_rate.nil?
          raise "CurrencyRateNotFound for #{preferred_base_currency} to #{package.order.currency}"
        end

        self.preferred_amount * exchange_rate
      end

    end
  end
end
