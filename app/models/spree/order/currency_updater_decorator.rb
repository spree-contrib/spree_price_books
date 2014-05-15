module Spree
  class Order < Spree::Base
    CurrencyUpdater.class_eval do

      # Updates price from given line item
      def update_line_item_price!(line_item)
        price = price_from_line_item(line_item)

        if price
          line_item.update_attributes!(
            currency: price.currency,
            list_price: price.variant.list_price_in(price.currency, line_item.order.store).price,
            price: price.price
          )
        else
          raise RuntimeError, "no #{currency} price found for #{line_item.product.name} (#{line_item.variant.sku})"
        end
      end

    end
  end
end
