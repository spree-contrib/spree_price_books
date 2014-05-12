class CreateSpreeStorePriceBooks < ActiveRecord::Migration
  def change
    create_table :spree_store_price_books do |t|
      t.belongs_to :price_book, index: true
      t.belongs_to :store, index: true
      t.integer :priority, default: 0, null: false, index: true

      t.timestamps
    end
  end
end
