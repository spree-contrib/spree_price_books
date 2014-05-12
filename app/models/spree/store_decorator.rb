Spree::Store.class_eval do

  has_many :price_books, -> {
    select("DISTINCT (#{table_name}.id), #{table_name}.*, #{Spree::StorePriceBook.table_name}.priority").
      order("#{Spree::StorePriceBook.table_name}.priority DESC")
  }, through: :store_price_books

  has_many :store_price_books

end
