class CreateSpreePriceBooks < ActiveRecord::Migration
  def change
    create_table :spree_price_books do |t|
      t.datetime :active_from
      t.datetime :active_to
      t.string :currency
      t.boolean :default, default: false, null: false
      t.boolean :discount, default: false, null: false
      t.string :name
      t.integer :parent_id
      t.float :price_adjustment_factor
      t.integer :priority, default: 0, null: false
      t.belongs_to :role
      t.belongs_to :store
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      t.timestamps
    end
    add_index :spree_price_books, :active_from
    add_index :spree_price_books, :active_to
    add_index :spree_price_books, :currency
    add_index :spree_price_books, :default
    add_index :spree_price_books, :depth
    add_index :spree_price_books, :parent_id
    add_index :spree_price_books, :role_id
    add_index :spree_price_books, :store_id
    add_index :spree_price_books, :lft
    add_index :spree_price_books, :rgt

    add_column :spree_prices, :price_book_id, :integer
    add_index :spree_prices, :price_book_id

    add_column :spree_line_items, :list_price, :decimal, :precision => 10, :scale => 2, :default => 0.0
  end
end
