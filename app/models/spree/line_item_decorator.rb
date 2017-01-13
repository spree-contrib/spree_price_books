Spree::LineItem.class_eval do

	alias_method :orginal_copy_price, :copy_price
  
  # Copy price and list_price based on user's role unless price already set.
  # list_price defaults to 0.0 so attempt to re-assign if it is the default value.
	def copy_price
    if variant
    	self.list_price = variant.list_price_in(order.currency, order.store, order.user.try(:price_book_role_ids)).amount if list_price.nil? || list_price == 0.0
      self.price = variant.price_in(order.currency, order.store, order.user.try(:price_book_role_ids)).amount if price.nil?
    end
    orginal_copy_price
  end
end
