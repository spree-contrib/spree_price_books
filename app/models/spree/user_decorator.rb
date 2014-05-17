Spree.user_class.class_eval do

  # When prices are determined based on the user role we must also include nil.
  def price_book_role_ids
    [nil, spree_roles.pluck(:id)].flatten
  end

end
