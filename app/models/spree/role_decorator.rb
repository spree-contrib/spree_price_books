module Spree
  Role.class_eval do
    has_many :price_books
    scope :with_price_book, -> { where(id: Spree::PriceBook.pluck(:role_id).uniq) }
  end
end
