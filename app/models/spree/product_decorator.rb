Spree::Product.class_eval do

  has_many :price_books, through: :master

  def master_price_for(price_book)
    Spree::Price.where(
      variant_id: self.master.id,
      price_book_id: price_book.id
    ).first
  end

  def display_master_price_for(price_book)
    price = master_price_for(price_book)
    Spree::Money.new(price.amount, currency: price_book.currency)
  end

end
