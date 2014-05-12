require 'spec_helper'

describe Spree::Product do

  let(:product) { create(:product) }
  let(:price_book) { create(:price_book) }

  before(:each) { price_book.add_product(product) }

  it '#display_master_price_for' do
    price = product.display_master_price_for(price_book)
    expect(price).to eq Spree::Money.new(19.99, currency: "USD")
  end

  it '#master_price_for' do
    price = product.master_price_for(price_book)
    expect(price).to be_an_instance_of Spree::Price
    expect(price.variant_id).to eq product.master.id
    expect(price.price_book_id).to eq price_book.id
    expect(price.amount).to eq 19.99
    expect(price.currency).to eq price_book.currency
  end

end
