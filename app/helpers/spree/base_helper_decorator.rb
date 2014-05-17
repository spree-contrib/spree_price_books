module Spree
  BaseHelper.class_eval do
    def display_price(product_or_variant)
      product_or_variant.price_in(current_currency, current_store.id, spree_current_user.try(:price_book_role_ids)).display_price.to_html
    end
  end
end
