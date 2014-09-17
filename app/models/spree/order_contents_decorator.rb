module Spree
  OrderContents.class_eval do

    # We want to require currency to be set so don't allow nil default.
    def add_to_line_item(variant, quantity, currency, shipment=nil)
      # Since we now require currency a nil quantity doesn't force a 1 anymore.
      quantity ||= 1

      line_item = grab_line_item_by_variant(variant)

      if line_item
        line_item.target_shipment = shipment
        line_item.quantity       += quantity.to_i
        line_item.currency        = currency
      else
        line_item                 = order.line_items.new(quantity: quantity, variant: variant)
        line_item.target_shipment = shipment
        line_item.currency        = currency
        line_item.list_price      = variant.list_price_in(currency, order.store, order.user.try(:price_book_role_ids)).amount
        line_item.price           = variant.price_in(currency, order.store, order.user.try(:price_book_role_ids)).amount
      end
      line_item.save
      line_item
    end

  end
end
