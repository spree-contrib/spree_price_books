module Spree
  BaseHelper.class_eval do
    def display_price(product_or_variant)
      role_ids = spree_current_user.present? ? [nil, spree_current_user.spree_roles.pluck(:id)].flatten : nil
      product_or_variant.price_in(current_currency, current_store.id, role_ids).display_price.to_html
    end
  end
end
