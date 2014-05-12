class Spree::StorePriceBook < ActiveRecord::Base

  belongs_to :price_book
  belongs_to :store

  delegate :name, to: :price_book

end
