class CreateSpreeCurrencyRates < ActiveRecord::Migration
  def change
    create_table :spree_currency_rates do |t|
      t.string :base_currency
      t.string :currency
      t.boolean :default, null: false, default: false, index: true
      t.float :exchange_rate
      t.timestamps
    end
  end
end
