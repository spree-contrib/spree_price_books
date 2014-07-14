require 'spec_helper'

describe Spree::Price do

  describe 'Scopes' do

    it '.by_currency' do
      usd_book = create :price, currency: 'USD', price_book: create(:price_book, currency: 'USD')
      gbp_book = create :price, currency: 'GBP', price_book: create(:price_book, currency: 'GBP')
      expect(subject.class.by_currency('GBP').to_a).to eql([gbp_book])
    end

    context '.by_role' do
      let!(:admin) { create(:role, name: 'admin') }
      let!(:customer) { create(:role, name: 'customer') }
      let!(:employee) { create(:role, name: 'employee') }

      let!(:p1) { create(:price, price_book: create(:price_book, role: admin)) }
      let!(:p2) { create(:price, price_book: create(:price_book)) }
      let!(:p3) { create(:price, price_book: create(:price_book, role: customer)) }
      let!(:p4) { create(:price, price_book: create(:price_book)) }
      let!(:p5) { create(:price, price_book: create(:price_book, role: employee)) }

      it 'should return books for NULL id' do
        results = subject.class.by_role(nil).to_a
        expect(results).to_not include(p1)
        expect(results).to include(p2)
        expect(results).to_not include(p3)
        expect(results).to include(p4)
        expect(results).to_not include(p5)
      end

      it 'should return books for single id' do
        results = subject.class.by_role(customer.id).to_a
        expect(results).to_not include(p1)
        expect(results).to_not include(p2)
        expect(results).to include(p3)
        expect(results).to_not include(p4)
        expect(results).to_not include(p5)
      end

      it 'should return books for array of ids' do
        results = subject.class.by_role([admin.id, employee.id]).to_a
        expect(results).to include(p1)
        expect(results).to_not include(p2)
        expect(results).to_not include(p3)
        expect(results).to_not include(p4)
        expect(results).to include(p5)

        results = subject.class.by_role([nil, employee.id]).to_a
        expect(results).to_not include(p1)
        expect(results).to include(p2)
        expect(results).to_not include(p3)
        expect(results).to include(p4)
        expect(results).to include(p5)
      end
    end

    it '.by_store' do
      store_1 = create(:store)
      store_2 = create(:store)
      default = Spree::PriceBook.default

      price_1 = create :price, price_book: create(:store_price_book, stores: [store_1])
      price_2 = create :price, price_book: create(:store_price_book, stores: [store_2])
      price_3 = create :price, price_book: create(:store_price_book, stores: [store_1, store_2])

      expect(subject.class.by_store(store_1.id).to_a).to include(price_1)
      expect(subject.class.by_store(store_1.id).to_a).to_not include(price_2)
      expect(subject.class.by_store(store_1.id).to_a).to include(price_3)

      expect(subject.class.by_store(store_2.id).to_a).to_not include(price_1)
      expect(subject.class.by_store(store_2.id).to_a).to include(price_2)
      expect(subject.class.by_store(store_2.id).to_a).to include(price_3)
    end

    it '.list' do
      p1 = create :price
      p2 = create :price, price_book: create(:price_book, discount: true)
      p3 = create :price

      expect(subject.class.list.to_a).to include(p1)
      expect(subject.class.list.to_a).to_not include(p2)
      expect(subject.class.list.to_a).to include(p3)
    end

  end

  it '#ensure_proper_currency' do
    record = build(:price, currency: 'GBP', price_book: create(:price_book))
    expect(record.valid?).to be false
    record.currency = 'USD'
    expect(record.valid?).to be true
  end

  describe '#populate_children' do

    before do
      @parent_book = Spree::PriceBook.default
      @child_book = create :factored_price_book, parent: @parent_book, price_adjustment_factor: 0.5
      @explicit_book = create :explicit_price_book
      @product = create :product, price: 10
    end

    it 'should add price only to child price books on create' do
      expect(@parent_book.prices.find_by_variant_id(@product.master.id).amount.to_f).to eql(10.0)
      expect(@child_book.prices.find_by_variant_id(@product.master.id).amount.to_f).to eql(5.0)
      expect(@explicit_book.prices.find_by_variant_id(@product.master.id)).to be_nil
    end

  end

  describe '#update_children' do

    before do
      @parent_book = Spree::PriceBook.default
      @child_book = create :factored_price_book, parent: @parent_book, price_adjustment_factor: 0.5
      @explicit_book = create :explicit_price_book
      @product = create :product, price: 10
      @explicit_book.prices.create amount: 4, variant_id: @product.master.id
      @product.update_attribute :price, 9
    end

    it 'should update price only to child price books on update' do
      expect(@parent_book.prices.find_by_variant_id(@product.master.id).amount.to_f).to eql(9.0)
      expect(@child_book.prices.find_by_variant_id(@product.master.id).amount.to_f).to eql(4.5)
      expect(@explicit_book.prices.find_by_variant_id(@product.master.id).amount.to_f).to eql(4.0)
    end

  end

end
