Spree::LineItem.class_eval do

	alias_method :orginal_copy_price, :copy_price
  # When prices are determined based on the user role we must also include nil.
	def copy_price
    if variant
    	# self.list_price = variant.list_price_in(order.currency, order.store, order.user.try(:price_book_role_ids)).amount if list_price.nil?
      self.price = variant.price_in(order.currency, order.store, order.user.try(:price_book_role_ids)).amount if price.nil?
    end
    orginal_copy_price
  end
end
