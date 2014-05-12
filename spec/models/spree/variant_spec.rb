require 'spec_helper'

describe Spree::Variant do

  describe 'Price Books' do

    before do
      @variant = create(:variant, price: 6)
      @default_price = @variant.default_price

      price_book = create(:price_book)

      @sale_price = @variant.prices.create! price_book: price_book, amount: 5
    end

    it '#default_price' do
      expect(@default_price.amount.to_f).to eql(6.0)
      expect(@default_price.price_book).to eql(Spree::PriceBook.default)
    end

    it '#price' do
      expect(@variant.price.to_f).to eql(6.0)
    end

  end

  describe '#list_price_in' do
    let(:variant) { create(:variant, price: 10) }

    before do
      default_book = Spree::PriceBook.default.update_attribute :priority, 1
      default_price = variant.default_price
      first_book = create(:price_book, priority: 2)
      first_price = variant.prices.create amount: 5, price_book: first_book
      second_book = create(:active_price_book, priority: 3)
      @second_price = variant.prices.create amount: 8, price_book: second_book
      third_book = create(:active_price_book, discount: true, priority: 4)
      third_price = variant.prices.create amount: 7, price_book: third_book
      fourth_book = create(:active_price_book, currency: 'GBP', priority: 5)
      fourth_price = variant.prices.create amount: 6, price_book: fourth_book
    end

    it 'should find price belonging to a list price book by highest priority' do
      expect(variant.list_price_in('USD')).to eql(@second_price)
    end
  end

  describe '#price_in' do

    let(:variant) { create(:variant, price: 10) }

    before do
      default_book = Spree::PriceBook.default.update_attribute :priority, 1
      default_price = variant.default_price
      first_book = create(:price_book, priority: 2)
      first_price = variant.prices.create amount: 8, price_book: first_book
      second_book = create(:active_price_book, priority: 3)
      second_price = variant.prices.create amount: 5, price_book: second_book
      third_book = create(:active_price_book, discount: true, priority: 3)
      third_price = variant.prices.create amount: 7, price_book: third_book
      fourth_book = create(:active_price_book, currency: 'GBP', priority: 4)
      fourth_price = variant.prices.create amount: 6, price_book: fourth_book
    end

    it 'should find price ordered by highest priority price book then lowest amount' do
      variant.price_in('USD').amount.to_f.should eql(5.0)
    end

  end

end
